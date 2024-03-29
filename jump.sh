#!/usr/bin/env bash
# @file jump.sh
# Directory bookmarking utility
# Source this file to install
# @author Alister Lewis-Bowen <alister@lewis-bowen.org>

## Working directory
export JUMP=~/.jump
[ -d "$JUMP" ] || mkdir "$JUMP"

## Directory bookmark store
export JUMP_BOOKMARKS=~/.jump/bookmarks

## Convenience aliases
alias j='jump'
alias 'j+'='jump add'
alias 'j-'='jump delete'
alias jl='jump list'

## Colors
# shellcheck disable=SC1090
[ -f ~/.colors.bash ] || curl -s -o ~/.colors.bash https://raw.githubusercontent.com/Bash-it/bash-it/master/themes/colors.theme.bash
# shellcheck disable=SC1090
source ~/.colors.bash

_jump_complete () {
    ## bash completion for bookmarks
    local cur="${COMP_WORDS[COMP_CWORD]}"
    # shellcheck disable=SC2155
    local bookmarks=$(awk -F'::' '{print $1}' "$HOME"/.jump/bookmarks)
    # shellcheck disable=SC2207
    COMPREPLY=( $(compgen -W "${bookmarks}" -- "${cur}") )
    return 0
}
complete -o default -o nospace -F _jump_complete jump
complete -F _jump_complete j

_jump_bookmark_exists () {
    ## Check if bookmark exists
    [[ $(grep -c "^$1::" "$JUMP_BOOKMARKS") -gt '0' ]] && return 0
    return 1
}

jump () {
    ## Directory bookmarking utility
    # shellcheck disable=SC2154
    local help="
${echo_bold_white}Jump to bookmarked directories${echo_normal}

Usage:
${echo_bold_white}jump ${echo_underline_white}name${echo_normal} will move you to the\
 directory bookmarked with ${echo_underline_white}name${echo_normal}
${echo_bold_white}jump list${echo_normal} to list the current bookmarked\
 directories
${echo_bold_white}jump add ${echo_underline_white}name${echo_normal} to bookmark the\
current directory with ${echo_underline_white}name${echo_normal}
${echo_bold_white}jump pathfor ${echo_underline_white}name${echo_normal} to display the\
current directory stored for ${echo_underline_white}name${echo_normal}
${echo_bold_white}jump delete ${echo_underline_white}name${echo_normal} to delete a\
 bookmark
"

    case "$1" in

        ''|help|--help|-h)  echo -e "$help" ;;

        list)

            local current="►"
            local badDir="✖"
            local name path state

            while read -r line; do
                name=${line%::*}
                path=${line#*::}
                state=' '
                [ "$PWD" == "$path" ] && state="$current"
                [ ! -d "$path" ] && state="$badDir"
                # shellcheck disable=SC2154
                printf "%1s ${echo_green}%-10s ${echo_cyan}%-60s${echo_normal}\n" \
                    "$state" "$name" "$path"
            done < "$JUMP_BOOKMARKS"
            echo
            ;;

        add)

            local bms

            [ -z "$2" ] && { echo -e "$help"; return 1; }
            if  _jump_bookmark_exists "$2"; then
                # shellcheck disable=SC2154
                echo -e "${echo_yellow}Bookmark exists${echo_normal}"
                jump list
                return 1
            else
                echo "$2"'::'"$PWD" >> "$JUMP_BOOKMARKS"
                bms=$(sort "$JUMP_BOOKMARKS") && echo "$bms" > "$JUMP_BOOKMARKS"
                echo -e "${echo_cyan}Bookmark added${echo_normal}"
            fi
            ;;

        delete)
            [ -z "$2" ] && { echo -e "$help"; return 1; }
            if _jump_bookmark_exists "$2"; then
                sed -e /^"$2"::/d "$JUMP_BOOKMARKS" > "$JUMP_BOOKMARKS.tmp" && mv "$JUMP_BOOKMARKS.tmp" "$JUMP_BOOKMARKS"
                echo -e "${echo_cyan}Bookmark deleted${echo_normal}"
            else
                echo -e "${echo_yellow}No bookmark with this name${echo_normal}"
                jump list
                return 1
            fi
            ;;

        pathfor)

            local bm

            [ -z "$2" ] && { echo -e "$help"; return 1; }
            if _jump_bookmark_exists "$2"; then
                bm=$(grep "$2" "$JUMP_BOOKMARKS")
                echo "${bm#*::}"
            else
                echo -e "${echo_yellow}No bookmark with this name${echo_normal}"
                jump list
                return 1
            fi
            ;;

        *)
            local bm
            
            if _jump_bookmark_exists "$1"; then
                bm=$(grep "$1" "$JUMP_BOOKMARKS")
                cd "${bm#*::}" || return 1
            else
                echo -e "${echo_yellow}Unable to find '$1'${echo_normal}"
                jump list
                return 1
            fi
            ;;
    esac

    return 0
}