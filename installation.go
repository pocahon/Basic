package main

import (
	"fmt"
	"os"
	"os/exec"
	"io"
	"net/http"
	"path/filepath"
	"bufio"
	"strings"
	"regexp"
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

func getWordlistFiles(baseURL string) ([]string, error) {
	resp, err := http.Get(baseURL)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	// Regex om href links te vinden
	re := regexp.MustCompile(`href="([^"]+)"`)
	var files []string
	scanner := bufio.NewScanner(resp.Body)
	for scanner.Scan() {
		line := scanner.Text()
		matches := re.FindAllStringSubmatch(line, -1)
		for _, match := range matches {
			if len(match) > 1 {
				files = append(files, match[1])
			}
		}
	}
	return files, scanner.Err()
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

	// Maak de map ~/Documents/wordlists aan
	wordlistDir := filepath.Join(os.Getenv("HOME"), "Documents", "wordlists")
	fmt.Println("Maak de map ~/Documents/wordlists aan...")
	err = os.MkdirAll(wordlistDir, os.ModePerm)
	if err != nil {
		fmt.Printf("Fout bij het aanmaken van de map ~/Documents/wordlists: %v\n", err)
		return
	}

	// Download alle wordlists van de gegeven URL
	wordlistBaseURL := "https://wordlists-cdn.assetnote.io/data/manual/"
	files, err := getWordlistFiles(wordlistBaseURL)
	if err != nil {
		fmt.Printf("Fout bij het ophalen van wordlist-bestanden: %v\n", err)
		return
	}

	for _, file := range files {
		// Zorg ervoor dat we alleen de bestanden downloaden die eindigen op .txt
		if strings.HasSuffix(file, ".txt") {
			fileURL := wordlistBaseURL + file
			destPath := filepath.Join(wordlistDir, file)
			fmt.Printf("Download %s...\n", file)
			err := downloadFile(destPath, fileURL)
			if err != nil {
				fmt.Printf("Fout bij het downloaden van %s: %v\n", file, err)
			}
		}
	}

	// Download JSON-bestanden van de gf GitHub repository
	files = []string{
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
