# zp

Personal prompt; largely wip and all manual config for now.

Looks like this.

```bash
./$(PWD) on $(git branch --show-current) >>
```

Then it's set with a zsh precmd

```zsh
function set_zp() {
    PROMPT="$(zp)"
}
[ ! "$TERM" = "linux" ] && precmd_functions+=(set_zp)
```
