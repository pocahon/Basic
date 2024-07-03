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

# Set variables
ppath="$(pwd)"
date=$(date +%Y-%m-%d)
scan_path="${ppath}/${domain}_${date}"
start_time=$(date +%s)

# Create the scan directory
mkdir -p "$scan_path"
cd "$scan_path"

### PERFORM SCAN ###
## SETUP
echo "[+] Starting scan against domain: $domain"

## DNS Enumeration - Find Subdomains
echo "[+] Gathering subdomains for $domain..."
echo "$domain" | subfinder -silent | anew subs.txt | wc -l

## DNS Resolution using httpx
echo "[+] Resolving discovered subdomains with httpx..."
cat subs.txt | httpx -silent -json -o "${scan_path}/httpx.json" -r "${ppath}/lists/resolvers.txt"

## Extracting IPs from httpx results
jq -r '.a[]? // empty' "${scan_path}/httpx.json" | anew "${scan_path}/ips.txt" | wc -l

################# ADD SCAN LOGIC HERE ###################

# Calculate time difference
end_time=$(date +%s)
seconds="$(expr $end_time - $start_time)"
time=""

if [[ "$seconds" -gt 59 ]]
then
    minutes=$(expr $seconds / 60)
    time="$minutes minutes"
else
    time="$seconds seconds"
fi

echo "[+] Scan of $domain took $time"
#echo "Scan of $domain took $time" | notify
