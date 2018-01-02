#!/bin/sh

# Script to fix $ `npm i -g <package>` installations without root access.
# Written by Github user glenpike; inlcuded in my personal dotfiles repo
# for convenience. - Nefari0uss

# Licensed under the MIT License which is included below:
# Copyright (c) 2014 Glen Pike
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

usage() {
cat << EOF
usage: $0 [-d] [-v]

This script is intended to fix the common problem where npm users
are required to use sudo to install global packages.

It will backup a list of your installed packages remove all but npm,
then create a local directory, configure node to use this for global installs
whilst also fixing permissions on the .npm dir before, reinstalling the old packages.

OPTIONS:
   -h   Show this message
   -d   debug
   -v   Verbose
EOF
}


DEBUG=0
VERBOSE=0
while getopts "dv" OPTION
do
     case $OPTION in
         d)
             DEBUG=1
             ;;
         v)
             VERBOSE=1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

to_reinstall='/tmp/npm-reinstall.txt'

if [ 1 = ${VERBOSE} ];  then
    printf "\nSaving list of existing global npm packages\n"
fi

#Get a list of global packages (not deps)
#except for the npm package
#save in a temporary file.
npm -g list --depth=0 --parseable --long | cut -d: -f2 | grep -v '^npm@\|^$' >$to_reinstall

if [ 1 = ${VERBOSE} ];  then
    printf "\nRemoving existing packages temporarily - you might need your sudo password\n\n"
fi
#List the file
#replace the version numbers
#remove the newlines
#and pass to npm uninstall

uninstall='sudo npm -g uninstall'
if [ 1 = ${DEBUG} ];    then
    printf "Won't uninstall\n\n"
    uninstall='echo'
fi
if [ -s $to_reinstall ]; then
    cat $to_reinstall | sed -e 's/@.*//' | xargs $uninstall
fi

defaultnpmdir="${HOME}/.npm-packages"
npmdir=''

read -p "Choose your install directory. Default (${defaultnpmdir}) : " npmdir

if [ -z ${npmdir} ]; then
    npmdir=${defaultnpmdir}
else
    if [ ! -d ${npmdir} ]; then
        echo "${npmdir} is not a directory."
        exit
    fi
    npmdir="${npmdir}/.npm-packages"
fi

if [ 1 = ${VERBOSE} ];  then
    printf "\nMake a new directory ${npmdir} for our "-g" packages\n"
fi

if [ 0 = ${DEBUG} ];    then
    mkdir -p ${npmdir}
    npm config set prefix $npmdir
fi

if [ 1 = ${VERBOSE} ];  then
    printf "\nFix permissions on the .npm directories\n"
fi

me=`whoami`
sudo chown -R $me $npmdir

if [ 1 = ${VERBOSE} ];  then
    printf "\nReinstall packages\n\n"
fi

#list the packages to install
#and pass to npm
install='npm -g install'
if [ 1 = ${DEBUG} ];    then
    install='echo'
fi
if [ -s $to_reinstall ]; then
    cat $to_reinstall | xargs $install
fi

envfix='
export NPM_PACKAGES="%s"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules${NODE_PATH:+:$NODE_PATH}"
export PATH="$NPM_PACKAGES/bin:$PATH"
# Unset manpath so we can inherit from /etc/manpath via the `manpath`
# command
unset MANPATH  # delete if you already modified MANPATH elsewhere in your config
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
'

fix_env() {
    if [ -f "${HOME}/.bashrc" ];    then
        printf "${envfix}" ${npmdir} >> ~/.bashrc
        printf "\nDon't forget to run 'source ~/.bashrc'\n"
    fi
    if [ -f "${HOME}/.zshrc" ]; then
        printf "${envfix}" ${npmdir} >> ~/.zshrc
        printf "\nDon't forget to run 'source ~/.zshrc'\n"
    fi

}

echo_env() {
    printf "\nYou may need to add the following to your ~/.bashrc / .zshrc file(s)\n\n"
    printf "${envfix}\n\n" ${npmdir}
}

printf "\n\n"
read -p "Do you wish to update your .bashrc/.zshrc file(s) with the paths and manpaths? [yn] " yn
case $yn in
    [Yy]* ) fix_env;;
    [Nn]* ) echo_env;;
    * ) printf "\nInvalid choice\n"; echo_env;;
esac

rm $to_reinstall

printf "\nDone - current package list:\n\n"
npm -g list -depth=0