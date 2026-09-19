# Setup

```sh
sudo lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description: Ubuntu 24.04.1 LTS
Release: 24.04
Codename: noble
```

## Install packages

```sh
sudo apt install make gcc g++ git curl
```

Optional:

```sh
sudo apt install htop gnome-tweaks parcellite pulseaudio-utils inotify-tools tig
```

## Parcellite (optional)

Enable these options:

- Use Primary (Selection)
- Synchronize clipboards

## Fonts

```sh
ln -s /home/klacointe/dotfiles/fonts /home/klacointe/.fonts
fc-cache -fv
```

Links:

- <https://www.nerdfonts.com/font-downloads>

## Git

```sh
ln -s /home/klacointe/dotfiles/gitconfig /home/klacointe/.gitconfig
```

## Retrieve config files

```sh
git clone git@github.com:klacointe/dotfiles
```

## Secrets

This repo is **public**. Nothing secret goes in it. Four layers make that hold,
and the first thing to do after a fresh clone is to arm the local two:

```sh
make secrets_setup   # installs gitleaks into ~/bin + enables the git hooks
```

`core.hooksPath` is local git config, so it is not carried by the clone — that
`make` target has to be run on every machine.

### The layers

| Layer | What it does | Where |
| --- | --- | --- |
| `.gitignore` | Keeps credential files from being picked up by `git add .` | `.gitignore` |
| `pre-commit` | Blocks the commit if gitleaks finds a secret in the index | `githooks/pre-commit` |
| `pre-push` | Blocks the push if a secret is in the outgoing commits | `githooks/pre-push` |
| GitHub | Secret scanning + push protection, rejects the push server-side | repo settings |
| CI | Full-history gitleaks scan on every push and weekly | `.github/workflows/gitleaks.yml` |

The local hooks fail closed: no gitleaks binary means no commit and no push.
GitHub's push protection and the CI job are the backstop for anything pushed
with `--no-verify`, from another machine, or by another git client.

### Where sensitive values go instead

Not in this repo. Either in the tool's own credential store outside the repo
(`~/.aws/credentials`, `~/.netrc`, the keyring), or in a file that stays local:
anything named `*.local` or placed under `private/` is gitignored. Reference it
from a versioned config rather than inlining the value — the way `zsh/env.zsh`
reads AWS keys through `aws configure get` instead of hardcoding them.

### Scanning by hand

```sh
make scan            # working tree, including untracked files
make scan_history    # the whole history
```

### If a secret does get pushed

Rotate it first, rewrite history second. Once it has reached a public repo,
assume it is already scraped — rewriting the history does not un-leak it, and
forks, caches and the GitHub events API keep copies.

1. **Rotate the credential immediately.** This is the only step that matters.
2. Remove it from the history (`git filter-repo`), then force-push.
3. Ask GitHub Support to flush cached views of the old commits if it was
   high-value.

### Known false positive

`tmux/plugins/tmux-copycat/docker_ssh.key` is a throwaway test key vendored
from upstream in 2015. It is allowlisted in `.gitleaks.toml` and grants access
to nothing.

## X

```sh
ln -s /home/klacointe/dotfiles/Xsession  /home/klacointe/.Xsession
ln -s /home/klacointe/dotfiles/Xdefaults  /home/klacointe/.Xdefaults
ln -s /home/klacointe/dotfiles/setxkbmaprc /home/klacointe/.setxkbmaprc
```

## Terminal & Shell

```sh
sudo apt install zsh tmux

curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

sudo ln -s /home/klacointe/.local/kitty.app/bin/kitty /usr/bin/
sudo ln -s /home/klacointe/.local/kitty.app/bin/kitten /usr/bin/

ln -s /home/klacointe/dotfiles/kitty /home/klacointe/.config/kitty

ln -s /home/klacointe/dotfiles/zsh/zshrc /home/klacointe/.zshrc
ln -s /home/klacointe/dotfiles/zsh /home/klacointe/.zsh

ln -s /home/klacointe/dotfiles/tmux/tmux.conf /home/klacointe/.tmux.conf

sudo usermod -s /bin/zsh klacointe

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## Languages

Download asdf bin from <https://github.com/asdf-vm/asdf/releases>

Add this to ~/.zsh/zshrc

```sh
export PATH="${ASDF_DATA_DIR:-HOME/.asdf}/shims:$PATH"
```

```sh
asdf plugin add erlang
asdf install erlang latest
asdf global erlang latest

asdf plugin add elixir
asdf install elixir latest
asdf global elixir latest

asdf plugin add nodejs
asdf install nodejs latest
asdf global nodejs latest

sudo apt install zlib1g libffi-dev libyaml-dev libpq-dev
asdf plugin add ruby
asdf install ruby latest
asdf global ruby latest
```

## Neovim

You'll need Neovim >= 0.10

```sh
sudo apt install fzf luarocks ripgrep fd-find python3-venv
npm install markdownlint-cli2 --global
```

```sh
sudo snap install nvim --classic
ln -s /home/klacointe/dotfiles/nvim /home/klacointe/.config/nvim
```

## Window Manager

### i3

```sh
sudo apt install i3 flameshot blueman pavucontrol xcalib
ln -s /home/klacointe/dotfiles/i3 /home/klacointe/.config/i3
```

## Social

```sh
sudo snap install telegram-desktop
sudo snap install discord
sudo snap install slack
```

## Nginx

```sh
sudo apt install nginx-extras
```

## Databases

### Postgres

```sh
sudo apt install postgresql
```

```sh
sudo su postgres
psql
postgres=# ALTER USER postgres with encrypted password 'my-password';
```

```sh
sudo nvim /etc/postgresql/16/main/pg_hba.conf

local   all             postgres                                trust
```

```sh
sudo systemctl restart postgres
psql -U postres
```

### Redis

```sh
sudo apt install redis
redis-cli
```

## Games

### Steam

```sh
sudo snap install steam
```

### Steam Link :x:

```sh
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.valvesoftware.SteamLink
flatpak run com.valvesoftware.SteamLink
```

```
cat /usr/local/bin/steamlink
#!/bin/sh

flatpak run com.valvesoftware.SteamLink
```

### yuki-iptv

```sh
sudo apt install flatpak
flatpak install flathub yuki-iptv
flatpak run io.github.yuki_iptv.yuki-iptv
```

```
cat /usr/local/bin/yuki-iptv
#!/bin/sh

flatpak run io.github.yuki_iptv.yuki-iptv
```

### IPTVnator

Install the native `.deb` — **not** the snap. The snap is strictly confined, so
AppArmor denies the exec and external players (MPV/VLC) never start.

```sh
make install_iptvnator
```

The script installs the latest release, migrates data from the snap if it finds
any, enables the embedded-MPV frame-copy engine (required for the embedded
player on Wayland) and installs the menu entry.

#### Re-create the Xtream playlist

The database is **not versioned**: it stores the Xtream credentials in clear
text. Re-create the playlist by hand instead — it takes a minute:

1. **Add playlist** → **Xtream Codes** tab
2. Fill in **Playlist title**, **Server URL** (`http://host:port`, no trailing
   path), **Username**, **Password**
3. Submit, then let the import finish — live, movies and series are fetched
   separately and the UI stays partly empty until each completes

Then pick a player that can actually decode the streams:

- **Settings** → **Video player** → **Embedded MPV** (or **MPV** for an
  external window). The default `Video.js` fails on most provider codecs.

Local data, for reference:

```sh
~/.iptvnator/databases/iptvnator.db   # playlists, EPG, favourites (credentials!)
~/.config/IPTVnator/config.json       # player paths, frame-copy flag
~/.config/IPTVnator/IndexedDB/        # UI settings (player, language, theme)
~/.config/IPTVnator/Cache/            # disposable, grows to >1 GB
```
