package main

import (
	"fmt"
	"log"
	"strings"

	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/errors/retry"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
	"github.com/hyperledger/fabric-sdk-go/pkg/util/pathvar"
)

// TestManualConfig uses new sdk instance with new config which only has entries for org1.
// this function tests,
//
//	if discovered peer has MSP ID found by dynamic discovery service.
//	if it is able to get endorsement from peers not mentioned in config
//	if tlscacerts are being used by channel block anchor peers if not found in config
func TestManualConfig(chaincodeId string) {
	//Config containing references to org1 only
	configProvider := config.FromFile(pathvar.Subst("config_manual.yaml"))

	org1sdk, err := fabsdk.New(configProvider)
	if err != nil {
		log.Fatal("failed to created SDK,", err)
	}
	defer org1sdk.Close()

	//prepare context
	org1ChannelClientContext := org1sdk.ChannelContext("mychannel", fabsdk.WithUser("User1"), fabsdk.WithOrg("Org1"))

	// Org1 user connects to 'mychannel'
	chClientOrg1User, err := channel.New(org1ChannelClientContext)
	if err != nil {
		log.Fatalf("Failed to create new channel client for Org1 user: %s", err)
	}

	req := channel.Request{
		ChaincodeID: chaincodeId,
		Fcn:         "GetAllAssets",
		Args:        nil,
	}
	resp, err := chClientOrg1User.Query(req, channel.WithRetry(retry.DefaultChannelOpts))
	if err != nil {
		log.Fatal("query funds failed", err)
	}

	foundOrg2Endorser := false
	for _, v := range resp.Responses {
		//check if response endorser is org2 peer and MSP ID 'Org2MSP' is found
		if strings.Contains(string(v.Endorsement.Endorser), "Org2MSP") {
			foundOrg2Endorser = true
			break
		}
	}

	if !foundOrg2Endorser {
		fmt.Println("Org2 MSP ID was not in the endorsement")
	}
}
