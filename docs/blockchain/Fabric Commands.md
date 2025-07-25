https://hyperledger-fabric.readthedocs.io/en/release-2.5/deploy_chaincode.html#package-the-smart-contract

**Set Org1 identity**
(đứng ở folder test-network)
```bash
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

- **Set Org2 identity:**
(đứng ở folder test-network)
```bash
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```
---
**Nén chaincode**
```
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-typescript/ --lang node --label basic_1.0
```
**Install chaincode**
```bash
peer lifecycle chaincode install basic.tar.gz
```
**Tìm packageID của chaincode**
```bash
peer lifecycle chaincode queryinstalled
```
**Set package id ENV**
```bash
export CC_PACKAGE_ID=basic_1.0:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3
```
**Approve chaincode**
(đứng ở folder test-network)
```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

**Check approve**
```bash
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --output json
```
**Commit chaincode to channel**
```bash
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
```
---
## Chaincode 

**Deploy chaincode với endorsement policy là 2 member của tổ chức **
```bash
./network.sh deployCC -c mychannel -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go -ccep "OutOf(2,'Org1MSP.peer','Org1MSP.peer','Org1MSP.peer')"
```
```
./network.sh deployCC -c mychannel -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go -ccep "AND('Org1MSP.member','Org1MSP.member')"
```
**InitLedger**
```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```
**GetAllAssets**
```bash
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```
**ReadAsset**
```bash
peer chaincode query -C mychannel -n basic -c '{"Args":["ReadAsset", "asset1"]}'
```
---
# PATH

## blockchain
```bash
docker exec -it peer0.org1.example.com bash
cd /var/hyperledger/production/ledgersData/chains/chains/mychannel
```