package main

import (
	"fmt"
	"os"
	"os/exec"
	"io"
	"net/http"
	"path/filepath"
	"bufio"
)

func runCommand(command string, args ...string) {
	cmd := exec.Command(command, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Printf("Fout bij uitvoeren van %s: %v\n", command, err)
	}
}

func downloadFile(filepath string, url string) error {
	// Maak de request
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Maak het bestand
	out, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer out.Close()

	// Kopieer de inhoud naar het bestand
	_, err = io.Copy(out, resp.Body)
	return err
}

func appendToZshrc(line string) error {
	// Open het bestand in append-modus, of maak het bestand als het niet bestaat
	file, err := os.OpenFile(os.Getenv("HOME")+"/.zshrc", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	defer file.Close()

	// Controleer of de regel al bestaat
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		if scanner.Text() == line {
			// Als de regel al bestaat, doe niets
			return nil
		}
	}

	// Voeg de regel toe aan het bestand
	_, err = file.WriteString(line + "\n")
	return err
}

func main() {
	fmt.Println("Start installatie van pdtm en tools van Tomnomnom...")

	// Zorg ervoor dat de Go bin directory aan de PATH wordt toegevoegd
	fmt.Println("Voeg /home/kali/go/bin toe aan PATH in ~/.zshrc...")
	err := appendToZshrc("export PATH=$PATH:/home/kali/go/bin")
	if err != nil {
		fmt.Printf("Fout bij het updaten van ~/.zshrc: %v\n", err)
		return
	}

	// Voer source ~/.zshrc uit om de wijzigingen door te voeren
	fmt.Println("Update de shell met source ~/.zshrc...")
	runCommand("source", os.Getenv("HOME")+"/.zshrc")

	// Installeer pdtm van Project Discovery
	fmt.Println("Installeer pdtm van Project Discovery...")
	runCommand("go", "install", "github.com/projectdiscovery/pdtm/cmd/pdtm@latest")

	// Voeg ProjectDiscovery tools toe met pdtm
	fmt.Println("Installeer tools van Project Discovery met pdtm...")
	runCommand("pdtm", "-ia")

	// Installeer Meg van Tomnomnom
	fmt.Println("Installeer Meg van Tomnomnom...")
	runCommand("go", "install", "github.com/tomnomnom/meg@latest")

	// Installeer gf van Tomnomnom
	fmt.Println("Installeer gf van Tomnomnom...")
	runCommand("go", "install", "github.com/tomnomnom/gf@latest")

	// Installeer anew van Tomnomnom
	fmt.Println("Installeer anew van Tomnomnom...")
	runCommand("go", "install", "github.com/tomnomnom/anew@latest")

	// Maak de map /home/kali/.gf/ aan
	fmt.Println("Maak de map /home/kali/.gf/ aan...")
	err = os.MkdirAll("/home/kali/.gf", os.ModePerm)
	if err != nil {
		fmt.Printf("Fout bij het aanmaken van de map: %v\n", err)
		return
	}

	// Download JSON-bestanden van de gf GitHub repository
	files := []string{
		"aws-keys.json", "base64.json", "cors.json", "debug-pages.json",
		"ip.json", "json-secure.json", "php-errors.json", "potential.json",
		"servers.json", "strings.json", "takeovers.json", "uploads.json",
		"urls.json", "debug-pages.json",
	}

	baseURL := "https://raw.githubusercontent.com/tomnomnom/gf/master/examples/"
	for _, file := range files {
		fileURL := baseURL + file
		destPath := filepath.Join("/home/kali/.gf", file)
		fmt.Printf("Download %s...\n", file)
		err := downloadFile(destPath, fileURL)
		if err != nil {
			fmt.Printf("Fout bij het downloaden van %s: %v\n", file, err)
		}
	}

	fmt.Println("Installatie voltooid!")
}
