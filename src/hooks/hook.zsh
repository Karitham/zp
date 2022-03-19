export ZP_SHELL="zsh"

function set_zp() {
    PROMPT="$(zp prompt)"
}

precmd_functions+=(set_zp)
