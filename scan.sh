#!/bin/bash

# set vars
id="$1"
ppath="$(pwd)"
scope_path="$ppath/scope/$id"

timestamp="$(date +%s)"
scan_path=$ppath/scans/$id-$timestamp

# exit if scope path doesn't exist
if [ ! -d "$scope_path" ]; then
    echo "Path doesn't exist"
    exit 1
fi

mkdir -p "$scan_path"
cd "$scan_path"

### PERFORM SCAN ###
## SETUP
echo "Starting scan against roots:"
cat "$scope_path/roots.txt"
cp -v "$scope_path/roots.txt" "$scan_path/roots.txt"

## DNS Enumeration - Find Subdomains
cat "$scan_path/roots.txt" | subfinder -silent | anew subs.txt | wc -l
cat "$scan_path/roots.txt" | shuffledns -mode resolve -w "$ppath/lists/pry-dns.txt" -r "$ppath/lists/resolvers.txt" -silent | anew subs.txt | wc -l

## DNS Resolution - Resolve Discovered Subdomains
puredns resolve "$scan_path/subs.txt" -r "$ppath/lists/resolvers.txt" -w "$scan_path/resolved.txt" -q | wc -l
dnsx -l "$scan_path/resolved.txt" -json -o "$scan_path/dns.json" -silent | jq -r '.a?[]?' | anew "$scan_path/ips.txt" | wc -l

## Port Scanning & HTTP Server Discovery
nmap -T4 -vv -iL "$scan_path/ips.txt" --top-ports 3000 -n --open -oX "$scan_path/nmap.xml"
tew -x "$scan_path/nmap.xml" -dnsx "$scan_path/dns.json" --vhost -o "$scan_path/hostport.txt" | httpx -sr -srd "$scan_path/responses" -json -o "$scan_path/http.json"

cat "$scan_path/http.json" | jq -r '.url' | sed -e 's/:80$//g' -e 's/:443$//g' | sort -u > "$scan_path/http.txt"

## Crawling
gospider -S "$scan_path/http.txt" --json | grep '{' | jq -r '.output?' | tee "$scan_path/crawl.txt"

## Javascript Pulling
cat "$scan_path/crawl.txt" | grep "\.js" | httpx -sr -srd js

################# ADD SCAN LOGIC HERE ###################

# calculate time diff
end_time=$(date +%s)
seconds="$(expr $end_time - $timestamp)"
time=""

if [[ "$seconds" -gt 59 ]]
then
    minutes=$(expr $seconds / 60)
    time="$minutes minutes"
else
    time="$seconds seconds"
fi

echo "Scan $id took $time"
#echo "Scan $id took $time" | notify
