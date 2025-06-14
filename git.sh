#!/bin/bash

source ./main.sh

branch_select() {
    printf "Which branch do you want to checkout?\n"
}

branch_delete() {
    get_options_from_command "git branch" options

    totalOptions=$((${#options[@]}-1))
    currentBranch=0
    printedOptions=()

    for branchIndex in ${!options[@]}
    do
        if [[ "${options[$branchIndex]}" =~ ^\* ]]; then
            currentBranch="$branchIndex"
            printedOptions[$branchIndex]="${UNSELECTED_ICON} ${options[$branchIndex]:1} [current branch]"
        else
            printedOptions[$branchIndex]="${SELECTED_ICON}${options[$branchIndex]}"
        fi
    done

    printf "Which branch(es) do you want to delete?\n"
    print_navigation_instructions
    printf "%s\n" "${printedOptions[@]}"
    cursor_up $(($totalOptions + 1)) currentOption
    navigate_options printedOptions $currentOption $totalOptions "${printedOptions[@]}"
}

case "$1" in
    "branch select")
        branch_select
        ;;
    "branch delete")
        branch_delete
        ;;
    *)
        ;;
esac