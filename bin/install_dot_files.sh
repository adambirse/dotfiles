#!/usr/bin/env bash
DOTFILES=~/dotfiles/dotfiles

function stow_package() {
    package=$1
    echo "Stowing ${package}"
    cd $DOTFILES
    stow -t $HOME $package

}

function stow_all() {
    cd $DOTFILES
    for DIR in $(ls -d */); do
        # Remove last character (/)
        package=$(echo "$DIR" | sed 's/.$//')
        echo "Stowing ${package}"
        stow -t $HOME $package
    done

}
