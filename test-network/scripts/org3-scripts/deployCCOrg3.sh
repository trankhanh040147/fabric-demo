#!/usr/bin/env bash

# Kịch bản này được thiết kế để chạy sau khi Org3 đã được thêm vào channel.
# Nó cài đặt một chaincode đã tồn tại lên các peer của Org3 và để Org3
# phê duyệt định nghĩa chaincode đã được kích hoạt trên channel.

## Thoát ngay khi có lỗi
#set -e

# --- Import các hàm tiện ích ---
source scripts/utils.sh

# --- Tham số mặc định ---
CHANNEL_NAME=${1:-"mychannel"}
CC_NAME=${2}
CC_SRC_PATH=${3}
CC_SRC_LANGUAGE=${4}
CC_VERSION=${5:-"1.0"} # Phiên bản phải khớp với chaincode đã deploy

# --- In ra các tham số ---
println "executing with the following for Org3"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"

# don't delete this
FABRIC_CFG_PATH=$PWD/../config/

# --- Import các kịch bản helper ---
. scripts/envVar.sh
. scripts/ccutils.sh

# --- Logic chính ---

## 1. Đóng gói Chaincode
# Chúng ta phải đóng gói lại chaincode để đảm bảo có đúng package ID.
# Mã nguồn phải giống hệt với phiên bản đã được deploy cho Org1 & Org2.
infoln "Packaging chaincode..."
./scripts/packageCC.sh "$CC_NAME" "$CC_SRC_PATH" "$CC_SRC_LANGUAGE" "$CC_VERSION"

infoln "Calculating chaincode package ID..."
export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CC_NAME}.tar.gz)
println "Package ID is: ${C_GREEN}${PACKAGE_ID}${C_RESET}"

## 2. Truy vấn Channel để lấy Sequence hiện tại
# Org3 phải phê duyệt đúng sequence number đang hoạt động trên channel.
infoln "Querying channel for current sequence..."
# Sử dụng peer0.org1 để truy vấn, vì họ là thành viên của channel
setGlobals 1 0

# Chạy truy vấn và phân tích output. Xử lý trường hợp không tìm thấy chaincode.
QUERY_OUTPUT=$(peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CC_NAME} -O json || echo "{}")
CURRENT_SEQUENCE=$(echo ${QUERY_OUTPUT} | jq -r .sequence)

if [ -z "$CURRENT_SEQUENCE" ] || [ "$CURRENT_SEQUENCE" == "null" ]; then
  errorln "Chaincode '${CC_NAME}' not found on channel '${CHANNEL_NAME}'. Please deploy to Org1/Org2 first."
  exit 1
fi

println "Current sequence on channel is: ${C_GREEN}${CURRENT_SEQUENCE}${C_RESET}"
export CC_SEQUENCE=${CURRENT_SEQUENCE}


## 3. Cài đặt Chaincode lên tất cả các peer của Org3
infoln "Installing chaincode on Org3 peers..."
installChaincode 3 0
installChaincode 3 1
installChaincode 3 2

## 4. Phê duyệt định nghĩa Chaincode cho Org3
infoln "Approving chaincode definition for Org3..."
# Hàm approveForMyOrg sẽ sử dụng biến CC_SEQUENCE đã được export ở trên
approveForMyOrg 3

### 5. Xác minh sự phê duyệt của Org3
#infoln "Verifying commit readiness with Org3's approval..."
#checkCommitReadiness 3 "\"Org1MSP\": true" "\"Org2MSP\": true" "\"Org3MSP\": true"

println "✅ Chaincode đã được cài đặt và phê duyệt cho Org3 thành công."
println "➡️ Bước tiếp theo: Nâng cấp định nghĩa chaincode trên channel với một chính sách chứng thực (endorsement policy) mới bao gồm cả Org3."
exit 0
