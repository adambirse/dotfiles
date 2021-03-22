#!/usr/bin/env bash
DOTFILES=~/dotfiles/dotfiles

function stow_package() {
    package=$1
    echo "Stowing ${package}"
    cd $DOTFILES
    stow -t $HOME $package

}

function stow_all() {
    #TODO loop through DOTFILES directory.
    stow_package zsh
    stow_package git

}
