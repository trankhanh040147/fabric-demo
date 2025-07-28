package main

import (
	"fmt"

	"rest-api-go/web"
)

// Org3
func main() {
	//Initialize setup for Org3
	cryptoPath := "../../test-network/organizations/peerOrganizations/org3.example.com"
	orgConfig := web.OrgSetup{
		OrgName:      "Org3",
		MSPID:        "Org3MSP",
		CertPath:     cryptoPath + "/users/User1@org3.example.com/msp/signcerts/User1@org3.example.com-cert.pem",
		KeyPath:      cryptoPath + "/users/User1@org3.example.com/msp/keystore/",
		TLSCertPath:  cryptoPath + "/peers/peer0.org3.example.com/tls/ca.crt",
		PeerEndpoint: "dns:///localhost:8200",
		GatewayPeer:  "peer0.org3.example.com",
	}

	orgSetup, err := web.Initialize(orgConfig)
	if err != nil {
		fmt.Println("Error initializing setup for Org3: ", err)
	}
	web.Serve(web.OrgSetup(*orgSetup))
}
