#!/bin/bash

source "$(dirname "$0")"/main.sh

SELECTIONS=()
TOTAL_OPTIONS=0
CURRENT_OPTION=0

branch_delete() {
    get_options_from_command "git branch" options

    BRANCH_NAMES=()
    CURRENT_BRANCH=0
    TOTAL_OPTIONS=$((${#options[@]}-1))
    CURRENT_OPTION=$((${#options[@]}-1))

    for branchIndex in ${!options[@]}
    do
        BRANCH_NAMES[$branchIndex]="${options[$branchIndex]:2}"

        if [[ "${options[$branchIndex]}" =~ ^\* ]]; then
            CURRENT_BRANCH="$branchIndex"
            SELECTIONS[$branchIndex]=false
        else
            SELECTIONS[$branchIndex]=true
        fi
    done

    printf "Which branch(es) do you want to delete?\n"
    print_navigation_instructions
    print_branch_options $(($TOTAL_OPTIONS+1))

    navigate_options "print_branch_options"

    printf "\nDeleting selected branches...\n"
    for selectionIndex in ${!SELECTIONS[@]}
    do
        if [[ "${SELECTIONS[$selectionIndex]}" == "true" ]]; then
            git branch -D "${BRANCH_NAMES[$selectionIndex]}" >/dev/null 
        fi
    done

    safe_cursor_down

    printf "\nRemaining Branches\n"
    git branch
}

print_branch_options() {
    local inputCurrentOption=$1

    printedOptions=()
    for branchIndex in "${!BRANCH_NAMES[@]}"
    do
        if [[ $branchIndex -eq $CURRENT_BRANCH ]]; then
            SELECTIONS[$branchIndex]=false
            printedOptions[$branchIndex]="${BRANCH_NAMES[$branchIndex]} [current]"
        else
            printedOptions[$branchIndex]="${BRANCH_NAMES[$branchIndex]}"
        fi
    done
    
    print_options "$inputCurrentOption" "${printedOptions[@]}"
}

case "$1" in
    "branch delete")
        branch_delete
        ;;
    *)
        ;;
esac