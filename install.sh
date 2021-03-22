#!/usr/bin/env bash
#--------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------
#
source "setup/zsh.sh"

args=$1
echo "Script called with \"${args}\""

function brew_install() {
    echo "Running brew bundle"
    brew bundle --file=brew/Brewfile
    echo "Finished running brew"
}

case $args in
brew)
    brew_install
    ;;

zsh)
    echo "Running zsh"
    install_zsh
    stow zsh
    ;;

git)
    echo "Running git"
    stow git
    ;;

*)
    echo "running full script"
    brew_install
    install_zsh
    stow zsh
    stow git
    ;;
esac
