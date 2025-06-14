#!/bin/bash

SELECTED_ICON='●'
UNSELECTED_ICON='○'

set_delimiter_newline() {
    IFS=$'\n' 
}

reset_delimiter() {
    IFS=$' \t\n'
}

cursor_up() {
    local inputCurrentOption=$1
    local outputCurrentOption=$2
 
    if [[ $inputCurrentOption -gt 0 ]]; then
        echo -en "\033[1A"
        currentOption=$((inputCurrentOption - 1))
    else
        currentOption="$inputCurrentOption"
    fi

    eval "$outputCurrentOption=\"$currentOption\""
}

cursor_down() {
    local inputCurrentOption=$1
    local inputTotalOptions=$2
    local outputCurrentOption=$3

    if [[ $inputCurrentOption -lt $inputTotalOptions ]]; then
        echo -en "\033[1B"
        currentOption=$((inputCurrentOption + 1))
    else
        currentOption="$inputCurrentOption"
    fi

    eval "$outputCurrentOption=\"$currentOption\""
}

cursor_to_bottom() {
    local inputCurrentOption=$1
    local inputTotalOptions=$2

    currentOption="$inputCurrentOption"

    while [[ "$currentOption" -ne "$inputTotalOptions" ]]; do
        cursor_down $currentOption $inputTotalOptions currentOption
    done
}

delete_current_option() {
    echo -ne "\033[2K\033[1A"
    echo -en "\033[1B"
}

delete_options() {
    local inputCurrentOption=$1
    local inputTotalOptions=$2

    cursor_to_bottom $inputCurrentOption $inputTotalOptions

    for (( i=0; i <= $inputTotalOptions; i++ )); do
        echo -ne "\033[2K\033[1A"
    done
    echo -ne "\033[1B"
}

print_navigation_instructions() {
    printf "\e[2mSelect branch (Press <space> to select, <a> to toggle all, <i> to invert selection, and <enter> to proceed)\e[0m\n"
}

toggle_selector_icon() {
    local outputPrintedOptions=$1
    local inputCurrentOption=$2
    local inputPrintedOptions=("${@:3}")

    printedOptions=("${inputPrintedOptions[@]}")

    if [[ "${inputPrintedOptions[$inputCurrentOption]}" =~ ^"$SELECTED_ICON" ]]; then
        printedOptions[$inputCurrentOption]="${UNSELECTED_ICON}${inputPrintedOptions[$inputCurrentOption]:1}"
    elif [[ "${inputPrintedOptions[$inputCurrentOption]}" =~ ^"$UNSELECTED_ICON" ]]; then
        printedOptions[$inputCurrentOption]="${SELECTED_ICON}${inputPrintedOptions[$inputCurrentOption]:1}"
    else
        printedOptions[$inputCurrentOption]="${inputPrintedOptions[$inputCurrentOption]}"
    fi

    eval "$outputPrintedOptions=(\"\${printedOptions[@]}\")"
}

navigate_options() {
    local ouputPrintedOptions=$1
    local inputCurrentOption=$2
    local inputTotalOptions=$3
    local inputPrintedOptions=("${@:4}")

    currentOption="$inputCurrentOption"
    printedOptions=("${inputPrintedOptions[@]}")

    while true; do
        get_user_input 1 userInput

        if [[ "$userInput" == $'\e' ]]; then
            get_user_input 2 arrowInput
            case "$arrowInput" in
                "[A")
                    cursor_up $currentOption currentOption
                    ;;
                "[B")
                    cursor_down $currentOption $inputTotalOptions currentOption
                    ;;
                *)
                    ;;
            esac
        else
            case "$userInput" in
                "k")
                    cursor_up $currentOption currentOption
                    ;;
                "j")
                    cursor_down $currentOption $inputTotalOptions currentOption
                    ;;
                "a")
                    echo "toggle_all_options"
                    ;;
                " ")
                    select_option printedOptions $currentOption "${printedOptions[@]}"
                    ;;
                "i")
                    invert_option_selection printedOptions $currentOption $inputTotalOptions "${printedOptions[@]}"
                    ;;
                "")
                    echo "proceed"
                    break
                    ;;
                *)
                    ;;
            esac
        fi
    done
}

invert_option_selection() {
    local outputPrintedOptions=$1
    local inputCurrentOption=$2
    local inputTotalOptions=$3
    local inputPrintedOptions=("${@:4}")

    printedOptions=("${inputPrintedOptions[@]}")
    for optionIndex in ${!inputPrintedOptions[@]}
    do
        toggle_selector_icon printedOptions $optionIndex "${printedOptions[@]}"
    done

    delete_options $inputCurrentOption $inputTotalOptions
    printf "%s\n" "${printedOptions[@]}"
    
    currentOption=$((inputTotalOptions + 1))

    while [[ $currentOption -gt $inputCurrentOption ]]; do
        cursor_up $currentOption currentOption
    done

    eval "$outputPrintedOptions=(\"\${printedOptions[@]}\")"
}

select_option() {
    local outputPrintedOptions=$1
    local inputCurrentOption=$2
    local inputPrintedOptions=("${@:3}")

    printedOptions=("${inputPrintedOptions[@]}")
    toggle_selector_icon printedOptions $inputCurrentOption "${printedOptions[@]}"
    delete_current_option
    printf "%s\n" "${printedOptions[$inputCurrentOption]}"
    echo -en "\033[1A"
}

get_options_from_command() {
    local inputCommand=$1
    local outputOptions=$2

    set_delimiter_newline
    executedCommand=($(eval "$inputCommand"))
    if [[ $? -eq 2 ]]; then
        exit 2
    fi
    eval "$outputOptions=(\"\${executedCommand[@]}\")"
    reset_delimiter
}

get_user_input() {
    local inputCharacters=$1
    local outputUserInput=$2

    IFS= read -rsn"$inputCharacters" input
    # -r: disable backslashes to escape characters
    # -s: does not echo the user's input
    # -n: returns after reading specified number of characters while honoring the delimiter to terminate early

    reset_delimiter

    eval "$outputUserInput=\"$input\""
}
