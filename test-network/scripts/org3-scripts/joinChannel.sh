#!/usr/bin/env bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# This script joins all peers of Org3 to an existing channel.
# It fetches the latest configuration block and then joins each peer.

## Exit on first error
#set -e

# --- Set Defaults ---
CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="mychannel"}
DELAY=3
MAX_RETRY=5
VERBOSE=false

# --- Import helpers ---
# Get the root directory of the project to make paths robust
ROOTDIR=$(cd "$(dirname "$0")" && pwd)
export TEST_NETWORK_HOME="$ROOTDIR/.."

. "${TEST_NETWORK_HOME}/scripts/envVar.sh"
. "${TEST_NETWORK_HOME}/scripts/utils.sh"

infoln "Joining Org3 to channel '${CHANNEL_NAME}'"

# --- 1. Fetch the latest channel config block ---
# We need this so Org3 can learn about the channel.
# We'll use peer0.org3 to do the fetching.
infoln "Fetching the latest channel configuration block..."
setGlobals 3 0
BLOCKFILE="${TEST_NETWORK_HOME}/channel-artifacts/${CHANNEL_NAME}.block"

set -x
peer channel fetch 0 ${BLOCKFILE} -c ${CHANNEL_NAME} -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA"
res=$?
{ set +x; } 2>/dev/null
verifyResult $res "Failed to fetch latest channel config block."


# --- 2. Join all Org3 peers to the channel ---
# This function joins a specific peer of Org3
joinPeer() {
  local PEER=$1
  infoln "Joining peer${PEER}.org3 to the channel..."
  setGlobals 3 ${PEER}
  local rc=1
  local COUNTER=1
  ## Sometimes Join takes time, hence retry
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b $BLOCKFILE >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    let rc=$res
    COUNTER=$(expr $COUNTER + 1)
  done
  cat log.txt
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org3 has failed to join channel '$CHANNEL_NAME' "
}

setAnchorPeer() {
  ORG=$1
  . scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME
}

# Join each peer
joinPeer 0
joinPeer 1
joinPeer 2


# --- 3. Set the anchor peer for Org3 ---
infoln "Setting anchor peer for org3..."
setAnchorPeer 3


successln "✅ Org3 successfully joined channel '${CHANNEL_NAME}'"
exit 0
