#function setenv
#    if [ $argv[1] = PATH ]
#        # Replace colons and spaces with newlines
#        set -gx PATH (echo $argv[2] | tr ': ' \n)
#    else
#        set -gx $argv
#    end
# end
#
#source ~/.env

fenv source ~/.profile

if status is-interactive

    set -g hydro_symbol_start ' '
    set -g hydro_multiline true
    set -g hydro_fetch false
    set -g fish_prompt_pwd_dir_length nil
    set -g fish_greeting
    set -g hydro_symbol_git_ahead '↑ '
    set -g hydro_symbol_git_behind '↓ '
    fzf --fish | source
    zoxide init fish | source
end


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/phil/miniforge3/bin/conda
    eval /home/phil/miniforge3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/phil/miniforge3/etc/fish/conf.d/conda.fish"
        . "/home/phil/miniforge3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/phil/miniforge3/bin" $PATH
    end
end
# <<< conda initialize <<<

