
---
### **1. Consensus Without Mining: Trust in a Permissioned Network**

In public blockchains, "mining" (typically Proof of Work - PoW) is essential. It serves two purposes: to validate and bundle transactions into blocks and to create new currency as a reward for the computationally expensive work performed. This process is necessary in a **permissionless** environment where participants are anonymous and cannot be inherently trusted.

Hyperledger Fabric, however, operates as a **permissioned** network. This means all participants (peers, orderers, clients) are known entities with verified identities, operating within a governance framework established by the consortium. This fundamental difference eliminates the need for PoW.

Instead of mining, Fabric employs a deterministic consensus protocol. The most common mechanism is a Crash Fault-Tolerant (CFT) protocol based on the **Raft** algorithm. Here’s how it works:

- **Known Participants:** The nodes responsible for ordering transactions (the "ordering service") are pre-defined and trusted by the network members.
    
- **Leader-Based Ordering:** In a Raft-based ordering service, the nodes elect a single "leader" which is responsible for proposing the order of transactions. This leader packages transactions into blocks and broadcasts them to the "follower" nodes.
    
- **Transaction Finality:** The followers receive the proposed block, acknowledge it, and write it to their local ledger. Once a majority of ordering nodes have agreed on the block, it is considered final. There are no forks or probabilistic finality as seen in PoW systems.
    

This approach is significantly more efficient than mining because it doesn't involve solving complex cryptographic puzzles. The trust is shifted from anonymous computational work to the established identities and agreements between the participating organizations.