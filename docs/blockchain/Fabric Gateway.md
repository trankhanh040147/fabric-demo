### ** gRPC
gRPC (gRPC Remote Procedure Call) là một framework do Google phát triển để thực hiện các cuộc gọi thủ tục từ xa. Trong bối cảnh của Fabric, nó thay thế cho các API REST/HTTP truyền thống.

**Tại sao Fabric lại cần gRPC?**

- **Hiệu suất (Performance):** gRPC được xây dựng trên nền tảng **HTTP/2**, cho phép các kết nối tồn tại lâu dài (persistent connections) và truyền dữ liệu hai chiều (bi-directional streaming). Điều này hiệu quả hơn nhiều so với việc tạo một kết nối HTTP mới cho mỗi yêu cầu. Trong một hệ thống phân tán như blockchain, nơi cần trao đổi nhiều thông điệp, hiệu suất là yếu tố sống còn.
- **Dữ liệu nhị phân (Binary Data):** gRPC sử dụng **Protocol Buffers (Protobuf)** để tuần tự hóa (serialize) dữ liệu. Protobuf chuyển đổi dữ liệu thành định dạng nhị phân nhỏ gọn, giúp việc truyền tải nhanh hơn và tiết kiệm băng thông hơn so với JSON/XML dựa trên văn bản.
- **Hợp đồng được định nghĩa chặt chẽ (Strongly-typed Contracts):** Các dịch vụ và thông điệp được định nghĩa trong các tệp `.proto`. Từ đó, mã nguồn client và server có thể được tạo tự động, đảm bảo rằng cả hai bên luôn "hiểu" nhau, giảm thiểu lỗi trong quá trình phát triển.

> **Tóm lại:** gRPC là đường ống dẫn nước hiệu suất cao, đảm bảo dữ liệu được truyền đi nhanh chóng, an toàn và đáng tin cậy giữa ứng dụng của bạn và mạng lưới Fabric.

---

### **Fabric Gateway**

> Fabric Gateway is a service, introduced in Hyperledger Fabric v2.4 peers, that provides a simplified, minimal API for submitting transactions to a Fabric network. Requirements previously placed on the client SDKs, such as gathering transaction endorsements from peers of various organizations, are delegated to the Fabric Gateway service running within a peer to enable simplified application development and transaction submission in v2.4.

Trước khi có Gateway, một ứng dụng client (SDK) phải thực hiện rất nhiều công việc phức tạp:

1. Nó phải biết địa chỉ của tất cả các **Peers** cần thiết để lấy chữ ký xác thực (endorsement).
2. Nó phải tự gửi yêu cầu đến từng Peer để thu thập đủ chữ ký theo chính sách (endorsement policy).
3. Sau khi có đủ chữ ký, nó phải tự mình tập hợp chúng lại.
4. Cuối cùng, nó phải gửi giao dịch đã được xác thực đến **Ordering Service**.

Công việc này rất phức tạp và lặp đi lặp lại, khiến việc phát triển ứng dụng trở nên khó khăn.

**Fabric Gateway ra đời để giải quyết vấn đề này.** Nó là một dịch vụ chạy trên các Peer, đóng vai trò là một điểm vào (entry point) duy nhất cho ứng dụng client.

**Vai trò của Gateway là gì?**

1. **Trừu tượng hóa (Abstraction):** Ứng dụng của bạn chỉ cần gửi một yêu cầu duy nhất đến Gateway: "Tôi muốn thực hiện giao dịch này".
2. **Thực thi quy trình giao dịch (Transaction Flow Execution):** Gateway sẽ thay bạn làm tất cả các bước phức tạp:
    - Nó tự tìm các Peers cần thiết để xác thực giao dịch dựa trên chaincode và chính sách.
    - Nó gửi yêu cầu và thu thập các chữ ký xác thực.
    - Nó gửi giao dịch đã hoàn chỉnh đến Ordering Service.
3. **Phản hồi đơn giản:** Sau khi giao dịch được đưa vào sổ cái, Gateway sẽ gửi một thông báo thành công hoặc thất bại về cho ứng dụng của bạn.

> **Tóm lại:** Fabric Gateway là một "trợ lý thông minh" giúp ứng dụng của bạn không cần phải biết về cấu trúc phức tạp bên trong mạng lưới. Bạn chỉ cần đưa ra yêu cầu, và Gateway sẽ lo phần còn lại.

---

### **Example**

```js
const peerEndpoint = 'localhost:7051';
const peerHostOverride = 'peer0.org1.example.com';

async function newGrpcConnection(): Promise<grpc.Client> {
    // 1. Đọc chứng thư TLS của CA để xác thực Gateway
    const tlsRootCert = await fs.readFile(tlsCertPath);
    const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);

    // 2. Tạo một kết nối gRPC đến Gateway
    return new grpc.Client(peerEndpoint, tlsCredentials, {
        // 3. Ghi đè tên host để xác thực TLS
        'grpc.ssl_target_name_override': peerHostOverride,
    });
}
```

1. **`peerEndpoint = 'localhost:7051'`**: Đây là địa chỉ mà ứng dụng của bạn kết nối tới. Vì bạn đang chạy ví dụ trên máy cục bộ (thường là qua Docker), ứng dụng của bạn truy cập vào Peer/Gateway qua `localhost`.
2. **`newGrpcConnection()`**: Hàm này thiết lập một **kết nối gRPC an toàn (qua TLS)** đến Fabric Gateway. Kết nối này nên được tái sử dụng cho tất cả các giao dịch để tránh chi phí thiết lập lại kết nối.
3. **`'grpc.ssl_target_name_override': peerHostOverride`**: Đây là phần quan trọng nhất để hiểu.
    - Chứng thư TLS của Gateway được cấp cho tên miền chính thức của nó bên trong mạng Docker, tức là `peer0.org1.example.com`.
    - Tuy nhiên, ứng dụng của bạn lại kết nối đến `localhost:7051`.
    - Nếu không có tùy chọn này, kết nối TLS sẽ thất bại vì tên miền trong chứng thư (`peer0.org1.example.com`) không khớp với địa chỉ bạn đang kết nối tới (`localhost`).
    - Tùy chọn `override` này nói với client gRPC rằng: "Hãy kết nối đến `localhost`, nhưng khi xác thực chứng thư TLS, hãy giả định rằng chúng ta đang nói chuyện với `peer0.org1.example.com`". Điều này cho phép kết nối TLS thành công trong môi trường phát triển cục bộ.

---
# Q: Tại sao gRPC, có thể thay thế bằng Websocket hay HTTP ko ?
### Tại sao gRPC là lựa chọn tốt nhất cho Fabric?

#### 1. Hiệu suất Vượt trội (Performance is King)

Đây là lý do quan trọng nhất. Một mạng lưới blockchain liên tục xử lý các giao dịch và đồng bộ hóa trạng thái giữa nhiều nút (peers, orderers). Tốc độ và hiệu quả là tối quan trọng.

- **HTTP/2:** gRPC được xây dựng trên nền tảng HTTP/2, mang lại các lợi ích mà HTTP/1.1 không có:
    - **Multiplexing:** Gửi nhiều yêu cầu và nhận nhiều phản hồi song song trên một kết nối TCP duy nhất, loại bỏ vấn đề "head-of-line blocking".
    - **Persistent Connections:** Kết nối được duy trì, giảm đáng kể độ trễ khi phải thiết lập kết nối mới cho mỗi yêu cầu như trong HTTP/1.1.
- **Protocol Buffers (Protobuf):** gRPC sử dụng Protobuf để tuần tự hóa (serialize) dữ liệu.
    - **Nhị phân (Binary):** Protobuf là định dạng nhị phân, nhỏ gọn và xử lý nhanh hơn nhiều so với định dạng văn bản (text-based) như JSON (được dùng phổ biến trong HTTP/WebSocket). Đối với một hệ thống gửi hàng triệu thông điệp, sự khác biệt này là rất lớn.
    - **Tiết kiệm băng thông:** Dữ liệu nhỏ hơn đồng nghĩa với việc truyền tải nhanh hơn và tốn ít tài nguyên mạng hơn.

#### 2. Hợp đồng API được định nghĩa chặt chẽ (Strict API Contracts)

Fabric là một hệ thống phức tạp với nhiều thành phần (peer, orderer, client SDK) cần giao tiếp với nhau một cách chính xác.

- **Tệp `.proto`:** Với gRPC, bạn định nghĩa các dịch vụ (services) và thông điệp (messages) trong một tệp `.proto`. Tệp này hoạt động như một **hợp đồng không thể phá vỡ** giữa client và server.
- **Tự động tạo mã (Code Generation):** Từ tệp `.proto`, gRPC có thể tự động tạo ra mã nguồn client và server (stubs) cho nhiều ngôn ngữ lập trình (Go, Java, Node.js, Python...). Điều này đảm bảo rằng các cấu trúc dữ liệu luôn đồng bộ, giảm thiểu lỗi tích hợp và giúp việc phát triển nhanh hơn.
- **An toàn kiểu (Type Safety):** Vì mọi thứ đều được định nghĩa chặt chẽ, bạn sẽ nhận được các lỗi ngay tại thời điểm biên dịch (compile-time) thay vì lúc chạy (run-time) nếu có sự không khớp về dữ liệu.

#### 3. Streaming hai chiều (Bi-Directional Streaming)

Fabric cần nhiều hơn là chỉ mô hình yêu cầu-phản hồi (request-response) đơn giản.

- **Ví dụ:** Một ứng dụng client có thể cần "lắng nghe" các sự kiện mới từ một peer (ví dụ: khi một block mới được commit). gRPC hỗ trợ streaming hai chiều một cách tự nhiên, cho phép client và server gửi một chuỗi các thông điệp qua lại trên cùng một kết nối.
- Trong khi WebSocket cũng làm được điều này, gRPC kết hợp nó với lợi ích của Protobuf và hợp đồng API chặt chẽ, tạo ra một giải pháp mạnh mẽ hơn cho các kịch bản phức tạp.

### So sánh nhanh với các lựa chọn khác

|Tiêu chí|gRPC|WebSocket|HTTP/1.1 (REST)|
|---|---|---|---|
|**Giao thức nền**|HTTP/2|Nâng cấp từ HTTP|HTTP/1.1|
|**Định dạng dữ liệu**|**Protocol Buffers (Nhị phân)**|Text (JSON) hoặc Nhị phân|Text (JSON, XML)|
|**Mô hình giao tiếp**|Yêu cầu-Phản hồi, Streaming (1 chiều & 2 chiều)|**Streaming 2 chiều**|**Yêu cầu-Phản hồi**|
|**Hợp đồng/Schema**|**Rất chặt chẽ (`.proto`)**|Không có sẵn (phải tự định nghĩa)|Lỏng lẻo (OpenAPI/Swagger là tùy chọn)|
|**Hiệu suất**|**Rất cao**|Cao|Trung bình|
|**Trường hợp sử dụng chính**|**Giao tiếp nội bộ giữa các microservices**|Giao tiếp real-time giữa client (trình duyệt) và server|API công khai, giao tiếp web truyền thống|

### Kết luận: Đúng công cụ cho đúng công việc

- **Bạn có thể dùng HTTP không?** Có, nhưng nó sẽ chậm hơn và kém hiệu quả hơn đáng kể cho việc giao tiếp liên tục giữa các nút trong mạng lưới Fabric. Giống như dùng xe tải để đi lại trong thành phố - vẫn được, nhưng không tối ưu.
- **Bạn có thể dùng WebSocket không?** Có, nó cung cấp giao tiếp hai chiều. Tuy nhiên, bạn sẽ mất đi lợi ích của hợp đồng API chặt chẽ và hiệu suất của Protobuf mà gRPC cung cấp sẵn. Bạn sẽ phải tự xây dựng lớp quản lý schema và tuần tự hóa dữ liệu.

**Tóm lại, Hyperledger Fabric đã chọn gRPC vì nó là công cụ được thiết kế chuyên biệt cho giao tiếp hiệu suất cao, an toàn kiểu và đáng tin cậy giữa các dịch vụ trong một hệ thống phân tán. Nó là "hệ thống thần kinh trung ương" hoàn hảo cho một kiến trúc phức tạp như Fabric.**


---

# Q: Khi connect đến gateway của peer0 và gửi proposal, có phải nó chỉ thực thi trên peer 0 hay không ? 

Đây là một câu hỏi cực kỳ sâu sắc và quan trọng, nó chạm đến cốt lõi của kiến trúc Fabric và vai trò của **Fabric Gateway**.

Câu trả lời ngắn gọn là: **Không, đó là một lầm tưởng phổ biến. Việc kết nối tới Gateway trên `peer0` không có nghĩa là chỉ `peer0` thực thi chaincode.**

Câu trả lời đầy đủ và chi tiết hơn là: Gateway trên `peer0` hoạt động như một **cổng vào thông minh** và một **người điều phối**, chứ không phải là người thực thi duy nhất. Toàn bộ quá trình vẫn tuân thủ nghiêm ngặt luồng giao dịch và chính sách xác thực (endorsement policy) của Fabric.

Hãy cùng phân tích luồng giao dịch khi bạn gọi `contract.SubmitTransaction()` qua Gateway.

### Vai trò của Gateway: Cổng vào thông minh, không phải là người thực thi duy nhất

Hãy tưởng tượng Gateway như một nhân viên lễ tân chuyên nghiệp tại một tòa nhà lớn. Bạn chỉ cần đến quầy lễ tân (Gateway trên `peer0`) và nói yêu cầu của mình. Nhân viên lễ tân sẽ tự biết phải gửi yêu cầu đó đến những phòng ban nào (các endorsing peer khác) để lấy đủ chữ ký xác nhận, sau đó tập hợp lại và trình lên giám đốc (Orderer).

Gateway giúp ứng dụng client trở nên **đơn giản hơn rất nhiều**. Client không cần phải tự mình quản lý kết nối đến nhiều peer, không cần tự mình gửi đề xuất đến từng peer, và không cần tự mình thu thập các chữ ký. Gateway làm tất cả những việc đó.

### Luồng giao dịch chi tiết khi sử dụng Gateway

Đây là những gì thực sự xảy ra phía sau khi bạn gọi `contract.SubmitTransaction("CreateAsset", ...)`:

**Bước 1: Propose (Đề xuất Giao dịch)**

1. **Client -> Gateway:** Ứng dụng Go của bạn gửi một đề xuất giao dịch `CreateAsset` đến Gateway đang chạy trên `peer0` (port `7051`).
2. **Gateway -> Discovery Service:** Gateway trên `peer0` sử dụng **Service Discovery** để phân tích. Nó tự hỏi: "Với chaincode `basic` trên channel `mychannel`, **chính sách xác thực (Endorsement Policy)** là gì? Và những peer nào cần phải ký vào giao dịch này để nó hợp lệ?"
3. **Ví dụ:** Giả sử chính sách là `OR('Org1MSP.peer', 'Org2MSP.peer')` (cần chữ ký của 1 peer từ Org1 VÀ 1 peer từ Org2).
4. **Gateway -> Endorsing Peers:** Gateway sẽ **thay mặt client** gửi đề xuất `CreateAsset` đến các peer cần thiết để thỏa mãn chính sách. Trong ví dụ này, nó sẽ gửi đến:
    - Một peer trong Org1 (có thể là chính `peer0.org1.example.com`).
    - Một peer trong Org2 (ví dụ `peer0.org2.example.com`).

**Bước 2: Endorse (Xác thực và Thực thi)**

1. **Thực thi song song:** Cả `peer0.org1` và `peer0.org2` **độc lập và song song thực thi hàm `CreateAsset`**. Chúng mô phỏng giao dịch, tạo ra một bộ đọc-ghi (Read-Write Set) và ký vào kết quả đó bằng chứng thư của mình.
2. **Endorsing Peers -> Gateway:** Các peer này gửi lại phản hồi đã được ký (signed proposal response) cho Gateway trên `peer0`.

**Bước 3: Submit to Orderer (Gửi đến Orderer)**

1. **Gateway tập hợp kết quả:** Gateway trên `peer0` nhận các phản hồi đã ký, kiểm tra xem chúng có nhất quán và có đủ chữ ký để thỏa mãn chính sách hay không.
2. **Gateway -> Orderer:** Nếu mọi thứ hợp lệ, Gateway sẽ gói tất cả lại thành một giao dịch hoàn chỉnh và **gửi nó đến Orderer**.

**Bước 4: Commit (Ghi vào Sổ cái)**

1. **Orderer -> All Peers:** Orderer tạo một khối mới chứa giao dịch này và phân phối khối đó đến **TẤT CẢ các peer** trong channel (bao gồm `peer0.org1`, `peer1.org1`, `peer0.org2`, v.v.).
2. **All Peers Validate & Commit:** **Mỗi peer** (kể cả những peer không tham gia xác thực ban đầu) sẽ xác thực giao dịch trong khối (kiểm tra chữ ký, kiểm tra xung đột phiên bản với RW Set). Nếu hợp lệ, chúng sẽ ghi khối mới vào sổ cái của mình.

### Bảng tóm tắt vai trò

|Thành phần|Vai trò trong luồng giao dịch này|
|---|---|
|**Application (Client)**|Gửi yêu cầu đến một điểm vào duy nhất (Gateway). Không cần quan tâm đến sự phức tạp phía sau.|
|**Gateway (trên `peer0`)**|**Điều phối viên:** Nhận yêu cầu, tìm ra ai cần xác thực, gửi đề xuất, thu thập chữ ký, và gửi giao dịch cuối cùng đến Orderer.|
|**Endorsing Peers**|**Người thực thi:** Các peer được chọn bởi Gateway (dựa trên chính sách) sẽ thực sự chạy chaincode và ký vào kết quả. **Đây có thể là nhiều peer, không chỉ `peer0`**.|
|**Orderer**|**Người sắp xếp:** Đóng gói các giao dịch đã được xác thực hợp lệ vào khối và đảm bảo thứ tự.|
|**All Peers (Committing Peers)**|**Người xác nhận cuối cùng:** Tất cả các peer trong channel nhận khối từ Orderer, xác thực và cập nhật sổ cái của mình.|

**Kết luận:**

Việc bạn kết nối tới Gateway trên `peer0` chỉ đơn giản là bạn chọn `peer0` làm "điểm vào" cho mạng lưới. Gateway đó đủ thông minh để điều phối công việc đến tất cả các peer cần thiết khác theo đúng quy tắc của Hyperledger Fabric. Quá trình thực thi và đồng thuận vẫn hoàn toàn **phân tán** và được quyết định bởi **chính sách xác thực của chaincode**, đảm bảo tính toàn vẹn và bảo mật của mạng lưới.

---

# Q: