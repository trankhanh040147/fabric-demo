Các actors trong mạng blockchain
- Các actors trong mạng blockchain gồm: Peers, orderers, client applications, administrators, ...
- Chúng phải có một digital identity encapsulated trong một X.509 digital certificate.

Identity
- Những danh tính (identity) này quan trọng vì chúng xác định các quyền hạn chính xác đối với tài nguyên và quyền truy cập thông tin mà các tác nhân có trong một mạng lưới blockchain.

Principal
- principle: Principle trong Fabric là gì ? Tại sao cần principle ? Principle liên quan với identity như thế nào ? Ví dụ cụ thể principle trong Fabric.
- Để một danh tính có thể được **xác minh** (verifiable), nó phải đến từ một **tổ chức được tin cậy** (trusted authority). **Nhà cung cấp dịch vụ thành viên** (Membership Service Provider - **MSP**) chính là tổ chức đáng tin cậy đó trong Fabric. Cụ thể hơn, MSP là một thành phần định nghĩa các quy tắc quản lý các danh tính hợp lệ cho một tổ chức. Việc triển khai MSP mặc định trong Fabric sử dụng X.509 làm danh tính, áp dụng mô hình phân cấp [**Hạ tầng khóa công khai**](https://en.wikipedia.org/wiki/Public_key_infrastructure) (Public Key Infrastructure - **PKI**) truyền thống.

**PKI**

![[Pasted image 20250717154717.png]]
 - A PKI is like a card provider — it dispenses many different types of verifiable identities.
 - Các thành phần của PKI:
	- **Digital Certificates**
	- **Public and Private Keys**
	- **Certificate Authorities**
	- **Certificate Revocation Lists**

**X.509**

X.509 là gì ?
- An X.509 certificate binds an identity to a public key using a digital signature. A certificate contains an identity (a hostname, or an organization, or an individual) and a public key ([RSA](https://en.wikipedia.org/wiki/RSA_\(cryptosystem\) "RSA (cryptosystem)"), [DSA](https://en.wikipedia.org/wiki/DSA_\(cryptography\) "DSA (cryptography)"), [ECDSA](https://en.wikipedia.org/wiki/ECDSA "ECDSA"), [ed25519](https://en.wikipedia.org/wiki/Ed25519 "Ed25519"), etc.), and is either signed by a certificate authority or is self-signed. When a certificate is signed by a trusted certificate authority, or validated by other means, someone holding that certificate can use the public key it contains to establish secure communications with another party, or validate documents [digitally signed](https://en.wikipedia.org/wiki/Digital_signature "Digital signature") by the corresponding [private key](https://en.wikipedia.org/wiki/Private_key "Private key").
- X.509 also defines [certificate revocation lists](https://en.wikipedia.org/wiki/Certificate_revocation_list "Certificate revocation list"), which are a means to distribute information about certificates that have been deemed invalid by a signing authority, as well as a [certification path validation algorithm](https://en.wikipedia.org/wiki/Certification_path_validation_algorithm "Certification path validation algorithm"), which allows for certificates to be signed by intermediate CA certificates, which are, in turn, signed by other certificates, eventually reaching a [trust anchor](https://en.wikipedia.org/wiki/Trust_anchor "Trust anchor").

 X.509 key được dùng ở đâu ?

 Cấu trúc của một X.509

 Định dạng của X.509
