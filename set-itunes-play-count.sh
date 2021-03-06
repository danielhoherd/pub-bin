#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Interactive dialogue boxes that set play count for each file selected in Music.

command -v osascript &>/dev/null || { echo "osascript is required, are you using OS X?" >&2 ; exit 1 ; }

osascript -e 'tell application "Music"
    set sel to selection
    repeat with t in sel
        set trackname to the name of t
        set dialog_answers to display dialog "Enter a new play count for " & trackname & ":" default answer ""
        set newcount to text returned of dialog_answers as integer
        if button returned of dialog_answers is "OK" then
            set played count of t to newcount
        end if
    end repeat
end tell'
