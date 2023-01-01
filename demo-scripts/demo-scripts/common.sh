GITHUB_REPO="https://github.com/$(git remote -v | awk -F[\:\.] '/fetch/ {print $3}')"

function prompt() {
    echo ""
    echo "=================================================="
    echo $1
    echo ""
    while true 
    do 
        echo ${2:-"Proceed"} "[Y|A|S]?"
        read PROCEED
        if [[ $PROCEED = "A" || $PROCEED == "a" ]] # Abort
        then
            echo "Aborting ..."
            exit
        elif [[ $PROCEED = "S" || $PROCEED == "s" ]] # Skip to next step
        then 
            return -1
        elif [[ $PROCEED = "Y" || $PROCEED == "y" ]] # Proceed with step
        then 
            return 0
        fi
    done
}