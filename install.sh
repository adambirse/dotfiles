#!/usr/bin/env bash
#--------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------
#

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

zsh )
    echo  "Running zsh"
    stow zsh
    ;;

*)
    echo "running full script"
    brew_install
    stow zsh
    ;;
esac
