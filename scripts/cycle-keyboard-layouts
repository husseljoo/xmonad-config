#!/usr/bin/env zsh

total_layouts="${#@}"
current_layout=$(setxkbmap -query | awk '/layout:/{ print $2 }')
current_index="${@[(i)$current_layout]}"
next_index="$((current_index % total_layouts + 1))"
next_layout="${@[$next_index]}"

setxkbmap "$next_layout"
