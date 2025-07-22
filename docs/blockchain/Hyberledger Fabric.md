# **How can Fabric supports pluggable consensus protocol ?**

Of course. This means you can choose the right "voting system" for your specific needs, rather than being stuck with a single, one-size-fits-all method.

Think of it like choosing an engine for a vehicle. You wouldn't put a massive, heavy-duty truck engine in a small city car because it would be inefficient and wasteful. You pick the engine that fits the vehicle's purpose.

In blockchain, this "voting system" is called a **consensus protocol**. It's how the network members agree that a transaction is valid before adding it to the ledger. Fabric lets you "plug in" the one that best suits your use case.

The two main types mentioned are Crash Fault-Tolerant (CFT) and Byzantine Fault-Tolerant (BFT).

---
# **Differences between [[Crash Fault-Tolerant]] vs [[Byzantine Fault-Tolerance]]**

Of course. This means you can choose the right "voting system" for your specific needs, rather than being stuck with a single, one-size-fits-all method.

Think of it like choosing an engine for a vehicle. You wouldn't put a massive, heavy-duty truck engine in a small city car because it would be inefficient and wasteful. You pick the engine that fits the vehicle's purpose.

In blockchain, this "voting system" is called a **consensus protocol**. It's how the network members agree that a transaction is valid before adding it to the ledger. Fabric lets you "plug in" the one that best suits your use case.

The two main types mentioned are Crash Fault-Tolerant (CFT) and Byzantine Fault-Tolerant (BFT).

### 🤝 Crash Fault-Tolerant (CFT)

This model is designed to handle simple failures, like a server crashing or going offline. It assumes that participants are **honest** and are not actively trying to cheat the system. If a participant stops working, it's considered an accident.

- **Trust Model:** High trust. Participants are cooperative.
    
- **Analogy:** Imagine a team of clerks counting votes. CFT ensures that if one clerk faints and falls over (a crash), the others can continue their work and still get the correct final count. It doesn't, however, protect against a clerk who is secretly trying to change votes.

### ⚔️ Byzantine Fault-Tolerant (BFT)

This is a much more robust and secure model. It's designed to handle "Byzantine faults," where participants can be malicious and actively try to corrupt the system by lying or sending conflicting information.

- **Trust Model:** Low trust or "zero trust." It assumes participants might be competitors or adversaries.
    
- **Analogy:** Now imagine the team of vote-counting clerks includes traitors who will lie and try to sabotage the outcome. BFT is a strict set of rules that ensures the honest clerks can still arrive at the correct final count, even with traitors in their midst. This requires more messaging and verification, making it slower.
    

### Real-World Examples

#### Example 1: Single Company running an Internal System (CFT is best)

- **Use Case:** A large supermarket chain like AEON uses a private Fabric network to track the movement of fresh produce from its own farms to its own warehouses and finally to its own stores.
    
- **Participants:** The farm, the warehouse, and the store are all part of the same company, AEON.
    
- **Why CFT?** There is a high level of trust. The warehouse has no reason to maliciously lie to the store. If a warehouse's server goes offline due to a power cut, that's a simple "crash." A lightweight, fast CFT consensus is perfect because it provides enough reliability without the performance cost of BFT.
    

#### Example 2: Competing Banks settling Financial Transactions (BFT is required)

- **Use Case:** A consortium of competing Vietnamese banks (e.g., Vietcombank, Techcombank, and ACB) forms a network to clear international payments between them.
    
- **Participants:** Three independent, competing companies.
    
- **Why BFT?** The trust level is low. While they've agreed to work together, they are still competitors. Techcombank needs a guarantee that Vietcombank cannot fake a transaction or block a legitimate one to gain an advantage. A highly secure BFT protocol is necessary to ensure the network is safe from malicious behavior, even though it may be slightly slower.
    

### Why Pluggable Consensus Matters

The ability to choose your consensus model is a major advantage. It allows organizations to build a blockchain network that is perfectly tailored to their needs, balancing performance and security. You don't have to use a slow, resource-intensive protocol (BFT) when a faster, simpler one (CFT) is more than adequate for your situation.

---
# How can Fabric do not require a native cryptocurrency

> Fabric can leverage consensus protocols that **do not require a native cryptocurrency** to incent costly mining or to fuel smart contract execution. Avoidance of a cryptocurrency reduces some significant risk/attack vectors, and absence of cryptographic mining operations means that the platform can be deployed with roughly the same operational cost as any other distributed system.

It works without a cryptocurrency because, in a private or permissioned network like Fabric, the **incentive to participate is based on business value, not on earning coins.**

In public blockchains like Bitcoin or Ethereum, a native cryptocurrency (like BTC or ETH) is essential to motivate anonymous strangers worldwide to secure the network. This process, called **mining**, is intentionally expensive and energy-intensive.

Fabric completely removes this requirement. Here’s how:

---

### Public vs. Permissioned Incentives

#### Public Blockchains (Bitcoin, Ethereum) 🪙

- **Participants:** Anonymous and untrusted.
    
- **Incentive:** **Cryptocurrency**. Anonymous "miners" spend vast amounts of computing power and electricity to validate transactions. They are rewarded with newly minted coins (e.g., Bitcoin) and transaction fees. Without this financial reward, no one would bother to run the network.
    
- **Security Model:** **Economic**. It's secure because attacking the network would require an immense, cost-prohibitive amount of computing power (a "51% attack").

#### Hyperledger Fabric (Permissioned) 🤝

- **Participants:** Known, verified, and trusted entities (e.g., a group of banks, a company's departments).
    
- **Incentive:** **Business Value**. The participants run the network because it benefits their business operations. For example, it might make their supply chain more efficient, reduce paperwork, or speed up financial settlements. Their reward is improved business performance, not a token.
    
- **Security Model:** **Governance**. The network is secured by the mutual self-interest of its members and the legal agreements they operate under. All participants are known, so any malicious activity can be traced and handled legally.
    

### How Fabric Reaches Agreement (Consensus)

Instead of costly mining, Fabric uses more traditional consensus protocols among its known participants. The nodes responsible for ordering transactions (the "Orderers") simply run an algorithm (like Raft for CFT) to agree on the sequence of transactions.

Because there is no mining, Fabric avoids:

- **High Energy Costs:** It doesn't need warehouses full of specialized computers running 24/7.
    
- **Attack Vectors:** It isn't vulnerable to attacks related to cryptocurrency market manipulation or mining pool takeovers.
    
- **Volatility:** Its operational costs are stable and predictable, like any standard IT system, as they aren't tied to a volatile crypto token.
    

In short, Fabric replaces the expensive, trustless incentive of cryptocurrency with the inherent business incentive that exists between collaborating organizations.

---
# Fabric supports pluggable identity management protocols,  what does it mean? 
> Hyperledger Fabric has been specifically architected to have a modular architecture. Whether it is pluggable consensus, pluggable identity management protocols such as LDAP or OpenID Connect, key management protocols or cryptographic libraries, the platform has been designed at its core to be configured to meet the diversity of enterprise use case requirements.

It means Fabric doesn't force you to use a built-in, proprietary system for managing user identities. Instead, it can connect to and use the existing identity management systems that a company already has in place.

Think of it like using your Google account to sign in to a new app. The app doesn't create its own password system for you; it "plugs into" Google's trusted identity service to verify who you are. Fabric does the same thing for large enterprises.

---

### How It Works: The Membership Service Provider (MSP)

Hyperledger Fabric manages identities through a component called the **Membership Service Provider (MSP)**. The MSP is an abstraction layer that dictates the rules for identifying and validating participants in the network.

Because this component is modular, it can be configured to work in different ways:

1. **Default Method:** By default, Fabric has its own certificate-based identity system. A **Certificate Authority (CA)** issues digital certificates to users, and these certificates act as their identity card on the network.
    
2. **Pluggable Method:** Instead of using the built-in CA, a company can configure its MSP to connect to its existing, centralized identity system. This is where protocols like LDAP and OpenID Connect come in.
    
    - **LDAP (Lightweight Directory Access Protocol):** This is a very common protocol used in corporate networks (often with Microsoft's Active Directory) to manage a central directory of all employees, their roles, and their permissions. Fabric can be configured so that when an employee tries to perform a transaction, the network checks with the company's LDAP server to confirm their identity and authority.
        
    - **OpenID Connect:** This is a more modern standard, often used for web applications. It allows you to verify a user's identity based on an existing account they have with a trusted provider, without sharing their actual password.
        

### Why This is Important for Enterprises

This pluggable identity feature is crucial for businesses because:

- **It uses existing infrastructure:** Companies have already invested heavily in robust identity systems like LDAP. They don't want to create and manage a whole new set of identities just for the blockchain network.
    
- **It simplifies user management:** When a new employee joins the company, they are added to the central LDAP directory. This can automatically grant them access to the Fabric network without any extra steps. Likewise, if an employee leaves, their access can be instantly revoked from one central place.
    
- **It enhances security:** It allows the blockchain to rely on the company's established, battle-tested security and authentication policies.
---
# So can Fabric works with my existed Oauth2 identity provider service  ?

Yes, it can, typically by using **OpenID Connect (OIDC)**, which is an identity layer built on top of OAuth 2.0.1

While Fabric doesn't integrate with raw OAuth 2.0 directly, most modern OAuth 2.0 identity providers (like Google, Azure Active Directory, Okta, etc.) also support OIDC.

---

### How It Works: The OIDC Bridge

The process allows a user to authenticate with your existing service to interact with the Fabric network.

1. **Authentication Request:** A user attempts to make a transaction on the Fabric network.
    
2. **Redirect to Provider:** The application redirects the user to your familiar OAuth 2.0 / OIDC login page.
    
3. **Login:** The user signs in with their standard company credentials.
    
4. **Identity Token:** Upon successful login, your identity provider issues an **ID Token** (this is the OIDC part) back to the application.2 This token securely contains information about the user's identity.
    
5. **Validation:** The application submits this ID Token to Fabric's **Membership Service Provider (MSP)**.
    
6. **Access Granted:** The MSP is configured to trust your identity provider. It validates the token, confirms the user's identity and permissions, and allows the transaction to proceed.
    

The key takeaway is that your identity service must support the **OpenID Connect (OIDC)** protocol. As long as it does, you can configure Fabric's MSP to "plug into" it and leverage your existing identity management system.

---
# Is smart contract = api service  ?

That's a very good analogy to start with, but there's a crucial difference. While they both expose business logic, how they run and manage data is fundamentally different.

A more accurate way to think about it is:

- An **API service with replicas** has multiple, independent copies running for performance and availability, all pointing to a **single, central database**.
    
- A **smart contract** is a **single, shared program** whose state and transaction history are replicated across all participants' nodes to ensure trust and decentralization.
    

---

### Key Differences Explained

Here is a breakdown of the comparison:

|Feature|API Service (with Replicas)|Smart Contract (Chaincode)|
|---|---|---|
|**State**|Each API instance is typically stateless. The "single source of truth" is a **centralized database**.|Each peer on the network holds a **replicated copy of the ledger** (the state database). The source of truth is decentralized.|
|**Trust**|You must **trust the owner** of the API and their central database (e.g., you trust Google to run Google Maps API correctly).|You **trust the code and the consensus protocol**. You don't need to trust the other participants because the network verifies every transaction.|
|**Execution**|A request is sent to a load balancer, which forwards it to **one** available API instance for processing.|A transaction proposal is sent to **many** peers. They **all execute the code independently** to verify the outcome before agreeing to commit the result to their copy of the ledger.|
|**Immutability**|The API owner can change the code or data in the database at any time, often without users knowing.|The transaction history is **immutable**. Once a transaction is agreed upon and written to the ledger, it cannot be changed.|

---

### Why "Untrusted Code" is a Key Concept

Your understanding connects directly to the three points you mentioned, especially that "**application code should be treated as untrusted**."

- With a normal API, you are forced to trust the provider.
    
- With a smart contract on Fabric, the system is designed precisely for a low-trust environment. Because every peer executes the same code and must reach a consensus, no single participant (or even the author of the code) can maliciously alter the outcome or change the business logic without the whole network noticing and rejecting the transaction. The trust comes from the **distributed verification**, not from trusting the code's author.
---
# [[Order-execute]] vs [[order-execute-validate]] ?

### **How [[order-execute]] works ?**
Most existing smart-contract capable blockchain platforms follow an **order-execute** architecture in which the consensus protocol:

- validates and orders transactions then propagates them to all peer nodes,
- each peer then executes the transactions sequentially.

The order-execute architecture can be found in virtually all existing blockchain systems, ranging from public/permissionless platforms such as [Ethereum](https://ethereum.org/) (with PoW-based consensus) to permissioned platforms such as [Tendermint](http://tendermint.com/), [Chain](http://chain.com/), and [Quorum](http://www.jpmorgan.com/global/Quorum).

Smart contracts executing in a blockchain that operates with the order-execute architecture must be deterministic; otherwise, consensus might never be reached. To address the non-determinism issue, many platforms require that the smart contracts be written in a non-standard, or domain-specific language (such as [Solidity](https://solidity.readthedocs.io/en/v0.4.23/)) so that non-deterministic operations can be eliminated. This hinders wide-spread adoption because it requires developers writing smart contracts to learn a new language and may lead to programming errors.

Further, since all transactions are executed sequentially by all nodes, performance and scale is limited. The fact that the smart contract code executes on every node in the system demands that complex measures be taken to protect the overall system from potentially malicious contracts in order to ensure resiliency of the overall system.

---
### **How order-execute-validate works** ?
Fabric introduces a new architecture for transactions that we call **execute-order-validate**. It addresses the resiliency, flexibility, scalability, performance and confidentiality challenges faced by the order-execute model by separating the transaction flow into three steps:

- _execute_ a transaction and check its correctness, thereby endorsing it,
    
- _order_ transactions via a (pluggable) consensus protocol, and
    
- _validate_ transactions against an application-specific endorsement policy before committing them to the ledger
    

This design departs radically from the order-execute paradigm in that Fabric executes transactions before reaching final agreement on their order.

In Fabric, an application-specific endorsement policy specifies which peer nodes, or how many of them, need to vouch for the correct execution of a given smart contract. Thus, each transaction need only be executed (endorsed) by the subset of the peer nodes necessary to satisfy the transaction’s endorsement policy. This allows for parallel execution increasing overall performance and scale of the system. This first phase also **eliminates any non-determinism**, as inconsistent results can be filtered out before ordering.

Because we have eliminated non-determinism, Fabric is the first blockchain technology that **enables use of standard programming languages**.