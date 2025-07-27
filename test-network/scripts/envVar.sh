#!/usr/bin/env bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
# test network home var targets to test-network folder
# the reason we use a var here is to accommodate scenarios
# where execution occurs from folders outside of default as $PWD, such as the test-network/addOrg3 folder.
# For setting environment variables, simple relative paths like ".." could lead to unintended references
# due to how they interact with FABRIC_CFG_PATH. It's advised to specify paths more explicitly,
# such as using "../${PWD}", to ensure that Fabric's environment variables are pointing to the correct paths.
TEST_NETWORK_HOME=${TEST_NETWORK_HOME:-${PWD}}
. ${TEST_NETWORK_HOME}/scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem
export PEER0_ORG2_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem
export PEER0_ORG3_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org3.example.com/tlsca/tlsca.org3.example.com-cert.pem

# Set environment variables for the peer org
#
# Sets the correct environment variables for the peer CLI
#
# @param ORG The organization number to use.
# @param PEER The peer number to use (defaults to 0).
#
setGlobals() {
  local ORG=$1
  # Default to peer 0 if the second argument is not provided
  local PEER=${2:-0}

  infoln "Using organization ${ORG} and peer ${PEER}"

  if [ $ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/peers/peer${PEER}.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    case $PEER in
          0)
            export CORE_PEER_ADDRESS=localhost:7051
            ;;
          1)
            export CORE_PEER_ADDRESS=localhost:9051
            ;;
          2)
            export CORE_PEER_ADDRESS=localhost:9151
            ;;
          *)
            errorln "Unknown peer ${PEER} for Org1"
            exit 1
            ;;
        esac

  elif [ $ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org2.example.com/peers/peer${PEER}.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
#    # This logic assumes peer0 is on 9051, peer1 is on 10051, etc.
    # peer0:8100, peer1:8120, peer2:8140
    export CORE_PEER_ADDRESS=localhost:$((8100 + PEER * 20))

  elif [ $ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org3.example.com/peers/peer${PEER}.org3.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
#    # This logic assumes peer0 is on 11051, peer1 is on 12051, etc.
#    export CORE_PEER_ADDRESS=localhost:$((11051 + PEER * 1000))
     # peer0:8200, peer1:8220, peer2:8240
     export CORE_PEER_ADDRESS=localhost:$((8200 + PEER * 20))

  else
    errorln "Unknown organization ${ORG}"
    exit 1
  fi

  if [ "$VERBOSE" = "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_ORG$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
