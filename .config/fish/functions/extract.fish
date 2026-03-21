function extract
    if test -f $argv
        switch $argv
            case "*.tar.gz"
                tar -xzf $argv
            case "*.tar.bz2"
                tar -xjf $argv
            case "*.zip"
                unzip $argv
            case "*.rar"
                unrar x $argv
            case "*.7z"
                7z x $argv
            case "*"
                echo "Không hỗ trợ file này"
        end
    end
end
