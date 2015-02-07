# Setup

First install package `sudo` as `root` and add group `sudo` to your `user`.

```bash
git clone https://github.com/klacointe/dotfiles
make install
```

## Install Vim plugins

```bash
:PlugInstall
```

## Install Go dependencies

```bash
go get github.com/mattn/gom
go get github.com/bradfitz/goimports
```
