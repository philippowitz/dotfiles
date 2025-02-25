_gen_fzf_default_opts() {
  local fg_main="#000000"
  local bg_hl_line="#d0d6ec"
  local blue="#3548cf"
  local yellow="#6f5500"

  ## Modus Operandi
  setenv FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS"
   --color fg:-1,bg:-1,hl:$blue,fg+:$fg_main,bg+:$bg_hl_line,hl+:$blue,info:$yellow,prompt:$yellow,pointer:$fg_main,marker:$fg_main,spinner:$yellow,gutter:-1
  "
}
_gen_fzf_default_opts
