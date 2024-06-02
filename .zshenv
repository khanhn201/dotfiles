. "$HOME/.cargo/env"

# Paths and Env
typeset -U path PATH
path=(/usr/local/texlive/2024/bin/x86_64-linux $path)

export PATH

export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
export EDITOR="nvim"
