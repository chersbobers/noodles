package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: noodles install <package-name>")
		os.Exit(1)
	}

	command := os.Args[1]

	if command == "install" {
		if len(os.Args) < 3 {
			fmt.Println("Please specify a package name to install")
			os.Exit(1)
		}
		packageName := os.Args[2]
		if err := installPackage(packageName); err != nil {
			log.Fatal(err)
		}
	} else {
		fmt.Printf("Unknown command: %s\n", command)
		fmt.Println("Available commands: install")
		os.Exit(1)
	}
}

func installPackage(packageName string) error {
	fmt.Printf("🍜 Installing package: %s\n", packageName)

	// Create temporary build directory
	tmpDir := "/tmp/noodles-" + packageName
	if err := os.MkdirAll(tmpDir, 0755); err != nil {
		return fmt.Errorf("failed to create build directory: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	// Clone the MPR repository
	fmt.Println("📦 Cloning package repository...")
	cloneCmd := execCommand("git", "clone",
		"https://mpr.makedeb.org/"+packageName,
		tmpDir)
	cloneCmd.Dir = tmpDir

	if output, err := cloneCmd.CombinedOutput(); err != nil {
		return fmt.Errorf("failed to clone repository: %v\n%s", err, output)
	}

	// Build the package using makedeb
	fmt.Println("🔨 Building package...")
	buildCmd := execCommand("makedeb", "-si")
	buildCmd.Dir = tmpDir
	buildCmd.Stdout = os.Stdout
	buildCmd.Stderr = os.Stderr

	if err := buildCmd.Run(); err != nil {
		return fmt.Errorf("failed to build package: %v", err)
	}

	fmt.Printf("✨ Successfully installed %s!\n", packageName)
	return nil
}

func execCommand(name string, args ...string) *exec.Cmd {
	cmd := exec.Command(name, args...)
	cmd.Env = os.Environ()
	return cmd
}
