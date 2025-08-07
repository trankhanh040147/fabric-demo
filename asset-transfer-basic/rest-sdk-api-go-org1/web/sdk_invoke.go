package web

import (
	"fmt"
	"net/http"

	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
)

// SdkInvoke handles chaincode invoke requests using the Fabric SDK.
func (setup *OrgSetup) SdkInvoke(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Received SDK Invoke request")
	if err := r.ParseForm(); err != nil {
		http.Error(w, fmt.Sprintf("ParseForm() err: %s", err), http.StatusBadRequest)
		return
	}
	chainCodeName := r.FormValue("chaincodeid")
	channelID := r.FormValue("channelid")
	if channelID == "" {
		channelID = setup.ChannelID
	}
	function := r.FormValue("function")
	args := r.Form["args"]

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

	response, err := client.Execute(channel.Request{
		ChaincodeID: chainCodeName,
		Fcn:         function,
		Args:        sdkArgs,
	})
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to invoke chaincode: %s", err), http.StatusInternalServerError)
		return
	}

	fmt.Fprintf(w, "Transaction ID: %s \nResponse Payload: %s", response.TransactionID, string(response.Payload))
}
