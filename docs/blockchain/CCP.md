https://hyperledger-fabric.readthedocs.io/en/release-2.2/developapps/connectionprofile.html
#### **CCP là gì?**

**CCP** là viết tắt của **Common Connection Profile** (Hồ sơ kết nối chung).

Nó là một tệp JSON hoặc YAML hoạt động giống như một **cuốn danh bạ** 📖 cho ứng dụng client của bạn. Thay vì phải lập trình cứng tất cả địa chỉ của các peer và orderer, ứng dụng của bạn chỉ cần đọc tệp CCP này. Nó chứa tất cả thông tin cần thiết để kết nối và tương tác với mạng Fabric, bao gồm:

- Địa chỉ của các **Peers** trong mỗi tổ chức.
    
- Địa chỉ của **Ordering Service**.
    
- Địa chỉ của **Certificate Authority (CA)** của tổ chức.
    
- Đường dẫn đến các chứng chỉ TLS cần thiết để giao tiếp an toàn.
    

Việc sử dụng CCP giúp ứng dụng của bạn trở nên linh hoạt và dễ quản lý hơn rất nhiều.

---
## CCP file ở đâu, và làm sao tôi có thể sử dụng nó ?

Tệp CCP (Common Connection Profile) được tự động tạo ra và lưu trữ trong thư mục của mỗi tổ chức. Bạn sử dụng nó trong mã nguồn của ứng dụng client (ví dụ: Node.js, Java, Go) để kết nối vào mạng Fabric một cách dễ dàng.

---

### Vị trí của tệp CCP 📁

Khi bạn chạy các kịch bản (`network.sh` hoặc `addOrg3.sh`), các tệp CCP sẽ được tạo ra tại đường dẫn sau:

`test-network/organizations/peerOrganizations/`

Cụ thể, bạn sẽ tìm thấy các tệp cho mỗi tổ chức trong thư mục tương ứng của chúng. Cả hai định dạng **JSON** và **YAML** đều được tạo ra:

- **Cho Org1:**
    
    - `org1.example.com/connection-org1.json`
        
    - `org1.example.com/connection-org1.yaml`
        
- **Cho Org2:**
    
    - `org2.example.com/connection-org2.json`
        
    - `org2.example.com/connection-org2.yaml`
        

---

### Cách sử dụng tệp CCP 🚀

CCP hoạt động như một "cuốn danh bạ" cho ứng dụng của bạn. Thay vì phải lập trình cứng địa chỉ của từng peer và orderer, bạn chỉ cần cung cấp đường dẫn đến tệp CCP cho Fabric SDK. SDK sẽ tự động đọc tệp và biết cách kết nối đến các thành phần cần thiết trong mạng.

#### **Ví dụ sử dụng trong ứng dụng Node.js:**

Đây là một đoạn mã ví dụ điển hình từ ứng dụng mẫu `asset-transfer-basic` trong `fabric-samples`.

1. Xây dựng đường dẫn đến tệp CCP:
    
    Mã nguồn của bạn cần biết đường dẫn chính xác đến tệp connection-org1.json.
    
    JavaScript
    
    ```
    const ccpPath = path.resolve(__dirname, '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'org1.example.com', 'connection-org1.json');
    ```
    
2. Đọc và phân tích tệp:
    
    Ứng dụng sẽ đọc nội dung của tệp JSON.
    
    JavaScript
    
    ```
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));
    ```
    
3. Kết nối Gateway:
    
    Đối tượng Gateway của Fabric SDK sẽ sử dụng thông tin từ CCP để thiết lập kết nối đến mạng.
    
    JavaScript
    
    ```
    // Tạo một đối tượng Gateway mới để kết nối
    const gateway = new Gateway();
    
    // Sử dụng thông tin từ CCP để kết nối đến mạng
    await gateway.connect(ccp, {
        wallet, // Ví chứa danh tính của người dùng
        identity: 'appUser', // Tên người dùng trong ví
        discovery: { enabled: true, asLocalhost: true } // Kích hoạt khám phá dịch vụ
    });
    ```
    

**Tóm lại:** Bạn chỉ cần cung cấp **đường dẫn đến tệp CCP** cho Fabric SDK trong ứng dụng của mình, và SDK sẽ lo phần còn lại của việc kết nối mạng.