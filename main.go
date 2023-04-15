package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"path/filepath"

	"github.com/adrg/xdg"
	"github.com/neovim/go-client/nvim"
)

const (
	defaultFile   = ""
	defaultLine   = 0
	defaultServer = ""
)

var (
	defaultCacheRoot = filepath.Join(xdg.CacheHome, "nvim")
)

type serverNames struct {
	ServerNames []string `json:"servernames"`
}

func main() {
	// Required flags are: -file string, -line int.
	// Optional flags are: -cache_root string, -server string.
	// No other argument is needed.
	file := flag.String("file", defaultFile, "Absolute filename [REQUIRED]")
	line := flag.Int("line", defaultLine, "Line number [REQUIRED] ")
	server := flag.String("server", defaultServer, "Server name (vim.v.servername)")
	cache_root := flag.String("cache_root", defaultCacheRoot, "Path to nvim-texlabconfig.json file")

	flag.Parse()

	if flag.NArg() > 0 || *file == defaultFile || *line == defaultLine {
		log.Fatal("Some flags are required")
	}

	// Parse cache file `nvim-texlabconfig.json`.
	content, err := ioutil.ReadFile(filepath.Join(*cache_root, "nvim-texlabconfig.json"))
	if err != nil {
		log.Fatal("Error when opening file: ", err)
	}

	var servers serverNames
	if err := json.Unmarshal(content, &servers); err != nil {
		log.Fatal("Error during Unmarshal(): ", err)
	}

	/// Try passed server first.
	if *server != defaultServer {
		servers.ServerNames = append([]string{*server}, servers.ServerNames...)
	}

	// ExecLua function `require('texlabconfig').fn:inverse_search` in the first avaiable nvim instance.
	for _, serverName := range servers.ServerNames {
		v, err := nvim.Dial(serverName)
		if err != nil {
			log.Print("Error during Dial nvim: ", err)
			continue
		}
		defer v.Close()

		var result bool
		if err := v.ExecLua("return require('texlabconfig').fn:inverse_search(...)", &result, file, line); err != nil {
			log.Print("Error during ExecLua: ", err)
		} else if !result {
			log.Print("Error during inverse_search")
		} else {
			log.Printf("Pipe: %s, File: %s, Line: %d", serverName, *file, *line)
			break
		}
	}
}
