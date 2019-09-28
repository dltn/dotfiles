#!/usr/bin/env bash

# Customized PS1 prompt of the form
#     user@host pwd$
#
# User appears red when previous command's exit status != 0

function RED         { echo "\[\e[0;91m\]$1\[\e[0m\]"; }
function BLUE        { echo "\[\033[38;5;27m\]$1\[\e[0m\]"; }
function LIGHT_BLUE  { echo "\[\033[38;5;39m\]$1\[\e[0m\]"; }

PROMPT_COMMAND=__prompt_command 
__prompt_command() {
    local EXIT="$?"
    PS1=""

    if [ $EXIT != 0 ]; then
        PS1+="$(RED \\u)"
    else
        PS1+="$(LIGHT_BLUE \\u)"	
    fi

    PS1+="@$(BLUE \\h) $(BLUE \\w)$ "
}

