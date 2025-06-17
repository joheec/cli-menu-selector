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
    echo -en "\033[1A"
}

cursor_down() {
    echo -en "\033[1B"
}

safe_cursor_up() {
    if [[ $CURRENT_OPTION -gt 0 ]]; then
        cursor_up
        CURRENT_OPTION=$(($CURRENT_OPTION-1))
    fi
}

safe_cursor_down() {
    if [[ $CURRENT_OPTION -lt $TOTAL_OPTIONS ]]; then
        cursor_down
        CURRENT_OPTION=$(($CURRENT_OPTION+1))
    fi
}

cursor_to_current_option() {
    local inputCurrentOption=$1

    returnDirection="up"
    if [[ "$inputCurrentOption" -lt "$CURRENT_OPTION" ]]; then
        returnDirection="down"
    fi

    while [[ "$inputCurrentOption" -ne "$CURRENT_OPTION" ]]
    do
        if [[ "$returnDirection" == "up" ]]; then
            cursor_up
            inputCurrentOption=$(($inputCurrentOption-1))

        else
            cursor_down
            inputCurrentOption=$(($inputCurrentOption+1))
        fi
    done
}

cursor_to_bottom() {
    currentOption="$CURRENT_OPTION"
    while [[ "$currentOption" -lt "$TOTAL_OPTIONS" ]]
    do
        cursor_down
        currentOption=$(($currentOption+1))
    done
}

delete_line() {
    echo -ne "\033[2K\033[1A"
}

delete_options() {
    cursor_to_bottom
    for (( i=0; i <= $TOTAL_OPTIONS; i++ )); do
        delete_line
    done
    cursor_down
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

print_navigation_instructions() {
    printf "\e[2mSelect branch (Press <space> to select, <a> to toggle all, <i> to invert selection, and <enter> to proceed)\e[0m\n"
}

print_options() {
    local inputCurrentOption=$1
    local inputPrintedOptions=("${@:2}")

    for printedOptionIndex in "${!inputPrintedOptions[@]}"
    do
        printedOption=""

        if [[ "${SELECTIONS[$printedOptionIndex]}" == "true" ]]; then
            printedOption+="${SELECTED_ICON} "
        else
            printedOption+="${UNSELECTED_ICON} "
        fi

        printedOption+="${inputPrintedOptions[$printedOptionIndex]}"
        printf "%s\n" "$printedOption"
    done

    cursor_to_current_option "$inputCurrentOption"
}

navigate_options() {
    local inputPrintFunction=$1

    while true; do
        get_user_input 1 userInput

        if [[ "$userInput" == $'\e' ]]; then
            get_user_input 2 arrowInput
            case "$arrowInput" in
                "[A")
                    safe_cursor_up
                    ;;
                "[B")
                    safe_cursor_down
                    ;;
                *)
                    ;;
            esac
        else
            case "$userInput" in
                "k")
                    safe_cursor_up
                    ;;
                "j")
                    safe_cursor_down
                    ;;
                " ")
                    select_option $inputPrintFunction
                    ;;
                "a")
                    toggle_all_options $inputPrintFunction
                    ;;
                "i")
                    invert_option_selection $inputPrintFunction
                    ;;
                "")
                    break
                    ;;
                *)
                    ;;
            esac
        fi
    done
}

select_option() {
    local inputPrintFunction=$1

    if [[ "${SELECTIONS[$CURRENT_OPTION]}" == "true" ]]; then
        SELECTIONS[$CURRENT_OPTION]=false
    else
        SELECTIONS[$CURRENT_OPTION]=true
    fi

    delete_options
    eval "$inputPrintFunction $(($TOTAL_OPTIONS+1))"
}

toggle_all_options() {
    local inputPrintFunction=$1

    selectedOptionCount=0
    for selection in "${SELECTIONS[@]}"
    do
        if [[ "$selection" == "true" ]]; then
            selectedOptionCount=$(($selectedOptionCount+1))
        fi
    done

    newSelectionValue=true
    if [[ "$selectedOptionCount" -gt $(($TOTAL_OPTIONS/2)) ]]; then
        newSelectionValue=false
    fi

    for selectionIndex in "${!SELECTIONS[@]}"
    do
        SELECTIONS[$selectionIndex]="$newSelectionValue"
    done

    delete_options
    eval "$inputPrintFunction $(($TOTAL_OPTIONS+1))"
}

invert_option_selection() {
    local inputPrintFunction=$1

    for selectionIndex in "${!SELECTIONS[@]}"
    do
        if [[ "${SELECTIONS[$selectionIndex]}" == "true" ]]; then
            SELECTIONS[$selectionIndex]=false
        else
            SELECTIONS[$selectionIndex]=true
        fi
    done

    delete_options
    eval "$inputPrintFunction $(($TOTAL_OPTIONS+1))"
}
