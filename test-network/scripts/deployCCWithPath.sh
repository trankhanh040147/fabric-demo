#!/usr/bin/env bash

# --- Source Utilities ---
source scripts/utils.sh

# --- Default Parameters ---
CHANNEL_NAME="mychannel"
CC_NAME=""
CC_SRC_LANGUAGE=""
CC_VERSION="1.0"
CC_SEQUENCE="1"
CC_INIT_FCN="NA"
CC_END_POLICY="NA"
CC_COLL_CONFIG="NA"
DELAY="3"
MAX_RETRY="5"
VERBOSE="false"
NUM_ORGS=2
CC_SRC_PATHS=()

# --- Help Function ---
function printHelp() {
  println "Deploy chaincode with a different source path for each organization."
  println "Each organization will package, install, and approve its own chaincode binary."
  println
  println "Usage: "
  println "  deployCCWithPath.sh [Flags]"
  println
  println "Flags:"
  println "  -h                    Show this help message"
  println "  -c <channel_name>     Name of the channel (Default: 'mychannel')"
  println "  -ccn <chaincode_name> Name of the chaincode (Required)"
  println "  -ccl <language>       Language of the chaincode (e.g., 'go', 'java', 'node') (Required)"
  println "  -ccp <path>           Path to the chaincode source. Use this flag for each organization."
  println "  -norgs <number>       Total number of organizations (Default: 2). Must match the number of -ccp flags."
  println "  -ccv <version>        Chaincode version (Default: '1.0')"
  println "  -ccs <sequence>       Chaincode definition sequence (Default: '1')"
  # ... (các flag khác có thể được thêm vào đây nếu cần)
  println
  println "Example:"
  println "  ./scripts/deployCCWithPath.sh -c mychannel -ccn basic -ccl go -norgs 3 -ccp ../path/org1 -ccp ../path/org2 -ccp ../path/org3"
}


# --- Argument Parser ---
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -h) printHelp; exit 0 ;;
  -c) CHANNEL_NAME="$2"; shift ;;
  -ccn) CC_NAME="$2"; shift ;;
  -ccl) CC_SRC_LANGUAGE="$2"; shift ;;
  -ccp) CC_SRC_PATHS+=("$2"); shift ;;
  -norgs) NUM_ORGS="$2"; shift ;;
  -ccv) CC_VERSION="$2"; shift ;;
  -ccs) CC_SEQUENCE="$2"; shift ;;
  -cci) CC_INIT_FCN="$2"; shift ;;
  -ccep) CC_END_POLICY="$2"; shift ;;
  -cccg) CC_COLL_CONFIG="$2"; shift ;;
  *) errorln "Unknown flag: $key"; printHelp; exit 1 ;;
  esac
  shift
done

# --- Validate Parameters ---
if [ -z "$CC_NAME" ] || [ -z "$CC_SRC_LANGUAGE" ] || [ ${#CC_SRC_PATHS[@]} -eq 0 ] || [ ${#CC_SRC_PATHS[@]} -ne "$NUM_ORGS" ]; then
    errorln "Invalid arguments. Use -h for help."
    exit 1
fi

# --- Print Parameters ---
println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- NUM_ORGS: ${C_GREEN}${NUM_ORGS}${C_RESET}"
# ... (in các tham số khác nếu cần)

# --- Argument Parsing for Fabric Flags ---
INIT_REQUIRED="--init-required"
[ "$CC_INIT_FCN" = "NA" ] && INIT_REQUIRED=""
[ "$CC_END_POLICY" != "NA" ] && CC_END_POLICY="--signature-policy $CC_END_POLICY" || CC_END_POLICY=""
[ "$CC_COLL_CONFIG" != "NA" ] && CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG" || CC_COLL_CONFIG=""

export FABRIC_CFG_PATH=$PWD/../config/

# --- Import helpers ---
. scripts/envVar.sh
. scripts/ccutils.sh

# --- Main Logic ---

# Mảng kết hợp để lưu trữ Package ID cho mỗi tổ chức
declare -A ORG_PACKAGE_IDS

## 1. Package and Install Chaincode for each Organization
for i in $(seq 1 "$NUM_ORGS"); do
    ORG_INDEX=$((i-1))
    CC_SRC_PATH_ORG="${CC_SRC_PATHS[$ORG_INDEX]}"
    PACKAGE_FILE="${CC_NAME}_org${i}.tar.gz"

    infoln "--- Processing for Org${i} ---"
    infoln "Packaging chaincode from path: ${CC_SRC_PATH_ORG}"

    # Tạm thời đổi tên file package mặc định để tránh ghi đè
    ./scripts/packageCC.sh "$CC_NAME" "$CC_SRC_PATH_ORG" "$CC_SRC_LANGUAGE" "$CC_VERSION"
    if [ $? -ne 0 ]; then
        fatalln "Failed to package chaincode for Org${i}. Exiting."
    fi
    mv "${CC_NAME}.tar.gz" "$PACKAGE_FILE"

    infoln "Calculating Package ID for Org${i}..."
    ORG_PACKAGE_IDS[$i]=$(peer lifecycle chaincode calculatepackageid "$PACKAGE_FILE")
    verifyResult $? "Calculating package ID for Org${i} failed"
    println "Package ID for Org${i} is: ${C_GREEN}${ORG_PACKAGE_IDS[$i]}${C_RESET}"

    infoln "Installing chaincode on peers of Org${i}..."
    # Giả sử mỗi org có 3 peer: 0, 1, 2. Chỉnh sửa nếu cần.
    installChaincode "$i" 0 "$PACKAGE_FILE"
    installChaincode "$i" 1 "$PACKAGE_FILE"
    installChaincode "$i" 2 "$PACKAGE_FILE"
done

## 2. Resolve sequence (only needs to be done once)
resolveSequence

## 3. Approve Chaincode Definition for each Organization
for i in $(seq 1 "$NUM_ORGS"); do
    infoln "Approving chaincode definition for Org${i}..."
    export PACKAGE_ID=${ORG_PACKAGE_IDS[$i]} # Đặt Package ID đúng cho tổ chức hiện tại
    approveForMyOrg "$i"
done

## 4. Check Commit Readiness and Commit
infoln "Building dynamic arguments for commit readiness check..."
CHECK_COMMIT_READINESS_ARGS=()
for i in $(seq 1 "$NUM_ORGS"); do
    CHECK_COMMIT_READINESS_ARGS+=("\"Org${i}MSP\": true")
done

infoln "Checking if chaincode definition is ready for ${NUM_ORGS} Orgs..."
for i in $(seq 1 "$NUM_ORGS"); do
    checkCommitReadiness "$i" "${CHECK_COMMIT_READINESS_ARGS[@]}"
done

COMMIT_ARGS=$(seq 1 "$NUM_ORGS")
infoln "Committing chaincode definition for ${NUM_ORGS} Orgs..."
commitChaincodeDefinition ${COMMIT_ARGS}

## 5. Query Committed Definition
for i in $(seq 1 "$NUM_ORGS"); do
    infoln "Querying committed definition on Org${i}..."
    queryCommitted "$i"
done

## 6. Initialize (if required)
if [ "$CC_INIT_FCN" != "NA" ]; then
    infoln "Initializing chaincode..."
    chaincodeInvokeInit ${COMMIT_ARGS}
else
    infoln "Chaincode initialization is not required."
fi

println "✅ Chaincode deployment successful with organization-specific binaries."
exit 0
