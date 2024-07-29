
# Paths and Env
typeset -U path PATH
path=(/usr/local/texlive/2024/bin/x86_64-linux $path)
path=(/home/nekoconn/qemu/ $path)

export PATH

export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
export EDITOR="nvim"

# nnn
export NNN_FIFO=/tmp/nnn.fifo
export NNN_OPENER=/home/nekoconn/.config/nnn/plugins/nuke
export NNN_PLUG='v:preview-tabbed'
. "$HOME/.cargo/env"
