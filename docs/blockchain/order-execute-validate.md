Fabric introduces a new architecture for transactions that we call **execute-order-validate**. It addresses the resiliency, flexibility, scalability, performance and confidentiality challenges faced by the order-execute model by separating the transaction flow into three steps:

- _execute_ a transaction and check its correctness, thereby endorsing it,
    
- _order_ transactions via a (pluggable) consensus protocol, and
    
- _validate_ transactions against an application-specific endorsement policy before committing them to the ledger
    

This design departs radically from the order-execute paradigm in that Fabric executes transactions before reaching final agreement on their order.

In Fabric, an application-specific endorsement policy specifies which peer nodes, or how many of them, need to vouch for the correct execution of a given smart contract. Thus, each transaction need only be executed (endorsed) by the subset of the peer nodes necessary to satisfy the transaction’s endorsement policy. This allows for parallel execution increasing overall performance and scale of the system. This first phase also **eliminates any non-determinism**, as inconsistent results can be filtered out before ordering.

Because we have eliminated non-determinism, Fabric is the first blockchain technology that **enables use of standard programming languages**.

---
## Q: If an end user want to create and send transaction ? How the process happens ?
>Primarily, smart contracts are used to generate transactions which are subsequently distributed to every peer node in the network where they are immutably recorded on their copy of the ledger. The users of applications might be end users using client applications or blockchain network administrators. 

Of course. When an end user wants to create and send a transaction in Hyperledger Fabric, the process doesn't happen in a single step. It follows a structured, three-phase flow called **"execute-order-validate"** to ensure trust and consistency among all network participants.

The end user interacts with a **client application**, which acts on their behalf to drive the entire process.

---

### **The 3 Phases of a Fabric Transaction**

Here’s a step-by-step breakdown of how a transaction goes from a user's request to being permanently recorded on the ledger.

#### **Phase 1: Proposal and Endorsement (Execute)** ✍️

This phase is about getting the required signatures for the proposed transaction.

1. **Create Proposal**: The end user, through a client application, creates a **transaction proposal**. This proposal specifies which **chaincode** (smart contract) to invoke, the function to run, and the input values.
    
2. **Send to Endorsers**: The client application sends this proposal to a set of **endorsing peer nodes**, as defined by the chaincode's **endorsement policy**. An endorsement policy might require, for example, "a signature from a peer in Organization A AND a peer in Organization B."
    
3. **Simulate and Sign**: Each endorsing peer receives the proposal and **simulates** the transaction by running the chaincode function on its local copy of the ledger. It does **not** update the ledger yet. It only generates a result, which includes a "read-write set" (what was read from the ledger and what would be written).
    
4. **Return Signed Proposal**: If the simulation is successful, the peer signs the result with its private key and sends the signed **proposal response** back to the client application.
    

At the end of this phase, the client application has a collection of signed endorsements, effectively acting as "proof" that the required organizations agree with the transaction's outcome.

---

#### **Phase 2: Ordering (Order)** 📦

This phase is about establishing a definitive chronological order for all transactions in the network.

1. **Assemble Transaction**: The client application verifies that the endorsements are valid and collects them into a single, complete **transaction**. This package includes the original proposal, the signed responses, and the end user's own signature.
    
2. **Submit to Orderer**: The client sends this complete transaction to the **Ordering Service** (or "Orderer"). The Orderer's job is not to check the transaction's content but simply to establish a consensus on the order of transactions.
    
3. **Create Block**: The Ordering Service receives transactions from all client applications across the network, orders them into a well-defined sequence, and packages them into a **block**.
    

---

#### **Phase 3: Validation and Commit (Validate)** ✅

This is the final phase where the transaction is checked one last time and officially recorded.

1. **Distribute Block**: The Ordering Service broadcasts the newly created block to all peer nodes in the channel.
    
2. **Validate Each Transaction**: Every peer in the channel receives the block and begins validating each transaction within it. This crucial check involves two steps:
    
    - **Endorsement Policy Check**: The peer verifies that the transaction has been signed by the correct set of endorsing peers according to the endorsement policy.
        
    - **Ledger Consistency Check**: The peer checks the "read set" from the transaction to ensure that no other transaction has modified the same data since the transaction was first simulated in Phase 1. This prevents "double-spending" and ensures data integrity.
        
3. **Commit to Ledger**: If a transaction passes both validation checks, the peer updates its ledger. The block is appended to the blockchain, and the "write set" is used to update the current state database (the "world state"). Transactions that fail validation are marked as invalid but are still retained on the blockchain for auditability, though they do not update the world state.
    
4. **Notify Client**: The peer can then send an event to the client application to notify the end user that their transaction has been successfully committed to the ledger.
