*Cách leave một channel*
```bash
# Path to the core.yaml file
export FABRIC_CFG_PATH=$PWD/config/

# Identity of the user performing the action
export CORE_PEER_MSPCONFIGPATH=/path/to/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

# Address of the target peer
export CORE_PEER_ADDRESS=localhost:7051
```

```bash
peer channel leave -c mychannel
```
