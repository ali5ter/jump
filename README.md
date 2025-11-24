> **⚠️ Archived 2025-11-24. No longer maintained.**

# 🔖 Jump! A simple directory bookmarking utility for bash
Bookmark the current directory and jump back to it. Bookmarks stored so you can use across bash sessions.

## Usage

    $ jump -h

    Jump to bookmarked directories

    Usage:
        jump name will move you to the directory bookmarked with name
        jump -l|--list to list the current bookmarked directories
        jump -a|--add name to bookmark thecurrent directory with name
        jump -p|--pathfor name to display thecurrent directory stored for name
        jump -r|--remove name to remove a bookmark

Tab completion of bookmarks is provided.

Alias provided:

    $ alias | grep jump
    alias j='jump'
    alias j+='jump --add'
    alias j-='jump --delete'
    alias jl='jump --list'

## Install
To try it out, just source the script...

    . ./jump.sh

Or add the following to your `.bashrc` or `.bash_profile`...

    [ -f ~/.jump.sh ] || curl -s -o ~/.jump.sh https://raw.githubusercontent.com/ali5ter/jump/master/jump.sh
    source ~/.jump.sh