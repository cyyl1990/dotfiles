function ff
    set file (find . | fzf)
    if test -n "$file"
        echo $file
    end
end
