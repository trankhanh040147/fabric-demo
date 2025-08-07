package main

import (
	"fmt"

	"rest-api-go-sdk/web"
)

func main() {
	TestManualConfig("basic")
	// Initialize setup for Org1 using Fabric SDK
	orgConfig := web.OrgSetup{
		OrgName:    "Org1",
		MSPID:      "Org1MSP",
		User:       "User1",
		ChannelID:  "mychannel",
		ConfigFile: "config.yaml", // Path to the config file
		// Explicitly provide the path to the organization's root CA certificate
		OrgMspCACert: "../../test-network/organizations/peerOrganizations/org1.example.com/msp/cacerts/ca.org1.example.com-cert.pem",
	}

	orgSetup, err := web.Initialize(orgConfig)
	if err != nil {
		fmt.Println("Error initializing setup for Org1: ", err)
		return
	}
	defer orgSetup.SDK.Close()

	web.Serve(*orgSetup)
}
