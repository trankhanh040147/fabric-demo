1. Giới thiệu chung 
    - Giới thiệu về Blockchain
        - Public Blockchain
        - Private Blockchain
    - Giới thiệu về Hyberledger Fabric  
        - Ưu điểm của mô hình Fabric
        - Nhược điểm của mô hình Fabric
2. Các thành phần trong Fabric  
    - Peer (định nghĩa, chức năng)
    - Ledger (định nghĩa, chức năng) 
    - Ordering Service (định nghĩa, chức năng)
    - Chaincode (định nghĩa, chức năng)
    - Channel (định nghĩa, chức năng)
3. Quy trình cài đặt một chaincode
- CC về bản chất chỉ là một source code backend để có thể thực thi business logic trên blockchain. Do đó để thực thi được CC thì nó phải được cài đặt trên các peer (? hay cài đặt trong mạng)
- Để đảm bảo tính minh bạch của blockchain, cài đặt CC cũng phải được sự đồng thuận từ các bên tham gia, tránh trường hợp một tổ chức tự ý cài đặt chaincode và sử dụng nó để làm thay đổi tài nguyên theo ý mình.
**Quy trình**
- Bước 1: Đóng gói (Package)
	- Bản chất chaincode chỉ là một source code, để thực thi được trên các peer thì cần phải được đóng gói chứa source code và các thư viện cần thiết và nén thành một file nén duy nhất
	- File chaincode được nén sẽ bao gồm 2 phần: source code (code.tar.gz) và file metadata chứa thông tin cho biết ngôn ngữ lập trình sử dụng và label của chaincode (Hiện tại Fabric hỗ trợ viết chaincode bằng các ngôn ngữ: Golang, Javascript/Typescript và Java)
	- Ở bước đóng gói chaincode này, ai sẽ là người thực hiện ?
		- Bước này có thể được thực hiện bởi **một tổ chức duy nhất** rồi chia sẻ cho các bên khác, hoặc **mỗi tổ chức** có thể tự đóng gói để đảm bảo tính toàn vẹn của mã nguồn mà họ sẽ chạy.
		- Đặt trường hợp ta đang có 2 Org trong mạng, Org1 đóng gói CC và gửi cho Org2 --> Cả 2 có cùng CC binaries
		- Đặt trường hợp ta đang có 2 Org trong mạng, Org1  tự đóng gói CC và Org2 tự đóng gói. Giả sử 2 bên dùng 2 source code khác nhau, thì lúc này có vấn đề gì không?
- Bước 2: Cài đặt (Install)
	- Chaincode được package phải được cài đặt lên các peers. Mục đích là để peer có mã nguồn để có thể execute (thực thi) logic của chaincode và endorse (chứng thực) transaction.
	- **Ai cần phải thực hiện bước này?**: **Tất cả các tổ chức** tham gia vào việc **xác thực giao dịch** (endorse) hoặc **truy vấn sổ cái** (query) từ chaincode này đều **bắt buộc** phải thực hiện bước cài đặt trên các peer của mình.
- Bước 3: Phê duyệt (Approve)
	- Sau khi cài đặt, **mỗi tổ chức** cần phải **phê duyệt một định nghĩa chaincode** cho tổ chức của mình.
	- **Mục đích:** Các tổ chức chính thức đồng ý về các tham số của chaincode sẽ được sử dụng trên channel, chẳng hạn như **tên, phiên bản, và quan trọng nhất là chính sách xác thực (endorsement policy)**.
	- **Điều kiện:** Chaincode chỉ có thể được kích hoạt trên channel khi có **đủ số lượng tổ chức phê duyệt**, và số lượng tổ chức này là theo quy định chính sách `LifecycleEndorsement` của channel (với chính sách mặc định là **đa số** (hơn 50%) các tổ chức trong channel). Ví dụ: Với một mạng có 3 tổ chức với chính sách là **đa số** thành viên cần phải duyệt định nghĩa của CC, thì chỉ cần tổ chức 1 và 2 duyệt là CC có thể được kích hoạt.
	- Hỏi:
		- Mỗi tổ chức phê duyệt một định nghĩa khác nhau thì sẽ có vấn đề gì ?
		- Một tổ chức có thể xem được source code của chaincode được cài đặt trên peer của tổ chức khác trước khi phê duyệt được không ? Trường hợp tổ chức khác cài đặt source code với logic không giống nhau. 
- Bước 4: Commit (Cam kết) định nghĩa lên channel

1. Luồng thực thi của một transaction trong Fabric  
	- Client khởi tạo giao dịch  
	- Các Endorsing Peer xác minh chữ ký và thực thi giao dịch  
	- Client kiểm tra kết quả chứng thực (endorsements)  
	- Client gửi kết quả chứng thực đến Ordering Service    
	- Các peers thực hiện commit giao dịch
# B - Kịch bản demo
- Demo 1: 
	- Deploy 1 mạng với 1 tổ chức có 3 peers
	- Tạo channel và join các peer vào channel
	- Deploy 1 chaincode lên channel theo policy (2 peer endorement)
	- Trình bày mạng trên có gì ? database lưu như thể nào/ở đâu?
	- Thực hiện giao dịch trên mạng vừa tạo (get dữ liệu, tạo dữ liệu) show terminal để xem các log endorsement của các peer. Sửa dữ liệu trái phép(cheat trên 		world state) -> get dữ liệu theo 2 kiểu(get db của peer hiện tại và get bằng các thực hiện transaction)
	- Thực hiện phục hồi db đã bị chỉnh sửa trái phép
- Demo 2: 
	- Deploy một mạng với 2 tổ chức (mỗi tổ chức có 3 peers)
	- Thực hiện thêm tổ chức vào mạng (join channel): Giải thích cần phải làm gì để tổ chức 3 có thể tham gia vào mạng ?
	- Quá trình thực thi chaincode lúc tổ chức 3 mới tham gia vào mạng: 
	- Thực thi chaincode (có tạo transaction) trên peer của tổ chức 3 để thấy tổ chức 3 chưa thể endorse được giao dịch (do chưa cài đặt chaincode)
	- Tắt các peer của một tổ chức để demo trường hợp không tạo được transacntion do peer 3 ko thể endorse (chỉ có một tổ chức chứng thực giao dịch, ko đủ 50%)
	- Deploy chaincode cho các peer của tổ chức 3 và thực thi lại chaincode để thấy quá trình endorse ở tổ chức 3
	- Demo cách cập nhật policy chứng thực và thực hiện lại transaction: Chỉ cần 50% peer của một tổ chức, 50% peer của mỗi tổ chức phải chứng thực.
# C - Các kịch bản khác
- Với môt mạng Fabric gồm 3 tổ chức, cài đặt 3 chaincode với logic khác nhau cho mỗi tổ chức (chaincode có cùng định nghĩa: tên chaincode và sequence), policy chứng thực là hơn 50% tổ chức
    - Trường hợp gọi một hàm giống logic có trong chaincode của 2 tổ chức: Transaction tạo thành công
    - Trường hợp gọi một hàm khác logic có trong chaincode của 2 tổ chức: Transaction tạo không thành công do kết quả ghi khác nhau
    - Trường hợp định nghĩa cấu trúc asset khác nhau --> các tổ chức chỉ thấy được những field được định nghĩa trong chaincode của mình (cách này phù hợp với việc muốn che dữ liệu với tổ chức khác) 
- Thay đổi trái phép dữ liệu trên world state của 1 peer
    - kiểm tra khi query dữ liệu, giải thích (tại sao response trả về data sai/lỗi) 
    - Giải pháp để query dữ liệu đúng(có endoser) 
    - Giải pháp để rebuild world state database 
- Trường hợp blockfile bị xóa/sửa trong 1 peer → làm sao để phục hồi như thế nào?
- Trường hợp một peer offline và có transaction mới được tạo trong lúc đó --> khi peer online trở lại phục hồi ntn ?
---
# Q&A (Demo 4)
### MANUAL 
- [ ] Thử nghiệm endorse trên từng peer bằng cách sử dụng fabric-sdk-go
### CƠ CHẾ KIỂM TRA KẾT QUẢ WRITE KHÁC NHAU
- [ ] Nếu endorse ra 2 kết quả khác nhau, gateway sẽ verify write set bị sai, nếu bỏ qua bước này thì peer có cơ chế tự verify lại kết quả ko ?
### CA
- [ ] Ai sẽ là người đứng ra tạo cert ? (tổ chức nào)
- [ ] Nếu một tổ chức muốn tạo ra cert mới cho peer/user của tổ chức đó thì cert phải thông qua 
- [ ] Làm sao peer biết được cert của một client là hợp lệ hay không ?
- [ ] Làm sao peer biết được user đó là từ tổ chức nào ? Có quyền gì ? 

- [ ] set gossip bootstrap sai thì bị gì ? (trường hợp tự trỏ vào chính nó)
- [ ] Làm sao để kết đến mạng bằng CCP ?