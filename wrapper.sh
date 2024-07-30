#!/bin/bash

# Print usage if no arguments are provided
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 -d domain"
    exit 1
fi

# Initialize variables
domain=""
while getopts "d:" opt; do
    case ${opt} in
        d )
            domain=$OPTARG
            ;;
        \? )
            echo "Invalid option: -$OPTARG" 1>&2
            exit 1
            ;;
        : )
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            exit 1
            ;;
    esac
done

# Check if the domain is provided
if [ -z "$domain" ]; then
    echo "Domain must be specified with -d option"
    exit 1
fi

# Generate a timestamp for filename
timestamp=$(date +"%Y%m%d_%H%M%S")

# Perform subdomain enumeration and HTTP probing
echo "$domain" | subfinder -silent -all | httpx -silent -o "subs_${domain}_${timestamp}"
echo "$domain" | subfinder -silent -all | httpx -silent -title -bp -server -td -o "info_${domain}_${timestamp}"
echo "$domain" | subfinder -silent -all | httpx -silent -ss 

echo "Subdomain enumeration and HTTP probing completed."
