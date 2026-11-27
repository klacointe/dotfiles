# pinned-spaces

A herdr plugin that brings back cockpit's pinned spaces (inbox, terminal, dotfiles, ...) when one disappears
because its last pane exited.

## Why it exists

Cockpit recreates a pinned space when herdr sends `workspace.closed`. herdr 0.9.5 only sends that event for an
explicit close (`herdr workspace close`, or closing the space from the UI). When a space goes away because you
exited its agents and shells one by one, herdr sends `pane.exited`, but no `workspace.closed`, `tab.closed` or
`pane.closed`. Cockpit never hears about it, and the space stays gone until something else makes cockpit check again (a herdr
restart, or an explicit close of another space).

Upstream issue: https://github.com/herdrdev/herdr/issues/6234

## How it works

`check.sh` runs on two events:

| Event | When it matters |
|---|---|
| `tab.focused` | The emptied space was in view: herdr moves the focus to another space. |
| `pane.exited` | The emptied space was out of view, so no focus moves. `check.sh` waits 1s first, since the event can arrive before herdr removes the space. |

Each run lists the workspaces once and stops there when every pinned space exists, which is the usual case. The
pinned spaces come from cockpit's config (`~/.cache/cockpit/config.json`, else `~/.config/cockpit/config.json`),
matched by cockpit's label, `<icon>  <name>`.

When one is missing, it runs cockpit's own `~/.config/cockpit/herdr/ensure-spaces.sh`, which recreates it in its
configured directory. To avoid creating the same space twice when cockpit's hook is already doing it (an explicit
close), it:

- takes a lock, so a burst of events gives a single run;
- waits up to 10s for a running cockpit `ensure-spaces.sh` to finish;
- waits 2s more, checks again, and only then runs `ensure-spaces.sh`.

## Install

`make symlinks` links it with the other local plugins (`herdr plugin link ~/dotfiles/herdr/plugins/pinned-spaces`).
After changing `herdr-plugin.toml`, run that link command again to reload the events.

## When to remove it

Once herdr sends `workspace.closed` for a space whose last pane exited, cockpit's own hook covers this and the
plugin can go: unlink it (`herdr plugin unlink wttj.pinned-spaces`), delete this folder and its line in the
Makefile.
