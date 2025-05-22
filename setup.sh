#!/bin/bash

set -e

# Update pakketlijsten en Installeer Go via apt
echo "Update pakketlijsten en Go installeren via apt..."
sudo apt update
sudo apt install -y golang-go

# Functie om Go tools te installeren via 'go install'
install_go_tool() {
    local pkg=$1
    echo "Installing $pkg ..."
    go install "$pkg@latest"
}

# Voeg Go bin directory toe aan PATH in ~/.bashrc als dat nog niet is gedaan
GOPATH=$(go env GOPATH)
GO_BIN="$GOPATH/bin"
if ! grep -q "$GO_BIN" ~/.bashrc; then
    echo "export PATH=\$PATH:$GO_BIN" >> ~/.bashrc
    echo "Go bin directory toegevoegd aan PATH in ~/.bashrc"
fi
export PATH=$PATH:$GO_BIN

# Installeer ProjectDiscovery tools
install_go_tool github.com/projectdiscovery/httpx/cmd/httpx
install_go_tool github.com/projectdiscovery/nuclei/v2/cmd/nuclei
install_go_tool github.com/projectdiscovery/shuffledns/cmd/shuffledns
install_go_tool github.com/projectdiscovery/uncover/cmd/uncover
install_go_tool github.com/projectdiscovery/subfinder/v2/cmd/subfinder
install_go_tool github.com/projectdiscovery/dnsx/cmd/dnsx

# Installeer tomnomnom tools
install_go_tool github.com/tomnomnom/anew
install_go_tool github.com/tomnomnom/waybackurls

# Maak map voor wordlists aan
WORDLIST_DIR="wordlists"
mkdir -p "$WORDLIST_DIR"

# Download alle bestanden van https://wordlists-cdn.assetnote.io/data/manual/
echo "Downloading wordlists from https://wordlists-cdn.assetnote.io/data/manual/ ..."
wget -r -np -nH --cut-dirs=3 -P "$WORDLIST_DIR" https://wordlists-cdn.assetnote.io/data/manual/

echo "Installatie voltooid. Voer 'source ~/.bashrc' uit of start een nieuwe shell om PATH wijzigingen te laden."
