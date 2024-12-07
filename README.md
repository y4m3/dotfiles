# dotfiles

- [basic tools for ubuntu](#basic-tools-for-ubuntu)
- [basic setting](#basic-setting)
- [apps](#apps)
    - [starship](#starship)
    - [mise](#mise)
    - [pipx](#pipx)
    - [neovim](#neovim)
    - [fzf](#fzf)
    - [cargo](#cargo)
    - [wsl environment](#wsl-environment)
- [bash configuration](#bash-configuration)
- [dev](#dev)

## basic tools for ubuntu

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    bzip2 \
    cmake \
    curl \
    fzf \
    git \
    grep \
    htop \
    jq \
    luarocks \
    net-tools \
    openssh-server \
    pipx \
    rsync \
    sed \
    tar \
    tmux \
    tree \
    unzip \
    vim \
    wget \
    zip
```

## basic setting

```bash
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
```

## apps

### starship

- [starship](https://starship.rs/guide/)
    - `curl -sS https://starship.rs/install.sh | sh`

### mise

- [mise](https://github.com/jdx/mise)

### pipx

- [pipx](https://github.com/pypa/pipx)

add path

```bash
sudo pipx ensurepath
```

install with pipx

```bash
pipx install \
    pre-commit \
    ruff \
    sqlfluff \
    trash-cli
```

- [pre-commit](https://pre-commit.com/)
- [ruff](https://github.com/astral-sh/ruff)
- [sqlfluff](https://github.com/sqlfluff/sqlfluff)
- [trash-cli](https://github.com/andreafrancia/trash-cli)

### neovim

before run neovim at first time, you need to install nodejs and python3

1. `mise use node python`
2. `npm install -g neovim prettier`
3. `pip install pynvim`

then install [neovim](https://github.com/neovim/neovim/blob/master/INSTALL.md#linux)

### fzf

- [fzf-tab-completion](https://github.com/lincheney/fzf-tab-completion)

```bash
git clone https://github.com/lincheney/fzf-tab-completion.git ~/.fzf-tab-completion
```

### cargo

install cargo

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

install with cargo

```bash
cargo install --locked \
  bat \
  eza \
  fd-find \
  ripgrep \
  stylua \
  zellij \
  zoxide
```

### wsl environment

- [win32yank](https://github.com/equalsraf/win32yank)

```bash
wget https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
unzip win32yank-x64.zip -d win32yank
cd win32yank
chmod +x win32yank.exe
sudo mv win32yank.exe /usr/local/bin/win32yank.exe
```

- wl-clipboard
    - `sudo apt install wl-clipboard`
- wslview
    - `sudo apt install wslu`

## bash configuration

Add the following line to your `~/.bashrc` to source `~/dotfiles/.bashrc.local`:

```bash
source ~/dotfiles/.bashrc.local
```

## dev

install gh cli

- [gh](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)

install markdown linter

- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)

```bash
npm install -g markdownlint-cli2
```

pre-commit

```bash
pre-commit install
```
