#!/usr/bin/env bash


# This function creates all the identities and MSP materials for Org1.
# It's updated to accept the number of peers to create as an argument.
#
# Usage: createOrg1 [number_of_peers]
# Example: createOrg1 3  (This will create peer0, peer1, and peer2 for Org1)
#
function createOrg1() {
  # The first argument specifies the number of peers; defaults to 1 if not provided.
  local NUM_PEERS=${1:-1}
  infoln "Creating Org1 with ${NUM_PEERS} peer(s)..."
  infoln "Enrolling the CA admin"

  # Create the directory for Org1's peer organization materials
  mkdir -p organizations/peerOrganizations/org1.example.com/

  # Set the Fabric CA client home directory to the Org1 peer organization directory
  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/

  # Enroll the CA admin
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Create the MSP configuration file
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml"

  # Copy the CA root certificate to the MSP and tlsca directories
  mkdir -p "${PWD}/organizations/peerOrganizations/org1.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/org1/ca-cert.pem" "${PWD}/organizations/peerOrganizations/org1.example.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/org1.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/org1/ca-cert.pem" "${PWD}/organizations/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/org1.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/org1/ca-cert.pem" "${PWD}/organizations/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem"

  # --- Loop to generate identities and MSPs for each peer ---
  for ((i=0; i<NUM_PEERS; i++)); do
    infoln "Registering peer${i}"
    set -x
    fabric-ca-client register --caname ca-org1 --id.name "peer${i}" --id.secret "peer${i}pw" --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
    { set +x; } 2>/dev/null

    infoln "Generating the peer${i} msp"
    set -x
    fabric-ca-client enroll -u "https://peer${i}:peer${i}pw@localhost:7054" --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
    { set +x; } 2>/dev/null

    # Copy the MSP config to the peer's MSP directory
    cp "${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/msp/config.yaml"

    infoln "Generating the peer${i}-tls certificates"
    set -x
    fabric-ca-client enroll -u "https://peer${i}:peer${i}pw@localhost:7054" --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/tls" --enrollment.profile tls --csr.hosts "peer${i}.org1.example.com" --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
    { set +x; } 2>/dev/null

    # Copy the TLS CA cert, server cert, and server keystore to well-known file names
    cp "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/tls/ca.crt"
    cp "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/tls/server.crt"
    cp "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/tls/server.key"
  done
  # --- End of peer generation loop ---

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/config.yaml"
}

# Function to set up Org2 with a dynamic number of peers.
# Usage: createOrg2 [number_of_peers]
# Example: createOrg2 3  (This will create peer0, peer1, and peer2 for Org2)
function createOrg2() {
  # The first argument specifies the number of peers; defaults to 1 if not provided.
  local NUM_PEERS=${1:-1}
  infoln "Creating Org2 with ${NUM_PEERS} peer(s)..."

  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org2.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-org2 --tls.certfiles "${PWD}/organizations/fabric-ca/org2/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories
  # Copy org2's CA cert to org2's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/org2.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/org2/ca-cert.pem" "${PWD}/organizations/peerOrganizations/org2.example.com/msp/tlscacerts/ca.crt"

  # Copy org2's CA cert to org2's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/org2.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/org2/ca-cert.pem" "${PWD}/organizations/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem"

  # Copy org2's CA cert to org2's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/org2.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/org2/ca-cert.pem" "${PWD}/organizations/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem"


  # --- Loop to generate identities and MSPs for each peer ---
  for ((i=0; i<NUM_PEERS; i++)); do
    infoln "Registering peer${i}"
    set -x
    fabric-ca-client register --caname ca-org2 --id.name "peer${i}" --id.secret "peer${i}pw" --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/org2/ca-cert.pem"
    { set +x; } 2>/dev/null

    infoln "Generating the peer${i} msp"
    set -x
    fabric-ca-client enroll -u "https://peer${i}:peer${i}pw@localhost:8054" --caname ca-org2 -M "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org2/ca-cert.pem"
    { set +x; } 2>/dev/null

    cp "${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/msp/config.yaml"

    infoln "Generating the peer${i}-tls certificates, use --csr.hosts to specify Subject Alternative Names"
    set -x
    fabric-ca-client enroll -u "https://peer${i}:peer${i}pw@localhost:8054" --caname ca-org2 -M "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/tls" --enrollment.profile tls --csr.hosts "peer${i}.org2.example.com" --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org2/ca-cert.pem"
    { set +x; } 2>/dev/null

    # Copy the tls CA cert, server cert, and server keystore to well-known file names
    cp "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/tls/ca.crt"
    cp "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/tls/server.crt"
    cp "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/tls/server.key"
  done
  # --- End of peer generation loop ---


  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org2/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/org2/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org2/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org2/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

# Loop through each orderer (orderer, orderer2, orderer3, orderer4) to register and generate artifacts
  for ORDERER in orderer orderer2 orderer3 orderer4; do
    infoln "Registering ${ORDERER}"
    set -x
    fabric-ca-client register --caname ca-orderer --id.name ${ORDERER} --id.secret ${ORDERER}pw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
    { set +x; } 2>/dev/null

    infoln "Generating the ${ORDERER} MSP"
    set -x
    fabric-ca-client enroll -u https://${ORDERER}:${ORDERER}pw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
    { set +x; } 2>/dev/null

    cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/config.yaml"

    # Workaround: Rename the signcert file to ensure consistency with Cryptogen generated artifacts
    mv "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/signcerts/cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/signcerts/${ORDERER}.example.com-cert.pem"

    infoln "Generating the ${ORDERER} TLS certificates, use --csr.hosts to specify Subject Alternative Names"
    set -x
    fabric-ca-client enroll -u https://${ORDERER}:${ORDERER}pw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls" --enrollment.profile tls --csr.hosts ${ORDERER}.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
    { set +x; } 2>/dev/null

    # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
    cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/ca.crt"
    cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/server.crt"
    cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/server.key"

    # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
    mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/tlscacerts"
    cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
  done

  # Register and generate artifacts for the orderer admin
  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}
