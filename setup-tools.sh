#!/bin/bash

# One-liner voor de installatie: curl -s https://raw.githubusercontent.com/pocahon/Basic/refs/heads/main/setup-tools.sh | bash
# Detecteer het pakketbeheer en installeer Go en Zsh
if command -v apt &> /dev/null; then
    sudo apt update && sudo apt install -y golang-go zsh curl
else
    echo "Niet-ondersteunde Linux-distributie. Dit script is alleen geschikt voor Kali Linux en Ubuntu."
    exit 1
fi

# Functie om de Go-bin-directory toe te voegen aan de huidige PATH variabele
updatePath() {
    export PATH=$PATH:$(go env GOPATH)/bin
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

# Functie om een regel toe te voegen aan een configuratiebestand
appendToFile() {
    line="$1"
    file="$2"
    if ! grep -Fxq "$line" "$file"; then
        echo "$line" >> "$file"
    fi
}

# Start installatie van tools
echo "Start installatie van subfinder, httpx, shuffledns, dnsx, nuclei, gf en anew..."

# Update de PATH variabele in de huidige sessie
updatePath

# Bepaal het juiste configuratiebestand
SHELL_NAME=$(basename "$SHELL")
if [ "$SHELL_NAME" = "bash" ]; then
    CONFIG_FILE="$HOME/.bashrc"
elif [ "$SHELL_NAME" = "zsh" ]; then
    CONFIG_FILE="$HOME/.zshrc"
else
    echo "Ongeldige shell. Alleen bash en zsh worden ondersteund."
    exit 1
fi

echo "Voeg Go bin directory toe aan PATH in $CONFIG_FILE..."
appendToFile 'export PATH=$PATH:$(go env GOPATH)/bin' "$CONFIG_FILE"

# Installeer tools via Go
for tool in "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest" \
            "github.com/projectdiscovery/httpx/cmd/httpx@latest" \
            "github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest" \
            "github.com/projectdiscovery/dnsx/cmd/dnsx@latest" \
            "github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest" \
            "github.com/tomnomnom/gf@latest" \
            "github.com/tomnomnom/anew@latest"; do
    echo "Installeer $(basename "$tool")..."
    runCommand go install -v "$tool"
done

# Maak de gf-configuratiemap aan
GF_DIR="$HOME/.gf"
echo "Maak de map $GF_DIR aan..."
mkdir -p "$GF_DIR"

# Maak de wordlists-map aan
WORDLIST_DIR="$HOME/Documents/wordlists"
echo "Maak de map $WORDLIST_DIR aan..."
mkdir -p "$WORDLIST_DIR"

# Download alle wordlists
wordlistBaseURL="https://wordlists-cdn.assetnote.io/data/manual/"
echo "Download wordlists..."
curl -s "$wordlistBaseURL" | grep -oP 'href="\K[^"]+(?=")' | grep "\.txt$" | while read -r file; do
    downloadFile "$WORDLIST_DIR/$file" "$wordlistBaseURL$file"
done

# Download JSON-bestanden voor gf
baseURL="https://raw.githubusercontent.com/tomnomnom/gf/master/examples/"
for file in "aws-keys.json" "base64.json" "cors.json" "debug-pages.json" "ip.json" "json-secure.json" "php-errors.json" "potential.json" "servers.json" "strings.json" "takeovers.json" "uploads.json" "urls.json"; do
    downloadFile "$GF_DIR/$file" "$baseURL$file"
done

# Controleer of Zsh correct is geïnstalleerd en stel het in als de standaard shell
echo "Controleer en stel Zsh in als standaard shell..."
sudo chsh -s $(which zsh) $USER

# Pas veranderingen toe
echo "Pas veranderingen toe met source $CONFIG_FILE..."
source "$CONFIG_FILE"

echo "Installatie voltooid!"
