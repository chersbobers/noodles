package mpr

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type Package struct {
	Name        string   `json:"Name"`
	Version     string   `json:"Version"`
	Description string   `json:"Description"`
	URL         string   `json:"URL"`
	Maintainer  string   `json:"Maintainer"`
	Depends     []string `json:"Depends"`
}

func GetPackageInfo(name string) (*Package, error) {
	url := fmt.Sprintf("https://mpr.makedeb.org/rpc/v1/info/%s", name)
	
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("package not found: %s", name)
	}

	var result struct {
		Results []Package `json:"results"`
	}
	
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	if len(result.Results) == 0 {
		return nil, fmt.Errorf("package not found: %s", name)
	}

	return &result.Results[0], nil
}