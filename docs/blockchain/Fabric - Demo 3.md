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
- CC về bản chất chỉ là một source code được nén lại và cài đặt trên các peer để có thể thực thi business logic được định nghĩa trong chaincode đó.
- Để đảm bảo tính minh bạch của blockchain, quá trình cài đặt CC trong Fabric cũng phải được sự đồng thuận từ các bên tham gia, tránh trường hợp một tổ chức tự ý cài đặt chaincode và sử dụng nó để làm thay đổi tài nguyên theo ý mình.
**Quy trình cài đặt chaincode**
- Bước 1: Đóng gói (Package)
	- CC được đóng gói thành một file .tar.gz chứa source code và file metadata chứa thông tin của chaincode như ngôn ngữ lập trình sử dụng.
	- Hiện tại Fabric có hỗ trợ tổng cộng 4 ngôn ngữ lập trình để viết chaincode: Golang, Javascript, Typescript và Java.


	- Để thực thi được trên các peer thì CC cần phải được đóng gói trong đó chứa các thư viện cần thiết và nén thành một file nén duy nhất
	- File chaincode được nén sẽ bao gồm 2 phần: source code (code.tar.gz) và file metadata thông tin cho biết ngôn ngữ lập trình sử dụng của chaincode (Hiện tại Fabric hỗ trợ viết chaincode bằng các ngôn ngữ: Golang, Javascript/Typescript và Java).
	- Ở bước đóng gói chaincode này, ai sẽ là người thực hiện ? (đặt trường hợp có nhiều hơn một tổ chức tham gia vào mạng)
		- Bước này có thể được thực hiện bởi **một tổ chức duy nhất** rồi chia sẻ cho các bên khác, hoặc **mỗi tổ chức** có thể tự đóng gói để đảm bảo tính toàn vẹn của mã nguồn mà họ sẽ chạy.
- Bước 2: Cài đặt (Install)
	- Sau khi có CC đã được nén, mỗi tổ chức phải cài đặt lên các peers của tổ chức mình. Mục đích là để peer có mã nguồn để có thể execute (thực thi) logic của chaincode và endorse (chứng thực) cho một transaction.
	- Sau khi cài đặt, CC vẫn chưa thể hoạt động trong mạng mà phải cần đi đến bước tiếp theo là Phê duyệt CC.


	- **Ai cần phải thực hiện bước này?**: **Tất cả các tổ chức** tham gia vào việc **xác thực giao dịch** (endorse) hoặc **truy vấn sổ cái** (query) từ chaincode này đều **bắt buộc** phải thực hiện bước cài đặt trên các peer của mình.
- Bước 3: Phê duyệt (Approve)
	- Các tổ chức cần phải phê duyệt định nghĩa CC nhằm mục đích chính thức đồng ý về các tham số của chaincode sẽ được sử dụng trên channel, chẳng hạn như **tên, phiên bản, và quan trọng nhất là chính sách xác thực**
	- Bước này là cực kỳ quan trọng bởi vì CC chỉ có thể được kích hoạt sau khi có đủ số lượng sự phê duyệt theo chính sách của kênh. Ví dụ: Trong một mạng có 3 tổ chức với chính sách là **đa số** thành viên cần phải duyệt định nghĩa của CC, thì khi tổ chức 1 và 2 phê duyệt, CC có thể được kích hoạt.

- Bước 4: Commit (Cam kết) định nghĩa lên channel
	- Sau khi có đủ số lượng phê duyệt, (một tổ chức) có thể commit để CC chính thức được đưa vào sử dụng.
	- Trường hợp các tổ chức đưa ra định nghĩa khác nhau (ví dụ khác sequence) thì bước commit sẽ thất bại.

4. Luồng thực thi của một transaction trong Fabric  
- Execution Phase: 
	- Đầu tiên, yêu cầu thực thi giao dịch (transaction proposal) được khởi tạo từ client sẽ được gửi đến Gateway trên một peer trong mạng, yêu cầu này sẽ bao gồm các thông tin: Tên của chaincode cần thực thi, fucntion cần gọi, và các tham số truyền vào. Yêu cầu này sẽ được ký bởi client và gửi đến Gateway.
	- Yêu cầu này sau đó sẽ được gửi đến các peer chứng thực theo chính sách chứng thực của CC. Ở công đoạn đoạn này các peer sẽ tiến hành 
		- kiểm tra chữ ký của client (để đảm bảo yêu cầu đến từ một client hợp lệ)
		- kiểm tra và thực thi chaincode theo thông tin yêu cầu (Ví dụ như kiểm tra xem function đó có hợp lệ không ? Có truyền đủ tham số không?).
		- chạy chaincode để tạo ra bộ giá trị đọc-ghi, trong đó ghi lại các khoá đã đọc (keys) và các giá trị mới sẽ được ghi vào sổ cái
		- Peer sẽ ký vào kết quả (bộ đọc-ghi) bằng chứng thực của chính nó và gửi lại một **phản hồi (proposal response)** đến client thông qua Gateway.
- Ordering Phase: 
	- Sau khi Gateway thu thập đủ phản hồi, nó sẽ tiến hành gói chúng lại thành một **giao dịch (transaction)** gửi đến Ordering Service. 
	- Nhiệm vụ duy nhất của Ordering Service là thiết lập một thứ tự giao dịch nhất quán, không thể thay đổi và đóng gói chúng vào các khối (blocks). Ordering Service không quan tâm đến nội dung hay tính hợp lệ của giao dịch. Dịch vụ này sẽ đóng gói các giao dịch vào thành khối theo một trình tự xác định và sau đó phân phối khối này đến tất cả các peer trong kênh.

- Validation Phase: 
	- Sau khi nhận được một khối mới từ Ordering Service, mỗi peer trong kênh (kể cả peer chứng thực) sẽ tiến hành xác thực giao dịch trong khối qua 2 bước:
        - **Kiểm tra Endorsement Policy:** Peer xác minh rằng giao dịch đã được ký bởi đúng và đủ số lượng các tổ chức cần thiết như đã định nghĩa trong chính sách.
        - **Kiểm tra xung đột phiên bản (MVCC - Multiversion Concurrency Control):** Đảm bảo dữ liệu mà giao dịch đã đọc ở bước Execute không bị thay đổi bởi một giao dịch khác đã được ghi vào sổ cái trước đó. 
	    (Peer kiểm tra bộ đọc (Read Set) của giao dịch. Nếu bất kỳ khóa (key) nào trong bộ đọc đã bị một giao dịch khác (đã được ghi vào sổ cái trước đó) thay đổi giá trị, giao dịch hiện tại sẽ bị đánh dấu là không hợp lệ. Điều này đảm bảo tính nhất quán của dữ liệu và ngăn chặn tấn công "double-spending".)
	- Chỉ những giao dịch vượt qua cả hai bước kiểm tra mới được coi là hợp lệ. Peer sẽ cập nhật trạng thái thế giới (world state) và ghi khối vào sổ cái của mình.
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
		- Chaincode được cài đặt với chính sách chứng thực là đa số tổ chức, có nghĩa cả 2 tổ chức phải đứng ra chứng thực giao dịch 
		- Luồng thực thi của transaction sẽ tương tự với một tổ chức, tuy nhiên sẽ khác ở chỗ thay vì chỉ có peer từ tổ chức 1 chứng thực, lúc này tổ chức 2 cũng sẽ tham gia vào quá trình chứng thực
	- Thực hiện thêm tổ chức vào mạng (join channel): Giải thích cần phải làm gì để tổ chức 3 có thể tham gia vào mạng ?
		- Đầu tiên, ta cần triển các peer node của tổ chức thứ 3
		- Tổ chức thứ 3 sau khi triển khai các peer, muốn tham gia vào mạng. Lúc này tổ chức thứ 3 phải được cái tổ chức khác thêm vào mạng (cụ thể là kênh mychannel).
		- Cấu hình mới của kênh sau khi được cập nhật sẽ đóng thành một block, được chấp thuận bởi các tổ chức và ghi block này lên ledger 
		- Quá trình sẽ được admin của tổ chức 1 và 2 thực hiện, quá trình tạo block cũng phải được chứng thực từ admin của 2 tổ chức.
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