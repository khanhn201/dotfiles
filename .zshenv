
# Paths and Env
typeset -U path PATH
path=(/usr/local/texlive/2024/bin/x86_64-linux $path)
path=(/home/nekoconn/qemu/bin $path)
path=(/home/nekoconn/code/seal/Nek5000/bin $path)
path=(/usr/local/visit/bin/ $path)

export PATH

export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
export EDITOR="nvim"

export NEK_SOURCE_ROOT="/home/nekoconn/code/seal/Nek5000"

# nnn
export NNN_FIFO=/tmp/nnn.fifo
export NNN_OPENER=/home/nekoconn/.config/nnn/plugins/nuke
export NNN_PLUG='v:preview-tabbed'
. "$HOME/.cargo/env"
