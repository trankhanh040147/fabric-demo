package main

import (
	"fmt"

	"rest-api-go/web"
)

// org1
func main() {
	//Initialize setup for Org1
	cryptoPath := "../../test-network/organizations/peerOrganizations/org1.example.com"
	orgConfig := web.OrgSetup{
		OrgName:      "Org1",
		MSPID:        "Org1MSP",
		CertPath:     cryptoPath + "/users/User1@org1.example.com/msp/signcerts/User1@org1.example.com-cert.pem",
		KeyPath:      cryptoPath + "/users/User1@org1.example.com/msp/keystore/",
		TLSCertPath:  cryptoPath + "/peers/peer1.org1.example.com/tls/ca.crt",
		PeerEndpoint: "dns:///localhost:7051",
		GatewayPeer:  "peer0.org1.example.com",
	}

	orgSetup, err := web.Initialize(orgConfig)
	if err != nil {
		fmt.Println("Error initializing setup for Org1: ", err)
	}
	web.Serve(web.OrgSetup(*orgSetup))
}

//func main() {
//    //Initialize setup for Org1
//    cryptoPath := "../../test-network/organizations/peerOrganizations/org1.example.com"
//    orgConfig := web.OrgSetup{
//        OrgName:      "Org1",
//        MSPID        "Org1MSP",
//        CertPath:     cryptoPath + "/users/User1@org1.example.com/msp/signcerts/User1@org1.example.com-cert.pem",
//        KeyPath:      cryptoPath + "/users/User1@org1.example.com/msp/keystore/",
//        TLSCertPath:  cryptoPath + "/peers/peer2.org1.example.com/tls/ca.crt",
//        PeerEndpoint: "dns:///localhost:9151",
//        GatewayPeer:  "peer2.org1.example.com",
//    }
//
//    orgSetup, err := web.Initialize(orgConfig)
//    if err != nil {
//        fmt.Println("Error initializing setup for Org1: ", err)
//    }
//    web.Serve(web.OrgSetup(*orgSetup))
//}

// Org3
//func main() {
//	//Initialize setup for Org3
//	cryptoPath := "../../test-network/organizations/peerOrganizations/org3.example.com"
//	orgConfig := web.OrgSetup{
//		OrgName:      "Org3",
//		MSPID:        "Org3MSP",
//		CertPath:     cryptoPath + "/users/User1@org3.example.com/msp/signcerts/User1@org3.example.com-cert.pem",
//		KeyPath:      cryptoPath + "/users/User1@org3.example.com/msp/keystore/",
//		TLSCertPath:  cryptoPath + "/peers/peer0.org3.example.com/tls/ca.crt",
//		PeerEndpoint: "dns:///localhost:8200",
//		GatewayPeer:  "peer0.org3.example.com",
//	}
//
//	orgSetup, err := web.Initialize(orgConfig)
//	if err != nil {
//		fmt.Println("Error initializing setup for Org3: ", err)
//	}
//	web.Serve(web.OrgSetup(*orgSetup))
//}
