# https://github.com/eza-community/eza
# zshとbashの両方で動作するようにコマンド存在確認
if command -v eza > /dev/null 2>&1; then
    # Define LS_COLORS based on the Hacker theme palette (terminal.ansi* colors)
    # Using RGB colors (requires compatible terminal)
    HACKER_FG="38;2;124;220;135" # foreground: #7CDC87
    HACKER_GREEN="38;2;64;187;64"   # terminal.ansiGreen: #40BB40
    HACKER_GREEN_BRIGHT="38;2;112;187;112" # terminal.ansiBrightGreen: #70BB70
    HACKER_YELLOW="38;2;170;170;48"  # terminal.ansiYellow: #AAAA30
    HACKER_RED="38;2;170;51;51"    # terminal.ansiRed: #AA3333
    HACKER_CYAN="38;2;64;181;181"   # terminal.ansiCyan: #40B5B5
    HACKER_BLUE="38;2;96;156;173"   # terminal.ansiBlue: #609CAD
    HACKER_COMMENT="38;2;80;112;80"  # terminal.ansiBrightBlack: #507050 (Used for less important things)

    # Simplified LS_COLORS definition using corrected colors - zsh compatible format
    export LS_COLORS=""
    LS_COLORS+="fi=${HACKER_FG}:"                  # Default file
    LS_COLORS+="di=1;${HACKER_GREEN_BRIGHT}:" # Directory
    LS_COLORS+="ex=1;${HACKER_GREEN}:"        # Executable
    LS_COLORS+="ln=1;${HACKER_CYAN}:"         # Symbolic link
    LS_COLORS+="or=1;${HACKER_RED}:"          # Orphan link
    LS_COLORS+="mi=1;${HACKER_RED}:"          # Missing file
    LS_COLORS+="so=1;${HACKER_YELLOW}:"       # Socket
    LS_COLORS+="pi=1;${HACKER_YELLOW}:"       # Pipe
    LS_COLORS+="bd=1;${HACKER_YELLOW}:"       # Block device
    LS_COLORS+="cd=1;${HACKER_YELLOW}:"       # Character device
    # Git status (Matches theme gitDecoration colors where possible)
    LS_COLORS+="ga=1;${HACKER_GREEN}:"        # Added (Matches untrackedResourceForeground)
    LS_COLORS+="gm=1;${HACKER_YELLOW}:"       # Modified (Matches modifiedResourceForeground)
    LS_COLORS+="gd=1;${HACKER_RED}:"          # Deleted (Matches deletedResourceForeground)
    LS_COLORS+="gv=1;${HACKER_CYAN}:"         # Renamed
    LS_COLORS+="gt=1;${HACKER_CYAN}:"         # Type changed

    # Aliases using eza
    alias ls="eza --icons --git"
    alias la="eza -a --icons --git"
    alias lt="eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons"
    alias lta="eza -T -a -I 'node_modules|.git|.cache' --color=always --icons | less -r"
    alias l="clear && ls"
else
    # Fallback aliases if eza is not found
    alias ll='ls -l'
    alias la='ls -la'
fi
