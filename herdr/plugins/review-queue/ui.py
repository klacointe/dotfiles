#!/usr/bin/env python3
"""Review queue TUI (stdlib curses, no dependencies).

Open WTTJ PRs awaiting my review, humans first then bots, grouped by repo.
`ui.py --mine` shows my own open PRs instead (CI, review decision, unresolved comments, conflicts).
Mouse: click selects, click again (or double-click) starts a review, right-click
opens the PR in the browser, wheel scrolls. Keyboard: see FOOTER.
Reviews are started by the sibling `review-queue --open URL` (herdr workspace).
"""
import curses
import json
import os
import re
import subprocess
import sys
import threading
import time
import webbrowser
from datetime import datetime, timezone

OWNER = os.environ.get("REVIEW_QUEUE_OWNER", "WTTJ")
REFRESH = int(os.environ.get("REVIEW_QUEUE_REFRESH", "300"))
HERE = os.path.dirname(os.path.realpath(__file__))
ENGINE = os.path.join(HERE, "review-queue")
# Selected row / bars: dark-grey background keeping the foreground colours (reverse video gave white blocks).
# SEL is a marker bit translated by put(); override the grey with REVIEW_QUEUE_SEL_BG (256-colour index).
SEL = curses.A_PROTECT
SEL_BG = int(os.environ.get("REVIEW_QUEUE_SEL_BG", "238"))
MINE = "--mine" in sys.argv
CACHE = os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")),
                     "review-queue-mine.json" if MINE else "review-queue.json")
# Nerd Font glyphs (the terminal font is a Nerd Font)
I_PR, I_EYE, I_USER, I_BOT = "\uf407", "\uf06e", "\uf007", "\uf544"
I_OK, I_DRAFT, I_SYNC, I_FILTER, I_WARN = "\uf00c", "\uf040", "\uf021", "\uf0b0", "\uf071"
I_X, I_DOT, I_UP, I_CHG, I_CIRC, I_COMMENT = "\uf00d", "\uf111", "\uf164", "\uf06a", "\uf017", "\uf075"
SPIN = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
# (key, label) pairs shown in the footer
HINTS_MINE = (("2×click", "GitHub"), ("↵", "fix"), ("c", "comments"), ("f", "fix CI"), ("b", "browser"), ("y", "copy"),
              ("/", "filter"), ("r", "refresh"), ("?", "legend"), ("q", "quit"))
HINTS = (("2×click", "GitHub"), ("↵", "review"), ("a", "analyze"), ("c", "comments"), ("f", "fix CI"), ("b", "browser"), ("y", "copy"),
         ("/", "filter"), ("h", "bots"), ("r", "refresh"), ("?", "legend"), ("q", "quit"))
I_SEARCH, I_REPLY, I_WRENCH, I_LINK, I_COPY, I_PLAY, I_GLOBE = "\uf002", "\uf112", "\uf0ad", "\uf0c1", "\uf0c5", "\uf04b", "\uf0ac"
PANEL_H = 6   # detail panel above the footer: rule, title, link, status, buttons, spacer
CI_TEXT = {"SUCCESS": ("CI passing", "green"), "FAILURE": ("CI failing", "red"), "ERROR": ("CI error", "red"),
           "PENDING": ("CI running", "yellow"), "EXPECTED": ("CI running", "yellow")}
DECISION_TEXT = {"APPROVED": ("approved", "green"), "CHANGES_REQUESTED": ("changes requested", "red"),
                 "REVIEW_REQUIRED": ("review required", "dim")}
TYPE_ATTR = {"feat": "green", "fix": "red", "refactor": "blue", "perf": "blue", "docs": "cyan", "ci": "dim", "chore": "dim",
             "test": "cyan", "build": "dim", "revert": "red", "style": "dim"}
PREFIX_RE = re.compile(r"^(\w+)(\([^)]*\))?(!)?:\s*")
TICKET_RE = re.compile(r"\s*\[([A-Z][A-Z0-9]+-\d+)\]\s*$")
FIELDS = "repository,number,title,author,url,updatedAt,isDraft"


def age(iso):
    t = datetime.fromisoformat(iso.replace("Z", "+00:00"))
    s = (datetime.now(timezone.utc) - t).total_seconds()
    if s < 3600:
        return f"{int(s // 60)}m"
    if s < 86400:
        return f"{int(s // 3600)}h"
    return f"{int(s // 86400)}d"


def age_seconds(iso):
    t = datetime.fromisoformat(iso.replace("Z", "+00:00"))
    return (datetime.now(timezone.utc) - t).total_seconds()


def trunc(s, n):
    return s if len(s) <= n else s[: n - 1] + "…"


GRAPHQL = os.path.join(HERE, "details.graphql")
# Bots are excluded from the (heavy) details query; they are listed from the cheap search only.
NO_BOTS = " ".join(f"-author:app/{b}" for b in ("github-actions", "wttj-bot", "renovate", "dependabot"))
Q_REQUESTED = f"is:pr is:open review-requested:@me org:{OWNER} archived:false sort:updated-desc"
Q_REVIEWED = f"is:pr is:open reviewed-by:@me -author:@me org:{OWNER} archived:false sort:updated-desc"
Q_MINE = f"is:pr is:open author:@me org:{OWNER} archived:false sort:updated-desc"


def gh_json(args):
    out = subprocess.run(["gh", *args], capture_output=True, text=True, timeout=90, check=True).stdout
    return json.loads(out)


def unresolved(node):
    return sum(1 for t in node["reviewThreads"]["nodes"] if not t["isResolved"])


def details(node):
    """CI state, review decision, unresolved threads and conflict flag for one PR node."""
    commits = node["commits"]["nodes"]
    rollup = (commits[0]["commit"]["statusCheckRollup"] if commits else None) or {}
    return {"detail": True, "ci": rollup.get("state"), "decision": node["reviewDecision"],
            "threads": unresolved(node), "conflict": node["mergeable"] == "CONFLICTING"}


MINE_GRAPHQL = os.path.join(HERE, "mine.graphql")
# bucket order and titles for the "mine" view
MINE_GROUPS = (("attn", "Needs your attention"), ("ready", "Ready to merge"), ("wait", "Waiting for review"), ("draft", "Drafts"))


def needs_attention(p):
    return (p.get("ci") in ("FAILURE", "ERROR") or p.get("decision") == "CHANGES_REQUESTED"
            or bool(p.get("threads")) or bool(p.get("conflict")))


def bucket(p):
    if p["isDraft"]:
        return "draft"
    if needs_attention(p):
        return "attn"
    if p.get("decision") == "APPROVED" and p.get("ci") in ("SUCCESS", None):
        return "ready"
    return "wait"


def fetch_mine():
    """(prs, warning): my own open PRs with CI, review decision, unresolved threads and conflicts."""
    data = gh_json(["api", "graphql", "-F", f"query=@{MINE_GRAPHQL}", "-f", f"q={Q_MINE}"])["data"]
    prs = []
    for n in data["a"]["nodes"]:
        if not n:
            continue
        reviewers = [(r["requestedReviewer"] or {}).get("login") or (r["requestedReviewer"] or {}).get("name")
                     for r in n["reviewRequests"]["nodes"]]
        p = {"url": n["url"], "number": n["number"], "title": n["title"], "updatedAt": n["updatedAt"], "isDraft": n["isDraft"],
             "author": n["author"], "repository": n["repository"], "bot": False, "follow": False, **details(n)}
        p["who"] = ", ".join(r for r in reviewers if r) or "no reviewer"
        p["repo"] = p["repository"]["name"]
        p["age"] = age(p["updatedAt"])
        prs.append(p)
    prs.sort(key=lambda p: (p["repo"], p["number"]))
    return prs, None


def fetch_requested():
    """(prs, warning). Cheap search for the whole list, GraphQL for CI/review details on human PRs."""
    base = gh_json(["search", "prs", "--review-requested=@me", "--state=open", f"--owner={OWNER}",
                    "--limit", "100", "--json", FIELDS])
    warn = None
    follow = []
    try:
        data = gh_json(["api", "graphql", "-F", f"query=@{GRAPHQL}", "-f", f"q1={Q_REQUESTED} {NO_BOTS}",
                        "-f", f"q2={Q_REVIEWED}"])["data"]
        me = data["viewer"]["login"]
        by_url = {n["url"]: details(n) for n in data["a"]["nodes"] if n}
        requested = {p["url"] for p in base}
        for n in data["b"]["nodes"]:
            if not n or n["url"] in requested or n["author"]["__typename"] == "Bot":
                continue
            mine = [r for r in n["reviews"]["nodes"] if r["author"] and r["author"]["login"] == me]
            last = mine[-1] if mine else None
            new_commits = bool(last and last["commit"] and last["commit"]["oid"] != n["headRefOid"])
            if last and (last["state"] != "APPROVED" or new_commits):
                follow.append({"url": n["url"], "number": n["number"], "title": n["title"], "updatedAt": n["updatedAt"],
                               "isDraft": n["isDraft"], "author": {"login": n["author"]["login"], "is_bot": False},
                               "repository": n["repository"], "follow": True, "mine": last["state"],
                               "new_commits": new_commits, **details(n)})
    except Exception as e:  # keep the plain list, just without CI / review details
        by_url = {}
        warn = f"details unavailable: {str(e)[:50]}"
    for p in base:
        p.update(by_url.get(p["url"], {}))
    prs = base + follow
    for p in prs:
        login = p["author"]["login"]
        p["bot"] = bool(p["author"].get("is_bot")) or login.endswith("[bot]")
        p["who"] = login.removesuffix("[bot]")
        p["repo"] = p["repository"]["name"]
        p["age"] = age(p["updatedAt"])
    prs.sort(key=lambda p: (p["bot"], p["repo"], p["number"]))
    return prs, warn


class State:
    def __init__(self):
        self.prs = []
        self.status = "loading…"
        self.updated = None
        self.loading = False
        self.error = None
        self.sel_url = None
        self.top = 0
        self.filter = ""
        self.typing = False
        self.hide_bots = False
        self.opened = set()
        self.msg = ""
        self.msg_at = 0.0
        self.last_click = (None, 0.0)
        self.sessions = {}
        self.sessions_at = 0.0
        self.legend = True
        try:
            with open(CACHE) as f:
                self.prs = json.load(f)
                self.status = "cached"
        except (OSError, ValueError):
            pass

    def refresh(self):
        if self.loading:
            return
        self.loading = True

        def work():
            try:
                self.prs, self.error = fetch_mine() if MINE else fetch_requested()
                self.updated = datetime.now()
                os.makedirs(os.path.dirname(CACHE), exist_ok=True)
                with open(CACHE, "w") as f:
                    json.dump(self.prs, f)
            except Exception as e:  # keep showing the previous list
                self.error = f"gh failed: {str(e)[:60]}"
            finally:
                self.loading = False

        threading.Thread(target=work, daemon=True).start()

    def flash(self, text):
        self.msg, self.msg_at = text, time.time()

    def rows(self):
        """Visible rows: ('head', text, kind) or ('pr', pr). kinds: human, follow, bot."""
        q = self.filter.lower()
        out = []
        if MINE:
            for kind, title in MINE_GROUPS:
                group = [p for p in self.prs if bucket(p) == kind
                         and (not q or q in f'{p["repo"]} {p["title"]} {p["who"]} {p["number"]}'.lower())]
                if group:
                    out.append(("head", f"{title} ({len(group)})", kind))
                    out += [("pr", p) for p in group]
            return out
        for kind, title in (("human", "Needs your review"), ("follow", "Reviewed by you"), ("bot", "Bots")):
            if kind == "bot" and self.hide_bots:
                continue
            group = [p for p in self.prs
                     if ("bot" if p["bot"] else "follow" if p.get("follow") else "human") == kind
                     and (not q or q in f'{p["repo"]} {p["title"]} {p["who"]} {p["number"]}'.lower())]
            if group:
                out.append(("head", f"{title} ({len(group)})", kind))
                out += [("pr", p) for p in group]
        return out


SESSION_RE = re.compile(r"^(review|analyze|comments|ci) (.+)#(\d+)$")
SESSION_WORD = {"working": "running", "blocked": "needs input", "idle": "done", "done": "done"}


def read_sessions():
    """{(repo, number): [(action, agent_status), ...]} from the herdr workspaces started by the buttons."""
    try:
        out = subprocess.run([os.environ.get("HERDR_BIN_PATH", "herdr"), "workspace", "list"],
                             capture_output=True, text=True, timeout=5, check=True).stdout
        spaces = json.loads(out)["result"]["workspaces"]
    except Exception:
        return None
    found = {}
    for ws in spaces:
        m = SESSION_RE.match(ws.get("label", ""))
        if m:
            found.setdefault((m.group(2), int(m.group(3))), []).append((m.group(1), ws.get("agent_status", "unknown")))
    return found


ACTION_NAMES = {"review": "review", "rereview": "re-review", "analyze": "analysis", "reply": "comment review", "ci": "CI investigation"}


def main(stdscr):
    os.environ.setdefault("ESCDELAY", "25")
    curses.curs_set(0)
    curses.use_default_colors()
    curses.mousemask(curses.ALL_MOUSE_EVENTS)
    curses.mouseinterval(0)
    for i, c in enumerate((curses.COLOR_CYAN, curses.COLOR_YELLOW, curses.COLOR_GREEN,
                           curses.COLOR_MAGENTA, curses.COLOR_RED, curses.COLOR_BLUE), start=1):
        curses.init_pair(i, c, -1)
    CYAN, YEL, GREEN, MAG, RED, _BLUE = (curses.color_pair(i) for i in range(1, 7))
    sel_ok = curses.COLORS >= 256
    if sel_ok:  # pair 10 = default foreground on grey; 11..16 = the six colours on grey
        curses.init_pair(10, -1, SEL_BG)
        for i, c in enumerate((curses.COLOR_CYAN, curses.COLOR_YELLOW, curses.COLOR_GREEN,
                               curses.COLOR_MAGENTA, curses.COLOR_RED, curses.COLOR_BLUE), start=1):
            curses.init_pair(10 + i, c, SEL_BG)
    DIM = curses.A_DIM
    stdscr.timeout(1000)
    st = State()
    st.refresh()
    next_refresh = time.time() + REFRESH

    def put(y, x, text, attr=0):
        h, w = stdscr.getmaxyx()
        if attr & SEL:
            attr &= ~SEL
            if sel_ok:
                attr = (attr & ~curses.A_COLOR) | curses.color_pair(10 + curses.pair_number(attr))
            else:
                attr |= curses.A_REVERSE
        if 0 <= y < h and x < w:
            try:
                stdscr.addnstr(y, x, text, max(0, w - x), attr)
            except curses.error:
                pass

    def draw_legend(y, width):
        """Coloured legend, grouped by meaning; trailing groups are dropped when the pane is narrow."""
        sep = ("  │  ", DIM)
        groups = [
            [("CI ", DIM | curses.A_BOLD), (I_OK, GREEN), (" pass  ", DIM), (I_X, RED), (" fail  ", DIM), (I_DOT, YEL), (" running", DIM)],
            [("review ", DIM | curses.A_BOLD), (I_UP, GREEN), (" approved  ", DIM), (I_CHG, RED), (" changes  ", DIM), (I_CIRC, DIM), (" pending", DIM)],
            [(I_COMMENT, YEL), (" open threads", DIM)],
            [(I_WARN, RED), (" conflict", DIM)],
        ]
        if MINE:
            groups.append([("names = requested reviewers", DIM)])
        x = 1
        for n, group in enumerate(groups):
            seg = ([sep] if n else []) + group
            need = sum(len(t) for t, _ in seg)
            if x + need > width - 2:
                break
            for text, attr in seg:
                put(y, x, text, attr)
                x += len(text)

    def layout():
        rows = st.rows()
        pr_idx = [i for i, r in enumerate(rows) if r[0] == "pr"]
        sel = next((i for i in pr_idx if rows[i][1]["url"] == st.sel_url), None)
        if sel is None and pr_idx:
            sel = pr_idx[0]
            st.sel_url = rows[sel][1]["url"]
        return rows, pr_idx, sel

    def move(delta):
        rows, pr_idx, sel = layout()
        if not pr_idx:
            return
        pos = pr_idx.index(sel) if sel in pr_idx else 0
        pos = max(0, min(len(pr_idx) - 1, pos + delta))
        st.sel_url = rows[pr_idx[pos]][1]["url"]

    def start(pr, action):
        """Start Claude on the PR in its own herdr workspace (see `review-queue --open URL ACTION`)."""
        subprocess.Popen([ENGINE, "--open", pr["url"], action], stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL, start_new_session=True)
        st.opened.add(pr["url"])
        st.flash(f'{ACTION_NAMES[action]} started: {pr["repo"]}#{pr["number"]}')

    def has_comments(pr):
        return bool(pr.get("threads")) or bool(pr.get("follow")) or pr.get("decision") == "CHANGES_REQUESTED"

    def open_review(pr):
        if MINE:  # my own PR: the primary action is whatever blocks it
            if pr.get("ci") in ("FAILURE", "ERROR"):
                start(pr, "ci")
            elif has_comments(pr):
                start(pr, "reply")
            else:
                browse(pr)
            return
        start(pr, "rereview" if pr.get("follow") else "review")

    def browse(pr):
        webbrowser.open(pr["url"])
        st.flash(f'opened in browser: {pr["repo"]}#{pr["number"]}')

    def copy_link(pr):
        try:
            subprocess.run(["xclip", "-selection", "clipboard"], input=pr["url"].encode(), timeout=3, check=True)
        except Exception:  # no xclip: ask the terminal to set the clipboard (OSC 52)
            import base64
            os.write(1, b"\x1b]52;c;" + base64.b64encode(pr["url"].encode()) + b"\x07")
        st.flash(f'link copied: {pr["repo"]}#{pr["number"]}')

    def perform(pr, action):
        if action == "browser":
            browse(pr)
        elif action == "copy":
            copy_link(pr)
        elif action == "review":
            open_review(pr)
        else:
            start(pr, action)

    def buttons(pr):
        """(action, icon, label, enabled, primary) for the selected PR."""
        ci_bad = pr.get("ci") in ("FAILURE", "ERROR")
        if MINE:
            return [("reply", I_REPLY, "Address comments", has_comments(pr), has_comments(pr) and not ci_bad),
                    ("ci", I_WRENCH, "Fix CI", ci_bad, ci_bad),
                    ("analyze", I_SEARCH, "Analyze", True, False),
                    ("browser", I_GLOBE, "Open on GitHub", True, False),
                    ("copy", I_COPY, "Copy link", True, False)]
        return [("rereview" if pr.get("follow") else "review", I_PLAY, "Re-review" if pr.get("follow") else "Review", True, True),
                ("analyze", I_SEARCH, "Analyze", True, False),
                ("reply", I_REPLY, "Address comments", bool(pr.get("threads")) or bool(pr.get("follow")), False),
                ("ci", I_WRENCH, "Fix CI", ci_bad, False),
                ("browser", I_GLOBE, "Open on GitHub", True, False),
                ("copy", I_COPY, "Copy link", True, False)]

    while True:
        h, w = stdscr.getmaxyx()
        rows, pr_idx, sel = layout()
        sel_pr = rows[sel][1] if sel is not None else None
        panel_h = PANEL_H if (sel_pr is not None and h >= 22) else 0
        body_h = max(1, h - 3 - panel_h)
        hot = []   # clickable button rectangles drawn this frame: (y, x0, x1, action)
        # keep selection visible
        if sel is not None:
            if sel < st.top:
                st.top = sel - 1 if sel > 0 and rows[sel - 1][0] == "head" else sel
            elif sel >= st.top + body_h:
                st.top = sel - body_h + 1
        st.top = max(0, min(st.top, max(0, len(rows) - body_h)))

        if time.time() - st.sessions_at > 2:
            found = read_sessions()
            if found is not None:
                st.sessions = found
            st.sessions_at = time.time()
        working = sum(1 for v in st.sessions.values() for _, a in v if a == "working")
        stdscr.erase()
        stdscr.timeout(120 if (st.loading or working) else 1000)
        bots = sum(1 for p in st.prs if p["bot"])
        nfollow = sum(1 for p in st.prs if p.get("follow") and not p["bot"])
        humans = len(st.prs) - bots - nfollow
        spin = SPIN[int(time.time() * 8) % len(SPIN)]
        state = f"{spin} refreshing" if st.loading else (f"{I_SYNC} {st.updated:%H:%M}" if st.updated else st.status)

        # title bar: icon + name on the left, badges on the right
        put(0, 0, " " * w, SEL)
        put(0, 1, f" {I_PR}  {'My pull requests' if MINE else 'Review queue'} ", curses.A_BOLD | SEL)
        counts = (f"{I_WARN} {sum(1 for p in st.prs if bucket(p) == 'attn')}  {I_PR} {len(st.prs)}" if MINE
                  else f"{I_USER} {humans}  {I_EYE} {nfollow}  {I_BOT} {bots}")
        right = (f" {spin} {working} running  " if working else " ") + f"{counts}   {state} "
        put(0, max(20, w - len(right) - 1), right, SEL)
        if st.error:
            put(1, 1, f"{I_WARN} {st.error} (showing the last list)", RED)
        elif st.filter or st.typing:
            put(1, 1, f"{I_FILTER} {st.filter}{'▏' if st.typing else ''}", YEL | curses.A_BOLD)
        elif st.hide_bots and not MINE:
            put(1, 1, f"{I_BOT} bots hidden (h to show)", DIM)
        elif st.legend:
            draw_legend(1, w)
        else:
            put(1, 1, "? legend", DIM)

        rw = min(24, max([len(p["repo"]) for p in st.prs] or [8]))
        aw = min(18, max([len(p["who"]) for p in st.prs] or [8]))
        for n, row in enumerate(rows[st.top: st.top + body_h]):
            y = 2 + n
            i = st.top + n
            if row[0] == "head":
                icon, col = {"bot": (I_BOT, MAG), "follow": (I_EYE, YEL), "attn": (I_WARN, RED), "ready": (I_OK, GREEN),
                             "wait": (I_EYE, DIM), "draft": (I_DRAFT, DIM)}.get(row[2], (I_USER, GREEN))
                label = f" {icon}  {row[1]} "
                put(y, 1, label, curses.A_BOLD | col)
                put(y, 1 + len(label), "─" * max(0, w - len(label) - 3), DIM)
                continue
            p = row[1]
            rev = SEL if i == sel else 0
            if rev:
                put(y, 0, " " * w, rev)
            secs = age_seconds(p["updatedAt"])
            age_attr = GREEN if secs < 3600 else (DIM if secs < 3 * 86400 else (YEL if secs < 7 * 86400 else RED))
            sess = st.sessions.get((p["repo"], p["number"]), [])
            states = [a for _, a in sess]
            if "working" in states:
                mark, mattr = spin, CYAN | curses.A_BOLD
            elif "blocked" in states:
                mark, mattr = "?", YEL | curses.A_BOLD
            elif sess:
                mark, mattr = I_OK, GREEN
            else:
                mark, mattr = (I_DRAFT, DIM) if p["isDraft"] else (I_PR, CYAN)
            put(y, 1, "▶" if i == sel else " ", GREEN | rev)
            put(y, 3, mark, mattr | rev)
            x = 6
            for text, attr in ((trunc(p["repo"], rw).ljust(rw), CYAN | curses.A_BOLD), (f'#{p["number"]}'.ljust(6), DIM),
                               (p["age"].rjust(3), age_attr)):
                put(y, x, text, attr | rev)
                x += len(text) + 2
            # status cluster: CI, review decision, unresolved threads, merge conflict
            if p.get("detail"):
                cg, ca = {"SUCCESS": (I_OK, GREEN), "FAILURE": (I_X, RED), "ERROR": (I_X, RED),
                          "PENDING": (I_DOT, YEL), "EXPECTED": (I_DOT, YEL)}.get(p.get("ci"), ("·", DIM))
                dg, da = {"APPROVED": (I_UP, GREEN), "CHANGES_REQUESTED": (I_CHG, RED),
                          "REVIEW_REQUIRED": (I_CIRC, DIM)}.get(p.get("decision"), (" ", DIM))
                put(y, x, cg, ca | rev)
                put(y, x + 2, dg, da | rev)
                if p.get("threads"):
                    put(y, x + 4, f'{I_COMMENT}{p["threads"]}', YEL | curses.A_BOLD | rev)
                if p.get("conflict"):
                    put(y, x + 8, I_WARN, RED | rev)
            x += 11
            who = trunc(p["who"], aw).ljust(aw)
            put(y, x, who, (DIM if p["bot"] else YEL) | rev)
            x += len(who) + 2
            # title: coloured conventional-commit prefix, dim ticket id at the end
            title = p["title"]
            ticket = ""
            m = TICKET_RE.search(title)
            if m:
                ticket, title = f" {m.group(1)}", title[: m.start()]
            m = PREFIX_RE.match(title)
            if m:
                pre = title[: m.end()]
                col = {"green": GREEN, "red": RED, "blue": curses.color_pair(6), "cyan": CYAN, "dim": DIM}.get(TYPE_ATTR.get(m.group(1), "dim"), DIM)
                put(y, x, pre, col | curses.A_BOLD | rev)
                x += len(pre)
                title = title[m.end():]
            if p.get("follow"):  # keep room for the "‹you requested changes›" tag at the end of the row
                reserve = 28 + len(ticket)
                title = trunc(title, max(12, w - x - reserve))
            put(y, x, title, curses.A_BOLD * (not p["bot"]) | rev)
            x += len(title)
            if ticket:
                put(y, x, ticket, MAG | rev)
                x += len(ticket)
            if p["isDraft"]:
                put(y, x, "  draft", DIM | rev)
                x += 7
            if p.get("follow"):
                tag = {"CHANGES_REQUESTED": "you requested changes", "COMMENTED": "you commented",
                       "APPROVED": "you approved"}.get(p.get("mine"), "")
                if p.get("new_commits"):
                    tag += (" · " if tag else "") + "new commits since"
                put(y, x, f"  ‹{tag}›", YEL | rev)
                x += len(tag) + 5
            if MINE:
                tags = []
                if p.get("ci") in ("FAILURE", "ERROR"):
                    tags.append(("CI failing", RED))
                if p.get("decision") == "CHANGES_REQUESTED":
                    tags.append(("changes requested", RED))
                if p.get("threads"):
                    tags.append((f'{p["threads"]} unresolved', YEL))
                if p.get("conflict"):
                    tags.append(("conflict", RED))
                if p.get("decision") == "APPROVED" and not needs_attention(p) and not p["isDraft"]:
                    tags.append(("approved", GREEN))
                for text, col in tags:
                    put(y, x, f"  [{text}]", col | curses.A_BOLD | rev)
                    x += len(text) + 5
            for action, status in sess:
                word = SESSION_WORD.get(status, status)
                col = CYAN if status == "working" else YEL if status == "blocked" else GREEN
                put(y, x, f"  [{action} {word}]", col | curses.A_BOLD | rev)
                x += len(action) + len(word) + 5
        if len(rows) > body_h:  # scrollbar
            thumb_h = max(1, body_h * body_h // len(rows))
            thumb_y = int((body_h - thumb_h) * st.top / max(1, len(rows) - body_h))
            for n in range(body_h):
                put(2 + n, w - 1, "█" if thumb_y <= n < thumb_y + thumb_h else "│", DIM)
        if not rows:
            msg = f"{spin}  loading…" if st.loading else (f"{I_OK}  nothing waiting for your review" if not st.filter else "no match")
            put(max(3, h // 2), max(2, (w - len(msg)) // 2), msg, DIM)

        if panel_h:
            py = h - 1 - panel_h
            ptag = " PR details "
            put(py, 0, "─" * w, DIM)
            put(py, 2, ptag, DIM | curses.A_BOLD)
            put(py + 1, 2, f"{I_PR}  ", CYAN)
            put(py + 1, 5, sel_pr["title"], curses.A_BOLD)
            put(py + 2, 2, f"{I_LINK}  ", DIM)
            put(py + 2, 5, sel_pr["url"], CYAN | curses.A_UNDERLINE)
            col = {"green": GREEN, "red": RED, "yellow": YEL, "dim": DIM}
            x = 2
            meta = [(f'{sel_pr["repo"]}#{sel_pr["number"]}', CYAN),
                    ((f'reviewers: {sel_pr["who"]}' if MINE else f'by {sel_pr["who"]}'), YEL), (f'updated {sel_pr["age"]} ago', DIM)]
            if sel_pr.get("detail"):
                if sel_pr.get("ci") in CI_TEXT:
                    t, c = CI_TEXT[sel_pr["ci"]]
                    meta.append((t, col[c]))
                if sel_pr.get("decision") in DECISION_TEXT:
                    t, c = DECISION_TEXT[sel_pr["decision"]]
                    meta.append((t, col[c]))
                if sel_pr.get("threads"):
                    meta.append((f'{sel_pr["threads"]} unresolved thread{"s" * (sel_pr["threads"] > 1)}', YEL | curses.A_BOLD))
                if sel_pr.get("conflict"):
                    meta.append(("merge conflict", RED | curses.A_BOLD))
            if sel_pr.get("follow"):
                meta.append(({"CHANGES_REQUESTED": "you requested changes", "COMMENTED": "you commented", "APPROVED": "you approved"}
                             .get(sel_pr.get("mine"), "reviewed by you") + (" · new commits since" if sel_pr.get("new_commits") else ""), YEL))
            for action, status in st.sessions.get((sel_pr["repo"], sel_pr["number"]), []):
                meta.append((f"{action}: {SESSION_WORD.get(status, status)}", {"working": CYAN, "blocked": YEL}.get(status, GREEN) | curses.A_BOLD))
            for text, attr in meta:
                put(py + 3, x, text, attr)
                x += len(text) + 3
            x = 2
            for action, icon, label, enabled, primary in buttons(sel_pr):
                text = f" {icon}  {label} "
                if enabled:
                    attr = (GREEN | curses.A_BOLD | curses.A_REVERSE) if primary else SEL
                    hot.append((py + 4, x, x + len(text), action))
                else:
                    attr = DIM | curses.A_UNDERLINE
                put(py + 4, x, text, attr)
                x += len(text) + 2

        # footer: highlighted keys; transient message wins for a few seconds
        put(h - 1, 0, " " * w, SEL)
        if st.msg and time.time() - st.msg_at < 4:
            put(h - 1, 1, f" {I_OK} {st.msg} ", GREEN | SEL | curses.A_BOLD)
        else:
            x = 1
            for key, label in (HINTS_MINE if MINE else HINTS):
                put(h - 1, x, f" {key} ", curses.A_BOLD | SEL)
                put(h - 1, x + len(key) + 2, f"{label} ", SEL | DIM)
                x += len(key) + len(label) + 4
        stdscr.refresh()

        if time.time() >= next_refresh:
            st.refresh()
            next_refresh = time.time() + REFRESH

        ch = stdscr.getch()
        if ch == -1:
            continue

        if st.typing:
            if ch in (10, 13):
                st.typing = False
            elif ch == 27:
                st.typing, st.filter = False, ""
            elif ch in (curses.KEY_BACKSPACE, 127, 8):
                st.filter = st.filter[:-1]
            elif 32 <= ch < 127:
                st.filter += chr(ch)
            continue

        if ch == curses.KEY_MOUSE:
            try:
                _, mx, my, _, bstate = curses.getmouse()
            except curses.error:
                continue
            idx = st.top + (my - 2)
            if bstate & curses.BUTTON1_PRESSED:
                hit = next((a for (hy, x0, x1, a) in hot if hy == my and x0 <= mx < x1), None)
                if hit and sel_pr:
                    perform(sel_pr, hit)          # CTA button
                elif 2 <= my < 2 + body_h and 0 <= idx < len(rows) and rows[idx][0] == "pr":
                    pr = rows[idx][1]
                    now = time.time()
                    st.sel_url = pr["url"]             # click selects: details + buttons appear below
                    if st.last_click[0] == pr["url"] and now - st.last_click[1] < 0.6:
                        browse(pr)                     # double-click opens the PR on GitHub
                        st.last_click = (None, 0.0)
                    else:
                        st.last_click = (pr["url"], now)
                elif panel_h and my == h - 1 - panel_h + 2 and sel_pr:
                    browse(sel_pr)                # click on the link line
            elif bstate & curses.BUTTON3_PRESSED and 2 <= my < 2 + body_h and 0 <= idx < len(rows) and rows[idx][0] == "pr":
                browse(rows[idx][1])
            elif bstate & curses.BUTTON4_PRESSED:
                move(-3)
            elif getattr(curses, "BUTTON5_PRESSED", 0) and bstate & curses.BUTTON5_PRESSED:
                move(3)
        elif ch in (ord("q"),):
            return
        elif ch in (curses.KEY_DOWN, ord("j")):
            move(1)
        elif ch in (curses.KEY_UP, ord("k")):
            move(-1)
        elif ch == curses.KEY_NPAGE:
            move(body_h)
        elif ch == curses.KEY_PPAGE:
            move(-body_h)
        elif ch in (curses.KEY_HOME, ord("g")):
            move(-10**6)
        elif ch in (curses.KEY_END, ord("G")):
            move(10**6)
        elif ch in (10, 13, ord("o")) and sel_pr:
            open_review(sel_pr)
        elif ch == ord("b") and sel_pr:
            browse(sel_pr)
        elif ch == ord("y") and sel_pr:
            copy_link(sel_pr)
        elif ch == ord("a") and sel_pr:
            start(sel_pr, "analyze")
        elif ch == ord("c") and sel_pr:
            if has_comments(sel_pr):
                start(sel_pr, "reply")
            else:
                st.flash("no unresolved comments on this PR")
        elif ch == ord("f") and sel_pr:
            if sel_pr.get("ci") in ("FAILURE", "ERROR"):
                start(sel_pr, "ci")
            else:
                st.flash("CI is not failing on this PR")
        elif ch in (ord("r"), 18):
            st.refresh()
            next_refresh = time.time() + REFRESH
        elif ch == ord("/"):
            st.typing = True
        elif ch == ord("?"):
            st.legend = not st.legend
        elif ch == ord("h"):
            st.hide_bots = not st.hide_bots
        elif ch == 27:
            st.filter = ""


if __name__ == "__main__":
    curses.wrapper(main)
