#### **1. X.509 là gì?**

**X.509** là một tiêu chuẩn quốc tế định nghĩa cấu trúc và gữ nghĩa cho **chứng thư khóa công khai (public key certificates)**. Về cốt lõi, một chứng thư X.509 thực hiện một nhiệm vụ quan trọng:

> Nó **liên kết một danh tính** (ví dụ: một cá nhân, một hostname, một tổ chức) **với một khóa công khai (public key)** thông qua một **chữ ký số (digital signature)**.

Chứng thư này được ký bởi một **Nhà cung cấp chứng thực (Certificate Authority - CA)** đáng tin cậy hoặc là một chứng thư tự ký (self-signed). Khi một bên tin tưởng vào CA, họ có thể tin tưởng vào danh tính được ghi trên chứng thư, từ đó sử dụng public key để:

- Thiết lập kênh giao tiếp an toàn (ví dụ: TLS/SSL).
- Xác thực các tài liệu hoặc mã nguồn được ký bằng **khóa riêng tư (private key)** tương ứng.

Tiêu chuẩn X.509 cũng định nghĩa các khái niệm quan trọng khác trong hệ sinh thái **PKI (Public Key Infrastructure)**:

- **Danh sách thu hồi chứng thư (Certificate Revocation List - CRL):** Một danh sách do CA phát hành để thông báo các chứng thư đã bị thu hồi và không còn hợp lệ trước ngày hết hạn.
- **Chuỗi chứng thực (Certificate Chain):** Cho phép xác thực một chứng thư bằng cách kiểm tra chuỗi chữ ký ngược về một CA gốc (Root CA) được tin tưởng tuyệt đối (**Trust Anchor**).

#### **2. X.509 được sử dụng ở đâu?**

Chứng thư X.509 là nền tảng cho rất nhiều cơ chế bảo mật trong thế giới số:

- **Bảo mật Web (TLS/SSL):** Đây là ứng dụng phổ biến nhất. Khi bạn truy cập một trang web qua `HTTPS`, trình duyệt của bạn sẽ xác thực chứng thư X.509 của máy chủ web để đảm bảo bạn đang kết nối đúng với trang web đó và mã hóa dữ liệu truyền đi.
- **Xác thực Client-Server (mTLS):** Trong các kiến trúc microservices hoặc các hệ thống yêu cầu bảo mật cao, không chỉ client xác thực server mà server cũng xác thực client thông qua chứng thư X.509.
- **Ký mã (Code Signing):** Các nhà phát triển phần mềm ký các ứng dụng của họ (ví dụ: `.exe`, `.jar`, `.apk`) để chứng minh mã nguồn không bị thay đổi và xác thực danh tính của nhà phát hành.
- **Ký tài liệu (Document Signing):** Đảm bảo tính toàn vẹn và xác thực nguồn gốc của các tài liệu điện tử như PDF.
- **Email bảo mật (S/MIME):** Mã hóa và ký email để đảm bảo tính riêng tư và xác thực người gửi.
- **Blockchain & Distributed Ledgers:** Như trong Hyperledger Fabric, chứng thư X.509 được dùng để định danh các actors (peers, orderers, admins) trong mạng lưới và quản lý quyền truy cập của họ.
- **IoT:** Các thiết bị IoT sử dụng chứng thư để xác thực lẫn nhau và kết nối an toàn đến máy chủ.

#### **3. Cấu trúc của một Chứng thư X.509**

Một chứng thư X.509 chứa các trường thông tin chính sau:

- **Version:** Phiên bản của tiêu chuẩn X.509 (thường là v3).
- **Serial Number:** Số sê-ri duy nhất do CA cấp cho chứng thư này.
- **Signature Algorithm:** Thuật toán được CA sử dụng để ký chứng thư (ví dụ: `SHA256withRSA`).
- **Issuer:** Thông tin về CA đã phát hành chứng thư (Tên tổ chức, quốc gia,...).
- **Validity Period:** Khoảng thời gian chứng thư có hiệu lực, bao gồm ngày bắt đầu (`Not Before`) và ngày hết hạn (`Not After`).
- **Subject:** Thông tin về đối tượng sở hữu chứng thư (ví dụ: `Common Name` có thể là `example.com`).
- **Subject Public Key Info:** Khóa công khai của đối tượng và thuật toán liên quan (ví dụ: RSA, ECDSA).
- **Extensions (v3):** Các trường mở rộng cung cấp thêm thông tin và ràng buộc:
    - **Subject Alternative Name (SAN):** Rất quan trọng, cho phép một chứng thư có thể dùng cho nhiều tên miền hoặc địa chỉ IP.
    - **Key Usage:** Xác định các mục đích sử dụng hợp lệ của khóa (ví dụ: `digitalSignature`, `keyEncipherment`).
    - **Extended Key Usage:** Chi tiết hóa mục đích sử dụng (ví dụ: `Server Authentication`, `Client Authentication`).
- **Issuer's Digital Signature:** Chữ ký số của CA, được tạo ra bằng cách hash toàn bộ nội dung chứng thư và mã hóa hash đó bằng private key của CA. Đây là yếu tố đảm bảo tính toàn vẹn của chứng thư.

#### **4. Các định dạng tệp (File Formats) của X.509**

Chứng thư X.509 có thể được lưu trữ dưới nhiều định dạng tệp khác nhau, thường gây nhầm lẫn cho các developer:

- **PEM (Privacy-Enhanced Mail):**
    
    - Là định dạng văn bản (ASCII), được mã hóa Base64.
    - Dễ dàng nhận biết bởi các dòng `-----BEGIN CERTIFICATE-----` và `-----END CERTIFICATE-----`.
    - Phổ biến nhất trên các hệ thống Linux/Unix.
    - Phần mở rộng tệp: `.pem`, `.crt`, `.cer`, `.key` (cho private key).
- **DER (Distinguished Encoding Rules):**
    
    - Là định dạng nhị phân (binary).
    - Không thể đọc trực tiếp bằng trình soạn thảo văn bản.
    - Thường được sử dụng trên các hệ thống Java và Windows.
    - Phần mở rộng tệp: `.der`, `.cer`.
- **PKCS#12 / PFX (Personal Information Exchange):**
    
    - Là một định dạng lưu trữ (archive) nhị phân, được bảo vệ bằng mật khẩu.
    - Dùng để đóng gói cả chuỗi chứng thư (certificate chain) và **khóa riêng tư (private key)** tương ứng vào một tệp duy nhất.
    - Rất hữu ích khi cần di chuyển một danh tính hoàn chỉnh (public + private key) giữa các hệ thống.
    - Phần mở rộng tệp: `.p12`, `.pfx`.
---

# Q: Tại sao Fabric dùng X.509 để định danh các actors mà ko dùng những loại khác ?

