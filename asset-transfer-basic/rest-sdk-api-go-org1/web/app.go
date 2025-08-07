package web

import (
	"fmt"
	"net/http"

	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
)

// OrgSetup contains organization's config to interact with the network via SDK.
type OrgSetup struct {
	OrgName      string
	MSPID        string
	User         string
	ChannelID    string
	ConfigFile   string
	OrgMspCACert string // Path to the Org's MSP CA certificate
	SDK          *fabsdk.FabricSDK
}

// Serve starts the http web server for SDK operations.
func Serve(setup OrgSetup) {
	http.HandleFunc("/query", setup.SdkQuery)
	http.HandleFunc("/invoke", setup.SdkInvoke)
	fmt.Println("SDK-based API server listening on http://localhost:4000/")
	if err := http.ListenAndServe(":4000", nil); err != nil {
		fmt.Println(err)
	}
}
