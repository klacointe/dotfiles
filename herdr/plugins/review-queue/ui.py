#!/usr/bin/env python3
"""Review queue TUI (stdlib curses, no dependencies).

Open WTTJ PRs awaiting my review, humans first then bots, grouped by repo.
Mouse: click selects, click again (or double-click) starts a review, right-click
opens the PR in the browser, wheel scrolls. Keyboard: see FOOTER.
Reviews are started by the sibling `review-queue --open URL` (herdr workspace).
"""
import curses
import json
import os
import subprocess
import threading
import time
import webbrowser
from datetime import datetime, timezone

OWNER = os.environ.get("REVIEW_QUEUE_OWNER", "WTTJ")
REFRESH = int(os.environ.get("REVIEW_QUEUE_REFRESH", "300"))
HERE = os.path.dirname(os.path.realpath(__file__))
ENGINE = os.path.join(HERE, "review-queue")
CACHE = os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "review-queue.json")
FOOTER = " ↑↓/jk move · Enter/click-again open review · b/right-click browser · / filter · h bots · r refresh · q quit "
FIELDS = "repository,number,title,author,url,updatedAt,isDraft"


def age(iso):
    t = datetime.fromisoformat(iso.replace("Z", "+00:00"))
    s = (datetime.now(timezone.utc) - t).total_seconds()
    if s < 3600:
        return f"{int(s // 60)}m"
    if s < 86400:
        return f"{int(s // 3600)}h"
    return f"{int(s // 86400)}d"


def trunc(s, n):
    return s if len(s) <= n else s[: n - 1] + "…"


def fetch():
    out = subprocess.run(
        ["gh", "search", "prs", "--review-requested=@me", "--state=open", f"--owner={OWNER}",
         "--limit", "100", "--json", FIELDS],
        capture_output=True, text=True, timeout=60, check=True,
    ).stdout
    prs = json.loads(out)
    for p in prs:
        login = p["author"]["login"]
        p["bot"] = bool(p["author"].get("is_bot")) or login.endswith("[bot]")
        p["who"] = login.removesuffix("[bot]")
        p["repo"] = p["repository"]["name"]
        p["age"] = age(p["updatedAt"])
    prs.sort(key=lambda p: (p["bot"], p["repo"], p["number"]))
    return prs


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
                self.prs = fetch()
                self.error = None
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
        """Visible rows: ('head', text, color) or ('pr', pr)."""
        q = self.filter.lower()
        out = []
        for bot in (False, True):
            if bot and self.hide_bots:
                continue
            group = [p for p in self.prs if p["bot"] == bot
                     and (not q or q in f'{p["repo"]} {p["title"]} {p["who"]} {p["number"]}'.lower())]
            if group:
                out.append(("head", f'{"Bots" if bot else "Humans"} ({len(group)})', "bot" if bot else "human"))
                out += [("pr", p) for p in group]
        return out


def main(stdscr):
    os.environ.setdefault("ESCDELAY", "25")
    curses.curs_set(0)
    curses.use_default_colors()
    curses.mousemask(curses.ALL_MOUSE_EVENTS)
    curses.mouseinterval(0)
    for i, c in enumerate((curses.COLOR_CYAN, curses.COLOR_YELLOW, curses.COLOR_GREEN,
                           curses.COLOR_MAGENTA, curses.COLOR_RED), start=1):
        curses.init_pair(i, c, -1)
    CYAN, YEL, GREEN, MAG, RED = (curses.color_pair(i) for i in range(1, 6))
    DIM = curses.A_DIM
    stdscr.timeout(1000)
    st = State()
    st.refresh()
    next_refresh = time.time() + REFRESH

    def put(y, x, text, attr=0):
        h, w = stdscr.getmaxyx()
        if 0 <= y < h and x < w:
            try:
                stdscr.addnstr(y, x, text, max(0, w - x), attr)
            except curses.error:
                pass

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

    def open_review(pr):
        subprocess.Popen([ENGINE, "--open", pr["url"]], stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL, start_new_session=True)
        st.opened.add(pr["url"])
        st.flash(f'review started: {pr["repo"]}#{pr["number"]}')

    def browse(pr):
        webbrowser.open(pr["url"])
        st.flash(f'opened in browser: {pr["repo"]}#{pr["number"]}')

    while True:
        h, w = stdscr.getmaxyx()
        rows, pr_idx, sel = layout()
        body_h = max(1, h - 3)
        # keep selection visible
        if sel is not None:
            if sel < st.top:
                st.top = sel - 1 if sel > 0 and rows[sel - 1][0] == "head" else sel
            elif sel >= st.top + body_h:
                st.top = sel - body_h + 1
        st.top = max(0, min(st.top, max(0, len(rows) - body_h)))

        stdscr.erase()
        humans = sum(1 for p in st.prs if not p["bot"])
        state = "⟳ loading…" if st.loading else (f"updated {st.updated:%H:%M}" if st.updated else st.status)
        put(0, 0, " Review queue ", curses.A_BOLD | curses.A_REVERSE)
        put(0, 15, f"{humans} human · {len(st.prs) - humans} bot   {state}", DIM)
        if st.error:
            put(0, max(15, w - len(st.error) - 2), st.error, RED)
        flt = f" filter: {st.filter}{'▏' if st.typing else ''}" if (st.filter or st.typing) else ""
        put(1, 0, flt or (" bots hidden" if st.hide_bots else ""), YEL if flt else DIM)

        rw = min(24, max([len(p["repo"]) for p in st.prs] or [8]))
        aw = min(18, max([len(p["who"]) for p in st.prs] or [8]))
        for n, row in enumerate(rows[st.top: st.top + body_h]):
            y = 2 + n
            i = st.top + n
            if row[0] == "head":
                put(y, 1, row[1], curses.A_BOLD | (MAG if row[2] == "bot" else GREEN))
                continue
            p = row[1]
            rev = curses.A_REVERSE if i == sel else 0
            if rev:
                put(y, 0, " " * w, rev)
            mark = "✓" if p["url"] in st.opened else " "
            put(y, 1, mark, GREEN | rev)
            x = 3
            for text, attr in ((trunc(p["repo"], rw).ljust(rw), CYAN), (f'#{p["number"]}'.ljust(6), DIM),
                               (p["age"].ljust(4), DIM), (trunc(p["who"], aw).ljust(aw), DIM if p["bot"] else YEL)):
                put(y, x, text, attr | rev)
                x += len(text) + 1
            put(y, x, p["title"] + ("  [draft]" if p["isDraft"] else ""), rev)
        if not rows:
            put(3, 2, "No PR waiting for your review." if not st.filter else "No match.", DIM)

        footer = st.msg if st.msg and time.time() - st.msg_at < 4 else FOOTER
        put(h - 1, 0, footer.ljust(w), DIM | curses.A_REVERSE if footer is FOOTER else GREEN)
        stdscr.refresh()

        if time.time() >= next_refresh:
            st.refresh()
            next_refresh = time.time() + REFRESH

        ch = stdscr.getch()
        if ch == -1:
            continue
        sel_pr = rows[sel][1] if sel is not None else None

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
            if bstate & curses.BUTTON1_PRESSED and 2 <= my < 2 + body_h and 0 <= idx < len(rows) and rows[idx][0] == "pr":
                pr = rows[idx][1]
                now = time.time()
                again = st.last_click[0] == pr["url"] and now - st.last_click[1] < 5
                st.sel_url = pr["url"]
                st.last_click = (pr["url"], now)
                if again:
                    open_review(pr)
                    st.last_click = (None, 0.0)
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
        elif ch in (ord("r"), 18):
            st.refresh()
            next_refresh = time.time() + REFRESH
        elif ch == ord("/"):
            st.typing = True
        elif ch == ord("h"):
            st.hide_bots = not st.hide_bots
        elif ch == 27:
            st.filter = ""


if __name__ == "__main__":
    curses.wrapper(main)
