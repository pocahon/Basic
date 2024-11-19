#!/bin/bash

# One-liner voor de installatie: curl -s https://raw.githubusercontent.com/pocahon/Basic/refs/heads/main/setup-tools.sh | bash
# Update de pakketlijst en installeer Go en Zsh
sudo apt update
sudo apt install -y golang-go zsh

# Functie om de Go-bin-directory toe te voegen aan de huidige PATH variabele
updatePath() {
    export PATH=$PATH:/home/kali/go/bin
}

# Functie om een commando uit te voeren
runCommand() {
    command="$1"
    shift
    "$command" "$@"
    if [ $? -ne 0 ]; then
        echo "Fout bij uitvoeren van $command"
    fi
}

# Functie om een bestand te downloaden
downloadFile() {
    filepath="$1"
    url="$2"
    curl -o "$filepath" "$url"
    if [ $? -ne 0 ]; then
        echo "Fout bij het downloaden van $url"
    fi
}

# Functie om een regel toe te voegen aan .zshrc
appendToZshrc() {
    line="$1"
    if ! grep -Fxq "$line" "$HOME/.zshrc"; then
        echo "$line" >> "$HOME/.zshrc"
    fi
}

# Functie om bestanden van een URL te krijgen
getWordlistFiles() {
    baseURL="$1"
    curl -s "$baseURL" | grep -oP 'href="\K[^"]+(?=")' | grep "\.txt$"
}

# Start installatie van subfinder, httpx, shuffledns, dnsx en nuclei
echo "Start installatie van subfinder, httpx, shuffledns, dnsx en nuclei..."

# Update de PATH variabele in de huidige sessie
updatePath

# Voeg de Go bin directory toe aan PATH in ~/.zshrc
echo "Voeg /home/kali/go/bin toe aan PATH in ~/.zshrc..."
appendToZshrc 'export PATH=$PATH:/home/kali/go/bin'

# Installeer subfinder
echo "Installeer subfinder van ProjectDiscovery..."
runCommand go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Installeer httpx
echo "Installeer httpx van ProjectDiscovery..."
runCommand go install github.com/projectdiscovery/httpx/cmd/httpx@latest

# Installeer shuffledns
echo "Installeer shuffledns van ProjectDiscovery..."
runCommand go install github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest

# Installeer dnsx
echo "Installeer dnsx van ProjectDiscovery..."
runCommand go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest

# Installeer nuclei
echo "Installeer nuclei van ProjectDiscovery..."
runCommand go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Maak de map /home/kali/.gf/ aan
echo "Maak de map /home/kali/.gf/ aan..."
mkdir -p /home/kali/.gf

# Maak de map ~/Documents/wordlists aan
wordlistDir="$HOME/Documents/wordlists"
echo "Maak de map ~/Documents/wordlists aan..."
mkdir -p "$wordlistDir"

# Download alle wordlists van de gegeven URL
wordlistBaseURL="https://wordlists-cdn.assetnote.io/data/manual/"
files=$(getWordlistFiles "$wordlistBaseURL")
for file in $files; do
    fileURL="$wordlistBaseURL$file"
    destPath="$wordlistDir/$file"
    echo "Download $file..."
    downloadFile "$destPath" "$fileURL"
done

# Download JSON-bestanden van de gf GitHub repository
files=("aws-keys.json" "base64.json" "cors.json" "debug-pages.json" "ip.json" "json-secure.json" "php-errors.json" "potential.json" "servers.json" "strings.json" "takeovers.json" "uploads.json" "urls.json")
baseURL="https://raw.githubusercontent.com/tomnomnom/gf/master/examples/"
for file in "${files[@]}"; do
    fileURL="$baseURL$file"
    destPath="/home/kali/.gf/$file"
    echo "Download $file..."
    downloadFile "$destPath" "$fileURL"
done

# Controleer of Zsh correct is geïnstalleerd en stel het in als de standaard shell
echo "Controleer en stel Zsh in als standaard shell..."
chsh -s $(which zsh)

# Voer source ~/.zshrc uit om de veranderingen toe te passen
echo "Pas veranderingen toe met source ~/.zshrc..."
zsh -c "source ~/.zshrc"

echo "Installatie voltooid!"
