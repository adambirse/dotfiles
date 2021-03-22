#!/usr/bin/env bash
#--------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------
#

ZSH=~/.oh-my-zsh
ZSH_CUSTOM=$ZSH/custom

function install_plugin() {

  if [[ ! -d "${ZSH_CUSTOM}/plugins/$1" ]]; then
    echo "Installing plugin $1 from $2"
    git clone "$2" "${ZSH_CUSTOM}/plugins/$1"
  fi
}

function install_zsh() {

  if [[ ! -d ${ZSH} ]]; then
    echo "installing oh my zsh"
    #
    # oh my zsh is installed by cloning repo. References to
    # oh my zsh are in the .zshrc dotfile. This is instead of the
    # default install script since it is more focussed, but is
    # effectively the same thing.
    #
    git clone -c core.eol=lf -c core.autocrlf=false \
      -c fsck.zeroPaddedFilemode=ignore \
      -c fetch.fsck.zeroPaddedFilemode=ignore \
      -c receive.fsck.zeroPaddedFilemode=ignore \
      --depth=1 --branch "master" \
      "https://github.com/ohmyzsh/ohmyzsh.git" "$ZSH"
  fi

  install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
  install_plugin "zsh-better-npm-completion" "https://github.com/lukechilds/zsh-better-npm-completion"
}
