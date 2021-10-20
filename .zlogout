if [[ $(find "~/Brewfile" -mtime +7 -print) ]]; then
    echo "Brewfile hasn't been updated in 7 days, syncing"
    brew bundle dump --force --file=~/Brewfile
fi
