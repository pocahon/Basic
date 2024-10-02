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

// updatePath voegt de Go-bin-directory toe aan de huidige PATH variabele
func updatePath() {
	os.Setenv("PATH", os.Getenv("PATH")+":/home/kali/go/bin")
}

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
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	out, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	return err
}

func appendToZshrc(line string) error {
	file, err := os.OpenFile(os.Getenv("HOME")+"/.zshrc", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		if scanner.Text() == line {
			return nil
		}
	}

	_, err = file.WriteString(line + "\n")
	return err
}

func main() {
	fmt.Println("Start installatie van pdtm en tools van Tomnomnom...")

	// Update de PATH variabele in de huidige sessie
	updatePath()

	// Zorg ervoor dat de Go bin directory aan de PATH wordt toegevoegd in toekomstige shells
	fmt.Println("Voeg /home/kali/go/bin toe aan PATH in ~/.zshrc...")
	err := appendToZshrc("export PATH=$PATH:/home/kali/go/bin")
	if err != nil {
		fmt.Printf("Fout bij het updaten van ~/.zshrc: %v\n", err)
		return
	}

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
