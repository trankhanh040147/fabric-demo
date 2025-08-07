package web

import (
	"fmt"
	"log"

	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
)

// Initialize sets up the Fabric SDK.
func Initialize(setup OrgSetup) (*OrgSetup, error) {
	log.Println("Initializing Fabric SDK...")
	sdk, err := fabsdk.New(config.FromFile(setup.ConfigFile))
	if err != nil {
		return nil, fmt.Errorf("failed to create new SDK: %w", err)
	}
	setup.SDK = sdk
	log.Println("Fabric SDK initialization complete")
	return &setup, nil
}
