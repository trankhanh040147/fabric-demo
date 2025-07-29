package transaction

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/errors/retry"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/providers/fab"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fab/txn"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
	"github.com/hyperledger/fabric-sdk-go/pkg/util/pathvar"
	"github.com/pkg/errors"

	"stask-api/api/serializers"
	"stask-api/common/configure"
	"stask-api/common/logging"
	"stask-api/common/response"
	respErr "stask-api/common/response/error"
)

var (
	cfg    = configure.GetConfig()
	logger = logging.GetLogger()
)

type Controller interface {
	Endorse(ctx *fiber.Ctx) (err error)
}

type controller struct {
	service serviceInterface
}

func New() Controller {
	return &controller{
		service: newService(),
	}
}

//func (c *controller) Endorse(ctx *fiber.Ctx) error {
//	var requestBody serializers.TransactionCreateBodyValidate
//	if err := ctx.BodyParser(&requestBody); err != nil {
//		return response.New(ctx, response.Options{Code: fiber.StatusBadRequest, Data: respErr.ErrFieldWrongType})
//	}
//	if err := requestBody.Validate(); err != nil {
//		return err
//	}
//
//	// init connection
//	cryptoPath := "../../test-network/organizations/peerOrganizations/org2.example.com"
//	orgConfig := OrgSetup{
//		OrgName:      "Org2",
//		MSPID:        "Org2MSP",
//		CertPath:     cryptoPath + "/users/User1@org2.example.com/msp/signcerts/User1@org2.example.com-cert.pem",
//		KeyPath:      cryptoPath + "/users/User1@org2.example.com/msp/keystore/",
//		TLSCertPath:  cryptoPath + "/peers/peer0.org2.example.com/tls/ca.crt",
//		PeerEndpoint: "dns:///localhost:8100",
//		GatewayPeer:  "peer0.org2.example.com",
//	}
//
//	orgSetup, err := Initialize(orgConfig)
//	if err != nil {
//		return err
//	}
//
//	network := orgSetup.Gateway.GetNetwork(cfg.ChannelId)
//	contract := network.GetContract(requestBody.ChaincodeName)
//
//	// TODO: get proposal from transaction id
//
//	// TODO: endorse proposal
//
//	return nil
//}

func (c *controller) Endorse(ctx *fiber.Ctx) error {
	var requestBody serializers.TransactionCreateBodyValidate
	if err := ctx.BodyParser(&requestBody); err != nil {
		return response.New(ctx, response.Options{Code: fiber.StatusBadRequest, Data: respErr.ErrFieldWrongType})
	}
	if err := requestBody.Validate(); err != nil {
		return err
	}

	//Config containing references to org1 only
	configProvider := config.FromFile(pathvar.Subst(cfg.ConfigOrg1))
	////if local test, add entity matchers to override URLs to localhost
	//if integration.IsLocal() {
	//	configProvider = integration.AddLocalEntityMapping(configProvider)
	//}

	org1sdk, err := fabsdk.New(configProvider)
	if err != nil {
		return err
	}
	defer org1sdk.Close()

	//prepare context
	org1ChannelClientContext := org1sdk.ChannelContext("mychannel", fabsdk.WithUser("User1"), fabsdk.WithOrg("Org1"))

	// Org1 user connects to 'mychannel'
	client, err := channel.New(org1ChannelClientContext)
	if err != nil {
		logger.Err(err)
		return err
	}

	req := channel.Request{
		ChaincodeID: requestBody.ChaincodeId,
		Fcn:         requestBody.ChaincodeFunc,
		Args:        requestBody.Args,
	}

	resp, err := client.Query(req, channel.WithRetry(retry.DefaultChannelOpts))
	if err != nil {
		logger.Err(err)
		return err
	}

	foundOrg2Endorser := false
	for _, v := range resp.Responses {
		//check if response endorser is org2 peer and MSP ID 'Org2MSP' is found
		if strings.Contains(string(v.Endorsement.Endorser), "Org2MSP") {
			foundOrg2Endorser = true
			break
		}
	}

	// TODO: get proposal from transaction id

	// TODO: endorse proposal

	return nil
}

func (c *controller) CreateTransaction(ctx *fiber.Ctx) error {
	var requestBody serializers.TransactionCreateBodyValidate
	if err := ctx.BodyParser(&requestBody); err != nil {
		return response.New(ctx, response.Options{Code: fiber.StatusBadRequest, Data: respErr.ErrFieldWrongType})
	}
	if err := requestBody.Validate(); err != nil {
		return err
	}

	request := fab.ChaincodeInvokeRequest{
		ChaincodeID: requestBody.ChaincodeId,
		Fcn:         requestBody.ChaincodeFunc,
		Args:        requestBody.Args,
		//TransientMap: chrequest.TransientMap,
	}

	txh, err := sender.CreateTransactionHeader()
	if err != nil {
		return nil, fab.EmptyTransactionID, errors.WithMessage(err, "creation of transaction header failed")
	}

	tpreq, err := txn.CreateChaincodeInvokeProposal(txh, request)
	if err != nil {
		return nil, fab.EmptyTransactionID, errors.WithMessage(err, "creation of transaction proposal failed")
	}

	tpr, err := sender.SendTransactionProposal(tpreq, targets)
	return tpr, tpreq.TxnID, err

	return nil
}
