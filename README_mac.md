# Mac

only for mac

## terminal

```zsh
xcode-select --install
```

install Homebrew

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

add path

```zsh
echo >> /Users/dummy/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/dummy/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

install apps with Homebrew

```zsh
brew install \
    cmake \
    curl \
    fzf \
    gh \
    git \
    gnu-sed \
    grep \
    htop \
    jq \
    luarocks \
    neovim \
    openssh \
    pipx \
    rsync \
    tmux \
    tree \
    unzip \
    vim \
    wget \
    zip
```

## fzf

activate completion and key bindings

```zsh
$(brew --prefix)/opt/fzf/install
```

install fzf-tab

```zsh
git clone https://github.com/Aloxaf/fzf-tab ~/.fzf-tab
```

## zsh configuration

Add the following line to your `~/.zshrc` to source `~/dotfiles/.zshrc.local`:

```bash
source ~/dotfiles/.zshrc.local
```

## app binary

- [bartender](https://www.macbartender.com)
- [battery](https://github.com/actuallymentor/battery)
- [hammerspoon](https://www.hammerspoon.org)
- [karabiner-elements](https://karabiner-elements.pqrs.org)
- [raycast](https://www.raycast.com)
- [rectangle](https://rectangleapp.com)
- [visual studio code](https://code.visualstudio.com)

```zsh
brew install \
    bartender \
    battery \
    hammerspoon \
    karabiner-elements \
    raycast \
    rectangle \
    visual-studio-code \
```

You need to start a background service. The service name will be displayed after installation.

```zsh
brew service start {service name ...}
```
