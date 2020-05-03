#!/bin/bash

# Cpp boilerplate installation code
# Author: Mustafa Kemal GILOR <mgilor@nettsi.com>

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Relative paths
declare -A RP
# Common headers
source $SCRIPT_ROOT/common.sh && hadouken.define_relative_paths $SCRIPT_ROOT RP

echo -e "Script root: ${RP["SCRIPT"]}"
echo -e "Boilerplate folder: ${RP["BOILERPLATE"]}"
echo -e "Project folder: ${RP["PROJECT"]}"
echo -e "Project build folder: ${RP["BUILD"]}"
echo 

# Check if current folder has the proper name
if ! [[ "boilerplate" == "$(basename ${RP["BOILERPLATE"]})" ]] ; then
    echo "Boilerplate folder name is invalid. It should be named as boilerplate!"
    exit 1
fi

# Check if our parent directory is a git repository or not.
if ! git -C ${RP["PROJECT"]} rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
    echo "Boilerplate's parent directory is not a git directory!"
    exit 1
fi

if ! hadouken.has_cmakelist "${RP["PROJECT"]}"; then
    echo -e "Boilerplate parent directory does not contain a CMakeLists.txt"
    read -p "Do you want to quick-start a new cmake project to parent folder [Yy/Nn]? " -n 1 -r
    echo  
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        hadouken.bootstrap_cmake_project "${RP["PROJECT"]}"
    else
        exit 1
    fi
fi

# Create symlinks to parent
echo -e "Creating symlinks to parent repository"

declare -A symlinks=( 
    ["boilerplate/dotfiles/.gitconfig"]="${RP["PROJECT"]}/.gitconfig" 
    ["boilerplate/dotfiles/.gitignore"]="${RP["PROJECT"]}/.gitignore" 
    ["boilerplate/dotfiles/.clang-format"]="${RP["PROJECT"]}/.clang-format" 
    ["boilerplate/dotfiles/.clang-tidy"]="${RP["PROJECT"]}/.clang-tidy" 
    ["boilerplate/dotfiles/.cppcheck-suppress"]="${RP["PROJECT"]}/.cppcheck-suppress" 
    ["boilerplate/dotfiles/.vscode/settings.json"]="${RP["PROJECT"]}/.vscode/settings.json" 
    ["boilerplate/.devcontainer"]="${RP["PROJECT"]}/.devcontainer" 
    ["boilerplate/script/hadouken.sh"]="${RP["PROJECT"]}/hadouken"    
)

for key in "${!symlinks[@]}"
do
    value=${symlinks[$key]}
    if ! test -e "$value"; then
        echo -e "Creating symlink of $key to $value"
        ln -s $key $value
    else
        echo -e "A symbol already exist on path $value, skipping symlink creation for $key"
    fi
done

if [[ $(which docker) && $(docker --version) ]]; then
    echo "Docker exist in system"
    # TODO: Check whether current user is in docker group
  else
    echo "Devenv container requires docker. Do you want to install it?"
    # TODO: Prompt yes-no

    # command
fi

# code-insiders --list-extensions -> grep
# code-insiders --install-extension ms-vscode-remote.remote-containers


# TODO: Check if docker is installed on the system
# TODO: Check visual studio code is installed on the system
# TODO: Check vscode remote docker extension installed on vscode
# (sudo apt install docker.io)


# sudo usermod -a -G docker mustafa
# logout, or somehow reflect group changes to active session?
# (apt ?)

echo -e "Done! You're all set up."