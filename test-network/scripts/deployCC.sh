#!/usr/bin/env bash

source scripts/utils.sh

# --- Parameter Defaults ---
CHANNEL_NAME=${1:-"mychannel"}
CC_NAME=${2}
CC_SRC_PATH=${3}
CC_SRC_LANGUAGE=${4}
CC_VERSION=${5:-"1.0"}
CC_SEQUENCE=${6:-"1"}
CC_INIT_FCN=${7:-"NA"}
CC_END_POLICY=${8:-"NA"}
CC_COLL_CONFIG=${9:-"NA"}
DELAY=${10:-"3"}
MAX_RETRY=${11:-"5"}
VERBOSE=${12:-"false"}

# --- Print Parameters ---
println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_COLL_CONFIG: ${C_GREEN}${CC_COLL_CONFIG}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- DELAY: ${C_GREEN}${DELAY}${C_RESET}"
println "- MAX_RETRY: ${C_GREEN}${MAX_RETRY}${C_RESET}"
println "- VERBOSE: ${C_GREEN}${VERBOSE}${C_RESET}"

# --- Argument Parsing for Flags ---
INIT_REQUIRED="--init-required"
if [ "$CC_INIT_FCN" = "NA" ]; then
  INIT_REQUIRED=""
fi

if [ "$CC_END_POLICY" = "NA" ]; then
  CC_END_POLICY=""
else
  CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

if [ "$CC_COLL_CONFIG" = "NA" ]; then
  CC_COLL_CONFIG=""
else
  CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG"
fi

FABRIC_CFG_PATH=$PWD/../config/

# --- Import helpers ---
. scripts/envVar.sh
. scripts/ccutils.sh

function checkPrereqs() {
  jq --version > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    errorln "jq command not found..."
    errorln
    errorln "Follow the instructions in the Fabric docs to install the prereqs"
    errorln "https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html"
    exit 1
  fi
}

#check for prerequisites
checkPrereqs

# --- Main Deployment Logic ---

## 1. Package the chaincode
infoln "Packaging chaincode..."
./scripts/packageCC.sh "$CC_NAME" "$CC_SRC_PATH" "$CC_SRC_LANGUAGE" "$CC_VERSION"

infoln "Calculating new chaincode package ID..."
export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CC_NAME}.tar.gz)
println "Package ID is: ${C_GREEN}${PACKAGE_ID}${C_RESET}"

## 2. Install chaincode on all peers
infoln "Installing chaincode on Org1 peers..."
installChaincode 1 0
installChaincode 1 1
installChaincode 1 2

infoln "Installing chaincode on Org2 peers..."
installChaincode 2 0
installChaincode 2 1
installChaincode 2 2

resolveSequence

### query whether the chaincode is installed
#queryInstalled 1

## 3. Approve the definition for each organization
infoln "Approving chaincode definition for Org1..."
approveForMyOrg 1

infoln "Approving chaincode definition for Org2..."
approveForMyOrg 2

## 4. Check commit readiness. This is the only check needed.
infoln "Checking if chaincode definition is ready to be committed..."
checkCommitReadiness 1 "\"Org1MSP\": true" "\"Org2MSP\": true"
checkCommitReadiness 2 "\"Org1MSP\": true" "\"Org2MSP\": true"

## 5. Commit the chaincode definition
infoln "Committing chaincode definition..."
commitChaincodeDefinition 1 2

## 6. Query the committed chaincode definition on all orgs
infoln "Querying committed definition on Org1..."
queryCommitted 1
infoln "Querying committed definition on Org2..."
queryCommitted 2

## 7. Initialize the chaincode if required
if [ "$CC_INIT_FCN" != "NA" ]; then
  infoln "Initializing chaincode..."
  chaincodeInvokeInit 1 2
else
  infoln "Chaincode initialization is not required."
fi

println "✅ Chaincode deployment successful."
exit 0
