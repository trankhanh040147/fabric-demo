package web

import (
	"fmt"
	"net/http"

	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
)

// SdkQuery handles chaincode query requests using the Fabric SDK.
func (setup *OrgSetup) SdkQuery(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received SDK Query request")
	queryParams := r.URL.Query()
	chainCodeName := queryParams.Get("chaincodeid")
	channelID := queryParams.Get("channelid")
	if channelID == "" {
		channelID = setup.ChannelID
	}
	function := queryParams.Get("function")
	args := r.URL.Query()["args"]

	fmt.Printf("channel: %s, chaincode: %s, function: %s, args: %s\n", channelID, chainCodeName, function, args)

	clientChannelContext := setup.SDK.ChannelContext(channelID, fabsdk.WithUser(setup.User))
	client, err := channel.New(clientChannelContext)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to create new channel client: %s", err), http.StatusInternalServerError)
		return
	}

	var sdkArgs [][]byte
	for _, arg := range args {
		sdkArgs = append(sdkArgs, []byte(arg))
	}

	response, err := client.Query(channel.Request{
		ChaincodeID: chainCodeName,
		Fcn:         function,
		Args:        sdkArgs,
	})
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to query chaincode: %s", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(response.Payload)
}
