#!/usr/bin/env bash

## Exit on first error
#set -e

source scripts/utils.sh

# --- Parameter Defaults ---
# Các tham số này sẽ được ghi đè bởi các cờ được truyền vào
CHANNEL_NAME="mychannel"
CC_NAME=""
CC_SRC_LANGUAGE=""
CC_VERSION="1.0"
CC_SEQUENCE="1"
CC_INIT_FCN="NA"
CC_END_POLICY="NA"
CC_COLL_CONFIG="NA"
NUM_ORGS=2
CC_SRC_PATHS=() # Mảng để lưu trữ các đường dẫn chaincode

# --- Parse Flags ---
# Vòng lặp này sẽ trích xuất tất cả các tham số từ dòng lệnh
while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -c )
    CHANNEL_NAME="$2"
    shift
    ;;
  -ccn )
    CC_NAME="$2"
    shift
    ;;
  -ccl )
    CC_SRC_LANGUAGE="$2"
    shift
    ;;
  -ccv )
    CC_VERSION="$2"
    shift
    ;;
  -ccs )
    CC_SEQUENCE="$2"
    shift
    ;;
  -ccp ) # Xử lý đặc biệt cho nhiều đường dẫn
    CC_SRC_PATHS+=("$2")
    shift
    ;;
  -ccep )
    CC_END_POLICY="$2"
    shift
    ;;
  -cccg )
    CC_COLL_CONFIG="$2"
    shift
    ;;
  -cci )
    CC_INIT_FCN="$2"
    shift
    ;;
  -norgs )
    NUM_ORGS="$2"
    shift
    ;;
  * )
    # Bỏ qua các cờ không xác định
    ;;
  esac
  shift
done


# --- Print Parameters ---
println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_COLL_CONFIG: ${C_GREEN}${CC_COLL_CONFIG}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- NUM_ORGS: ${C_GREEN}${NUM_ORGS}${C_RESET}"
for i in $(seq 1 $NUM_ORGS); do
  path_index=$((i-1))
  println "- CC_SRC_PATH_ORG${i}: ${C_GREEN}${CC_SRC_PATHS[$path_index]}${C_RESET}"
done


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

# --- Main Deployment Logic ---

# Vòng lặp để đóng gói, cài đặt và phê duyệt cho từng tổ chức
for i in $(seq 1 $NUM_ORGS); do
  path_index=$((i-1))
  ORG_CC_SRC_PATH=${CC_SRC_PATHS[$path_index]}
  ORG_CC_PKG_NAME="${CC_NAME}_org${i}.tar.gz"

  infoln "--- Processing for Org${i} ---"
  infoln "Packaging chaincode from path: ${ORG_CC_SRC_PATH}"
  ./scripts/packageCC.sh "$CC_NAME" "$ORG_CC_SRC_PATH" "$CC_SRC_LANGUAGE" "$CC_VERSION" "$ORG_CC_PKG_NAME"

  infoln "Calculating package ID for Org${i}..."
  export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid $ORG_CC_PKG_NAME)
  println "Package ID for Org${i} is: ${C_GREEN}${PACKAGE_ID}${C_RESET}"

  infoln "Installing chaincode for Org${i}..."
  installChaincode ${i} 0 ${ORG_CC_PKG_NAME}
  installChaincode ${i} 1 ${ORG_CC_PKG_NAME}
  installChaincode ${i} 2 ${ORG_CC_PKG_NAME}

  infoln "Approving chaincode definition for Org${i}..."
  approveForMyOrg ${i}
done

# --- Các bước commit và query chung cho cả channel ---

## Check commit readiness and Commit the chaincode definition
if [ "$NUM_ORGS" -ge 3 ]; then
  infoln "Checking if chaincode definition is ready for 3 Orgs..."
  checkCommitReadiness 1 "\"Org1MSP\": true" "\"Org2MSP\": true" "\"Org3MSP\": true"
  checkCommitReadiness 2 "\"Org1MSP\": true" "\"Org2MSP\": true" "\"Org3MSP\": true"
  checkCommitReadiness 3 "\"Org1MSP\": true" "\"Org2MSP\": true" "\"Org3MSP\": true"

  infoln "Committing chaincode definition for 3 Orgs..."
  commitChaincodeDefinition 1 2 3
else
  infoln "Checking if chaincode definition is ready for 2 Orgs..."
  checkCommitReadiness 1 "\"Org1MSP\": true" "\"Org2MSP\": true"
  checkCommitReadiness 2 "\"Org1MSP\": true" "\"Org2MSP\": true"

  infoln "Committing chaincode definition for 2 Orgs..."
  commitChaincodeDefinition 1 2
fi


## Query the committed chaincode definition on all orgs
infoln "Querying committed definition on all Orgs..."
for i in $(seq 1 $NUM_ORGS); do
  queryCommitted ${i}
done

## Initialize the chaincode if required
if [ "$CC_INIT_FCN" != "NA" ]; then
  infoln "Initializing chaincode..."
  if [ "$NUM_ORGS" -ge 3 ]; then
    chaincodeInvokeInit 1 2 3
  else
    chaincodeInvokeInit 1 2
  fi
else
  infoln "Chaincode initialization is not required."
fi

println "✅ Chaincode deployment with distinct paths successful."
exit 0
