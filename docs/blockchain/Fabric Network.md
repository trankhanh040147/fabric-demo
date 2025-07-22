[Fabric Network without system channel (Fabric 2.5)](https://hyperledger-fabric.readthedocs.io/en/release-2.5/network/network.html#)

[Fabric Network with a system channel (Fabric 2.2)](https://hyperledger-fabric.readthedocs.io/en/release-2.5/test_network.html)

---
### Q: Difference between a network with system channel with network w/o system channel ?
## Q: Is that true chaincode consists of ledger and smart contract ?
> A blockchain network is a technical infrastructure that provides ledger and smart contract (which are packaged as part of a “chaincode”

#### 1. The Ledger: The Distributed System of Record

The Ledger is the heart of a Hyperledger Fabric network. It is a sequenced, tamper-resistant record of all state transitions for a channel. Unlike a monolithic database, the Fabric ledger is comprised of two distinct, though related, parts:

- **The World State:** The world state represents the _current values_ of all keys in the ledger. It is a database that provides an efficient way for applications to get the present value of an asset or entity without having to traverse the entire transaction log. The world state is expressed as a key-value store and can be implemented with either LevelDB (default) or CouchDB.
    
    - **Key Advantage:** Using CouchDB enables rich JSON queries against the world state, allowing for complex, real-time data retrieval that is essential for many enterprise applications.
    - **Role:** It is the "current state" snapshot, optimized for reads.
- **The Blockchain (Transaction Log):** The blockchain is the immutable, append-only log that records the complete history of all transactions that resulted in the current world state. It is a chain of cryptographically linked blocks, where each block contains a batch of ordered transactions.
    
    - **Key Advantage:** This log provides the definitive, auditable history of the system. It is the ultimate source of truth. The world state can always be regenerated from the blockchain by replaying the transactions from the genesis block forward.
    - **Role:** It is the "transaction history," optimized for immutability and auditability.

In essence, the Ledger combines the efficiency of a key-value database (the world state) with the integrity and auditability of a blockchain (the transaction log).

#### 2. The Smart Contract: The Business Logic

A Smart Contract defines the executable business logic and rules that govern how the ledger's state can be modified. It is not the code itself, but rather the set of transaction functions that applications can invoke to interact with the ledger.

- **Function:** It contains the business rules of the system. For example, in an asset transfer application, the smart contract would define functions like `createAsset`, `queryAsset`, and `transferAsset`.
- **Encapsulation:** The `transferAsset` function would encapsulate the logic required for a valid transfer, such as verifying the identity of the asset's owner, confirming the asset is not locked, and executing the change of ownership.
- **Scope:** A smart contract is focused on a specific business process. A complex application may involve multiple smart contracts.

Think of the smart contract as the "contractual" part of the system—it defines the agreed-upon rules that all participants must adhere to when changing the state of the ledger.

#### 3. The Chaincode: The Deployed Application Package

Chaincode is the technical container—the packaged code—that houses one or more smart contracts. It is the unit of deployment in Hyperledger Fabric.

- **Packaging:** Developers write their smart contract logic in a general-purpose programming language (e.g., Go, Node.js, Java). This code, along with any necessary dependencies, is packaged into a chaincode archive.
- **Lifecycle Management:** This chaincode package is what is managed by the Fabric network administrators. Its lifecycle involves:
    1. **Installation:** The chaincode package is installed on the peers that need to endorse transactions.
    2. **Approval & Commitment:** The organization administrators on a channel approve a chaincode definition, which is then committed to the channel. This action makes the smart contracts within the chaincode active and available for invocation by client applications.
- **Execution Environment:** When a transaction is invoked, the chaincode is executed in a secure, isolated environment (e.g., a Docker container) on the endorsing peer.

A single chaincode package can contain a single smart contract or a collection of related smart contracts. This allows for modular management of on-chain logic.

### Correcting the Misconception: The Precise Interrelationship

The common misconception is that chaincode _is_ the ledger and smart contract combined. This is incorrect. The relationship is one of execution and interaction, not containment.

**The correct model is as follows:**

**Chaincode _executes_ Smart Contract logic to _propose updates_ to the Ledger.**

Here is the precise flow:

1. A client application initiates a transaction by sending a proposal to an endorsing peer. This proposal targets a specific **Smart Contract** function within a specific **Chaincode**.
2. The peer invokes the target **Chaincode**, which runs in a separate, isolated container.
3. The **Chaincode** executes the requested **Smart Contract** function. This function's code uses a provided API (the chaincode shim) to interact with the **Ledger's** world state (e.g., `getState()` to read data, `putState()` to propose a write).
4. The execution generates a "Read-Write Set" (RWSet), which details the keys that were read and the new values that are being proposed for writing. The chaincode _does not_ modify the ledger directly.
5. The peer signs this RWSet, creating an endorsement, and returns it to the client.
6. Once the client collects enough endorsements to satisfy the channel's endorsement policy, it submits the transaction (containing the proposal, RWSet, and endorsements) to the ordering service.
7. The ordering service sequences the transactions into a block and delivers it to all peers on the channel.
8. Each peer validates the transaction. It checks the endorsements and verifies that the data read in the RWSet has not been modified by another transaction since the chaincode was executed.
9. If the transaction is valid, the peer commits it to its local **Ledger**, appending the new block to the blockchain and updating the world state with the values from the RWSet.

### Analogy to a Traditional Three-Tier Architecture

To crystallize these concepts, consider the following analogy to a standard enterprise application stack.

- **The Ledger (World State)** is the **Database** (e.g., PostgreSQL, Oracle).
    
    - It is the persistence layer responsible for storing the current state of the application's data. It is optimized for efficient queries and retrieval of this current state.
- **The Smart Contract** is the **Business Logic / API Layer** (e.g., a REST API built with Spring Boot or Express.js).
    
    - It defines the available operations (`GET /api/users`, `POST /api/orders`) and enforces the business rules that govern how the database state can be manipulated. You interact with the API, not the database directly.
- **The Chaincode** is the **Deployed Application Package** (e.g., a `.war` file, a Docker image, a serverless function bundle).
    
    - It is the versioned, deployable artifact that contains the compiled business logic (the API) and all its dependencies. This package is what you deploy onto an application server (the peer). The server runs this package, thereby exposing the API endpoints (the smart contract functions) to the outside world.

In this analogy, you would never say a Docker image _consists of_ the database. Instead, the running container (Chaincode) executes business logic (Smart Contract) to interact with the database (Ledger). The same separation of concerns applies directly to Hyperledger Fabric.

---
