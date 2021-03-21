#!/usr/bin/env bash
#--------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------
#

source "zsh/install/install.sh"

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
    zsh_install
    ;;

*)
    echo "running full script"
    brew_install
    zsh_install
    ;;
esac
