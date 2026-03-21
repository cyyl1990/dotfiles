function fish_user_key_bindings

    # Ctrl + R -> fzf history search
    bind \cr 'history | fzf | read -l cmd; commandline $cmd'

    # Ctrl + F -> tìm file
    bind \cf 'fd . | fzf | read -l file; commandline $file'

end	
