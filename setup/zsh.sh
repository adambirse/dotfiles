#!/usr/bin/env bash
#--------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------
#


ZSH=~/.oh-my-zsh

if [[ ! -d ${ZSH} ]] ; then
echo "installing oh my zsh"
  #
  # oh my zsh is installed by cloning repo. References to 
  # oh my zsh are in the .zshrc dotfile. This is instead of the
  # default install script since it is more focussed, but is 
  # effectively the same thing.
  #
  git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore             \
    -c fetch.fsck.zeroPaddedFilemode=ignore       \
    -c receive.fsck.zeroPaddedFilemode=ignore     \
    --depth=1 --branch "master"                   \
    "https://github.com/ohmyzsh/ohmyzsh.git" "$ZSH"
fi