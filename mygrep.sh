#!/bin/bash

# Function to print help/usage
print_help() {
    echo "Usage: $0 [OPTION] PATTERN [FILE]"
    echo "Options:"
    echo "  -n        Show line numbers"
    echo "  -v        Invert match (show lines that do not match)"
    echo "  -h, --help  Show this help message"
}

# Initialize flags
show_line_numbers=false
invert_match=false

# Special handling for --help before getopts
for arg in "$@"; do
    if [[ "$arg" == "--help" ]]; then
        print_help
        exit 0
    fi
done

# Parse options with getopts
while getopts ":nvh" opt; do
    case $opt in
        n) show_line_numbers=true ;;
        v) invert_match=true ;;
        h) print_help; exit 0 ;;
        \?) echo "Unknown option: -$OPTARG"; print_help; exit 1 ;;
    esac
done

shift $((OPTIND -1))  # Remove parsed options from arguments

# After options, expect search_string and filename
search_string="$1"
filename="$2"

# Validate input
if [ -z "$search_string" ] || [ -z "$filename" ]; then
    echo "Error: Missing search string or filename."
    print_help
    exit 1
fi

if [ ! -f "$filename" ]; then
    echo "Error: File '$filename' not found."
    exit 1
fi

# Convert search_string to lowercase for case-insensitive search
search_lower=$(echo "$search_string" | tr '[:upper:]' '[:lower:]')

# Main functionality
line_number=0

while IFS= read -r line; do
    ((line_number++))

    # Convert line to lowercase for case-insensitive comparison
    line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    # Check if search string exists in line
    if [[ "$line_lower" == *"$search_lower"* ]]; then
        match=true
    else
        match=false
    fi

    # Handle inverted match
    if $invert_match; then
        match=$(! $match && echo true || echo false)
    fi

    # If match, print the line
    if $match; then
        if $show_line_numbers; then
            echo "${line_number}:$line"
        else
            echo "$line"
        fi
    fi
done < "$filename"
