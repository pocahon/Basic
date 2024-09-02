package main

import (
	"fmt"
	"os"
	"os/exec"
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

func main() {
	fmt.Println("Start installatie van pdtm en tools van Tomnomnom...")

	// Installeer pdtm van Project Discovery
	fmt.Println("Installeer pdtm van Project Discovery...")
	runCommand("go", "install", "github.com/projectdiscovery/pdtm/cmd/pdtm@latest")

	// Voeg ProjectDiscovery tools toe met pdtm
	fmt.Println("Installeer tools van Project Discovery met pdtm...")
	runCommand("pdtm", "add", "all")

	// Installeer Meg van Tomnomnom
	fmt.Println("Installeer Meg van Tomnomnom...")
	runCommand("go", "install", "github.com/tomnomnom/meg@latest")

	// Installeer gf van Tomnomnom
	fmt.Println("Installeer gf van Tomnomnom...")
	runCommand("go", "install", "github.com/tomnomnom/gf@latest")

	// Installeer anew van Tomnomnom
	fmt.Println("Installeer anew van Tomnomnom...")
	runCommand("go", "install", "github.com/tomnomnom/anew@latest")

	fmt.Println("Installatie voltooid!")
}
