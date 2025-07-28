package main

import (
	"fmt"

	"rest-api-go/web"
)

// org2
func main() {
	//Initialize setup for Org2
	cryptoPath := "../../test-network/organizations/peerOrganizations/org2.example.com"
	orgConfig := web.OrgSetup{
		OrgName:      "Org2",
		MSPID:        "Org2MSP",
		CertPath:     cryptoPath + "/users/User1@org2.example.com/msp/signcerts/User1@org2.example.com-cert.pem",
		KeyPath:      cryptoPath + "/users/User1@org2.example.com/msp/keystore/",
		TLSCertPath:  cryptoPath + "/peers/peer0.org2.example.com/tls/ca.crt",
		PeerEndpoint: "dns:///localhost:8100",
		GatewayPeer:  "peer0.org2.example.com",
	}

	orgSetup, err := web.Initialize(orgConfig)
	if err != nil {
		fmt.Println("Error initializing setup for Org2: ", err)
	}
	web.Serve(web.OrgSetup(*orgSetup))
}
