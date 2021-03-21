#!/usr/bin/env bash
#--------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------
#

working_dir="$(pwd)/zsh"

function zsh_install() {
    echo "Installing zsh"
    ln -s "${working_dir}/.aliases" ~/.aliases
    ln -s "${working_dir}/.zshrc" ~/.zshrc
    echo "Installed zsh"
}
