Với sự nổi lên của Bitcoin, Etherium và các công nghệ khác, nhu cầu ứng dụng công nghệ blockchain, sổ cái phân tán và nền tảng ứng dụng phân tán vào các use cases của doanh nghiệp cũng đang tăng lên. Tuy nhiên, các doanh nghiệp cần những đặc tính về độ hiệu quả mà các công nghệ blockchain không ủy quyền không thể đáp ứng được. Đặc biệt trong nhiều trường hợp, danh tính của thành viên tham gia mạng là một yêu cầu bắt buộc, ví dụ trong các giao dịch tài chính thì Know-Your-Customer (KYC) và Anti-Money Laundering (AML) là các quy trình bắt buộc phải tuân theo.

Khi áp dụng blockchain vào môi trường doanh nghiệp, cần xem xét các yêu cầu sau:
- **Các bên tham gia phải được xác định danh tính hoặc có thể nhận dạng được**: Khác với mạng lưới công khai như Bitcoin hay Ethereum, nơi người tham gia thường là ẩn danh. Trong môi trường kinh doanh, các bên tham gia (ví dụ: nhà cung cấp, nhà phân phối, ngân hàng) phải là những bên đã biết và được xác thực danh tính.
- **Mạng lưới cần phải được _cấp phép_ (permissioned)**: Mạng lưới được cấp phép có nghĩa là không phải ai cũng có thể tự do tham gia. Một tổ chức quản trị sẽ kiểm soát ai được phép tham gia vào mạng lưới, và họ được cấp những quyền hạn gì (ví dụ: chỉ đọc, ghi giao dịch, hay xác thực giao dịch). Mô hình này có thể đáp ứng được với nhu cầu của doanh nghiệp.
- **Hiệu suất xử lý giao dịch cao**: Doanh nghiệp cần xử lý một khối lượng lớn giao dịch một cách nhanh chóng (ví dụ: hàng trăm hoặc hàng nghìn giao dịch mỗi giây), điều mà các blockchain công khai thế hệ đầu không thể đáp ứng được.
- **Độ trễ thấp trong việc xác nhận giao dịch**: Thời gian từ lúc mà một giao dịch được gửi đi cho đến khi nó được xác nhận trên sổ cái phải rất ngắn (vài giây hoặc thậm chí mili giây). Trong kinh doanh, việc phải chờ 10 phút đến 1 giờ để xác nhận một giao dịch (như trên mạng Bitcoin) là không khả thi.
- **Quyền riêng tư và bảo mật của các giao dịch và dữ liệu liên quan**: Đây là yêu cầu tối quan trọng. Các chi tiết của một giao dịch kinh doanh (ví dụ: giá cả, điều khoản hợp đồng, thông tin khách hàng) là thông tin nhạy cảm. Doanh nghiệp cần đảm bảo rằng chỉ những bên được phép trong giao dịch đó mới có thể xem nội dung của nó, chứ không phải tất cả mọi người trong mạng lưới.

Trong khi nhiều nền tảng blockchain ban đầu hiện đang được *thay đổi* để phù hợp cho việc sử dụng trong doanh nghiệp, thì Hyperledger Fabric đã được _thiết kế chuyên biệt_ cho doanh nghiệp ngay từ đầu. Các phần sau sẽ mô tả cách mà Fabric tạo ra sự khác biệt so với các nền tảng blockchain khác và giải thích nguyên nhân đằng sau các quyết định kiến trúc của nó.

### 1. Các thành phần module của Hyberledger Fabric

Hyperledger Fabric được thiết kế một cách có chủ đích theo **thiết kế module hóa [(modular architecture)](https://triare.net/insights/modular-architecture-software/)**. Từ cơ chế đồng thuận, các giao thức quản lý danh tính như LDAP hay OpenID Connect, giao thức quản lý khóa, cho đến các thư viện mã hóa, mọi thứ đều có thể tùy chỉnh. Nền tảng này được xây dựng từ cốt lõi để có thể cấu hình linh hoạt nhằm đáp ứng sự đa dạng trong các yêu cầu của doanh nghiệp.

Fabric bao gồm các thành phần module sau:
- **Ordering Service:** Chịu trách nhiệm thiết lập cách đồng thuận về **thứ tự** của các giao dịch, sau đó chuyển các khối đã được sắp xếp này đến các peer. Có thể dùng **Raft** (recommend) hoặc trong các phiên bản cũ hơn là Solo (cho môi trường dev) hay Kafka.
- **Membership Service Provider - MSP:** Quản lý danh tính của các thành viên trong mạng. Có thể tích hợp với hệ thống quản lý danh tính có sẵn của doanh nghiệp như **LDAP** hoặc **Active Directory**, hoặc sử dụng Fabric CA mặc định.
- **Peer-to-peer Gossip Service:** Phân phối các blocks do Ordering Service tạo ra đến các peer khác trong mạng lưới.
- **Chaincode**: Chạy trong một môi trường container (ví dụ: Docker) để đảm bảo an toàn. Có thể được viết bằng các ngôn ngữ lập trình như Go, Java, JS để tương tác với sổ cái.
- **Sổ cái (Ledger):** Có thể được cấu hình để hỗ trợ nhiều hệ quản trị cơ sở dữ liệu (DBMS) khác nhau (LevelDB hoặc CouchDB)
- **Chính sách xác thực và kiểm duyệt (Endorsement and Validation Policy):** Cho phép cấu hình các quy tắc xác thực cho từng application.



- Note: Trong Hyperledger Fabric, **module hóa (modular)** có nghĩa là có thể **"tháo lắp" hoặc "thay thế" (pluggable)** các cách triển khai cụ thể cho một module mà không cần phải thay đổi toàn bộ kiến trúc. Ví dụ Ordering Service có thể sử dụng Raft, Kafka hoặc Solo. Tương tự, có thể chọn CouchDB thay vì LevelDB cho sổ cái nếu cần các truy vấn phức tạp. 
### 2.2. Smart Contract (Chaincode)
- **Smart contract** là một chương trình máy tính được lưu trữ và thực thi trên blockchain. Nó tự động thực thi các điều khoản của một hợp đồng hoặc thỏa thuận khi các điều kiện định trước được đáp ứng. Smart contract là phần business logic của blockchain.

 - Trong Hyperledger Fabric, Smart Contract được gọi là **Chaincode**. Khái niệm "chaincode" nhấn mạnh rằng đây không chỉ là một "hợp đồng" tĩnh, mà là một đoạn mã ứng dụng (application code) hoạt động trên blockchain (the chain).

- Chaincode đóng vai trò là một ứng dụng **được tin tưởng** vì nó được cài đặt và phê duyệt bởi các thành viên tham gia mạng lưới. Mọi hành động của chaincode đều được ghi lại một cách minh bạch và không thể thay đổi trên sổ cái, đảm bảo tất cả các bên đều tuân thủ cùng một bộ quy tắc mà không cần một bên trung gian.

- Các đặc tính quan trọng của Chaincode: 
	- **Chạy nhiều chaincode đồng thời**: Một mạng Fabric có thể vận hành nhiều chaincode khác nhau trên các "channel" (kênh) riêng biệt. Điều này cho phép các nhóm tổ chức khác nhau thực hiện các logic kinh doanh riêng tư trên cùng một cơ sở hạ tầng blockchain.
	- **Triển khai và nâng cấp động**: Có thể cài đặt, khởi tạo và nâng cấp chaincode trên một mạng lưới đang hoạt động mà không cần phải dừng hệ thống. Quá trình này được quản lý thông qua một chính sách (policy) do các thành viên mạng lưới thỏa thuận.
	- **Kiểm soát truy cập chặt chẽ**: Chaincode có thể lập trình logic để kiểm tra danh tính và quyền hạn của người gọi. Ví dụ, chỉ người dùng có vai trò "manager" mới có thể tạo tài sản mới, trong khi người dùng "auditor" chỉ có quyền đọc dữ liệu.
	- **Tương tác với Sổ cái (Ledger)**: Chaincode là cách duy nhất để tương tác với sổ cái. Nó chứa các hàm để đọc, ghi và xóa dữ liệu trong cơ sở dữ liệu trạng thái (world state).

- Có thể hình dung chaincode như một backend application, nhưng thay vì chạy trên một server tập trung, nó được thực thi và xác thực bởi nhiều máy tính (peers) trong mạng lưới. Logic của nó là "nếu-thì" (if-this-then-that) và kết quả thực thi của nó là bất biến (immutable), được ghi lại vĩnh viễn trên sổ cái (ledger).

- Mục đích chính của chaincode là để **định nghĩa và thực thi business logic** của một ứng dụng phi tập trung. Cụ thể:

1. **Định nghĩa Tài sản (Assets)**: Chaincode xác định cấu trúc dữ liệu của các tài sản sẽ được quản lý trên blockchain. Ví dụ: một chiếc xe, một lô hàng, một chứng chỉ tài chính.
    
2. **Định nghĩa Giao dịch (Transactions)**: Nó chứa các function để thay đổi trạng thái của các tài sản đó. Ví dụ: `createCar()`, `transferOwner()`, `updateShipmentLocation()`.
    
3. **Thực thi Quy tắc**: Nó đảm bảo các quy tắc kinh doanh đã được thống nhất được tuân thủ. Ví dụ: ngăn chặn việc chuyển quyền sở hữu một chiếc xe không tồn tại, hoặc chỉ cho phép một bên cụ thể cập nhật trạng thái lô hàng.
### 2.3. Tính bảo mật dữ liệu
- Trong các public blockchain như Bitcoin hay Ethereum, **tính minh bạch (transparency)** là một đặc tính cốt lõi. Mọi giao dịch và dữ liệu đều được sao chép và hiển thị công khai cho tất cả các nút (node) trong mạng lưới.  Việc này đặt ra vấn đề: Mặc dù danh tính người dùng được ẩn danh sau các địa chỉ ví, toàn bộ lịch sử giao dịch và dữ liệu đều công khai. Trong môi trường doanh nghiệp, việc để lộ thông tin nhạy cảm như giá cả hợp đồng, chi tiết chuỗi cung ứng, hay thông tin khách hàng cho đối thủ cạnh tranh là điều không thể chấp nhận.

- Fabric giải quyết bài toán bảo mật dữ liệu thông qua một kiến trúc đa lớp, cho phép các tổ chức tham gia có thể kiểm soát ai được phép xem dữ liệu nào bằng các cơ chế chính là **Channels** và **Private Data Collections**.

- **Channel** là một cơ chế tạo ra một "mạng lưới con" (subnet) riêng tư giữa một tập hợp các thành viên cụ thể trong mạng.
	- **Cơ chế hoạt động:** Mỗi channel có một sổ cái hoàn toàn riêng biệt. Các giao dịch và dữ liệu được gửi trên một channel sẽ chỉ được phát tán và lưu trữ trên các peer của những thành viên thuộc channel đó.
	- **Mục đích:** Channels thực hiện việc cô lập dữ liệu ở cấp độ sổ cái. Các tổ chức không thuộc một channel sẽ không biết về sự tồn tại của channel đó, cũng như không thể truy cập vào bất kỳ dữ liệu nào bên trong nó.
- Trong nhiều trường hợp, ngay cả các thành viên trên cùng một channel cũng cần giữ riêng tư một phần dữ liệu giao dịch với nhau. **Private Data Collections (PDC)** giải quyết nhu cầu này.
	- **Cơ chế hoạt động:**
	    - Dữ liệu thực tế (private data) không được ghi lên sổ cái chung của channel. Thay vào đó, nó được gửi trực tiếp (peer-to-peer) thông qua giao thức gossip chỉ đến các tổ chức được ủy quyền. Dữ liệu này được lưu trữ trong một cơ sở dữ liệu riêng trên peer của họ (gọi là private data collection).
	    - Một **hash** (băm) của dữ liệu riêng tư đó sẽ được ghi lên sổ cái chung của channel.
	- **Mục đích:**
	    - Chỉ các bên được phép mới có thể xem nội dung dữ liệu gốc.
	    - Hash trên sổ cái chung đóng vai trò là bằng chứng không thể chối cãi về sự tồn tại và tính toàn vẹn của giao dịch mà không tiết lộ nội dung. Bất kỳ ai trên channel cũng có thể xác thực rằng một giao dịch liên quan đến dữ liệu riêng tư đã xảy ra.
### 2.4. Cơ chế đồng thuận
![[Pasted image 20250717114142.png]]
- Khác với các hệ thống blockchain truyền thống áp dụng mô hình đồng thuận nguyên khối (monolithic) theo cơ chế **order-execute**, nơi việc sắp xếp thứ tự và thực thi giao dịch diễn ra đồng thời trên toàn mạng, Hyperledger Fabric sử dụng một kiến trúc khác là **execute-order-validate**: 

1. **Chaincode execution (Thực thi & Xác thực - Endorsement):**
    - Một giao dịch được khởi tạo từ client và gửi đến các peer được chỉ định trong một chính sách gọi là **Endorsement Policy**.
    - Các peer này sẽ thực thi giao dịch trên một bản sao của sổ cái, tạo ra một kết quả đọc/ghi (Read-Write Set) và ký số lên kết quả đó. Quá trình này không cập nhật vào sổ cái chính.
2. **Order (Sắp xếp thứ tự - Ordering):**
    - Client thu thập các chữ ký xác thực (endorsement collection) và gửi gói giao dịch đến một thành phần chuyên biệt gọi là **Ordering Service**.
    - Nhiệm vụ duy nhất của Ordering Service là thiết lập một thứ tự giao dịch nhất quán, không thể thay đổi và đóng gói chúng vào các khối (blocks). Ordering Service không quan tâm đến nội dung hay tính hợp lệ của giao dịch.
3. **Validate (Kiểm duyệt & Ghi sổ - Validation):**
    - Ordering Service phát các khối đã được sắp xếp đến tất cả các peer trong channel.
    - Mỗi peer sẽ kiểm duyệt lại từng giao dịch trong khối:
        - **Kiểm tra Endorsement Policy:** Đảm bảo giao dịch có đủ chữ ký xác thực hợp lệ.
        - **Kiểm tra xung đột phiên bản (MVCC - Multiversion Concurrency Control):** Đảm bảo dữ liệu mà giao dịch đã đọc ở bước Execute không bị thay đổi bởi một giao dịch khác đã được ghi vào sổ cái trước đó.
    - Chỉ những giao dịch vượt qua cả hai bước kiểm tra mới được coi là hợp lệ và được ghi vào sổ cái, cập nhật trạng thái thế giới (world state).

Mô hình Execute-Order-Validate cho phép các giao dịch được thực thi song song trên các peer, giải quyết các vấn đề về hiệu năng và ngăn chặn các giao dịch không xác định (non-determinism) vốn tồn tại trong các hệ thống blockchain khác.

- [ ] Peer (non-endorsing là gì) ?
- [ ] Giải thích flow theo hình

# Q&A: 
### 1: Giải thích cơ chế đồng thuận theo hình:
Chắc chắn rồi. Dưới đây là phần giới thiệu về cơ chế đồng thuận trong Hyperledger Fabric, giải thích dựa trên hình ảnh bạn đã cung cấp.

---
#### Pha 1: Endorsement (Thực thi và Bảo chứng)

Đây là pha thực thi giao dịch ban đầu, nơi các bên liên quan đồng ý về kết quả của một giao dịch được đề xuất.

- **(1) Invocation & Chaincode Execution:**
    
    - `Client` (ứng dụng phía người dùng) tạo một đề xuất giao dịch (transaction proposal) và gửi nó đến các `endorsing peers` được chỉ định.
        
    - Các peer này được định nghĩa bởi một **Endorsement Policy** (Chính sách Bảo chứng) gắn liền với `chaincode` (smart contract). Ví dụ, chính sách có thể yêu cầu "cần chữ ký từ Peer 1 VÀ Peer 2".
        
    - Mỗi endorsing peer sẽ mô phỏng việc thực thi giao dịch trên một bản sao tạm thời của sổ cái, tạo ra một tập hợp kết quả gồm các giá trị đã đọc (Read Set) và các giá trị sẽ được ghi (Write Set).
        
- **(2) Endorsement Collection:**
    
    - Nếu thực thi thành công, mỗi endorsing peer sẽ ký điện tử lên kết quả (Read-Write Set) và gửi lại cho `client`. Đây được gọi là một `endorsement` (bảo chứng).
        
    - Client sẽ thu thập các chữ ký này cho đến khi thỏa mãn Endorsement Policy.
        

#### Pha 2: Ordering (Sắp xếp)

Sau khi có đủ bảo chứng, giao dịch cần được đưa vào một thứ tự nhất quán trên toàn mạng lưới.

- **(3) Ordering Broadcast:**
    
    - Client đóng gói đề xuất giao dịch cùng với các chữ ký bảo chứng thu thập được thành một giao dịch hoàn chỉnh và gửi nó đến **Ordering Service**.
        
- **(4) Broadcast/Delivery:**
    
    - `Ordering Service` (thường sử dụng thuật toán đồng thuận như Raft) không quan tâm đến nội dung hay tính hợp lệ của giao dịch. Nhiệm vụ duy nhất của nó là thống nhất về thứ tự giao dịch trên toàn mạng.
        
    - Nó sẽ gom nhiều giao dịch lại, sắp xếp chúng theo thứ tự thời gian và tạo thành một khối (block) mới, sau đó phân phối khối này đến tất cả các peer trong channel.
        

#### Pha 3: Validation và Commit (Kiểm tra và Ghi sổ)

Đây là pha cuối cùng, nơi các peer xác thực và chính thức ghi giao dịch vào sổ cái.

- **(5) Validation & Commit:**
    
    - Tất cả các peer trong channel (cả `endorsing peer` và `non-endorsing peer`) nhận khối mới từ Ordering Service.
        
    - Với mỗi giao dịch trong khối, peer sẽ thực hiện hai bước kiểm tra quan trọng:
        
        1. **Kiểm tra Endorsement Policy:** Giao dịch có đủ chữ ký hợp lệ từ các endorsing peer được yêu cầu hay không?
            
        2. **Kiểm tra Xung đột (MVCC Check):** Các giá trị trong Read Set của giao dịch có bị thay đổi bởi một giao dịch khác kể từ khi nó được thực thi ở Pha 1 không? Đây là cơ chế kiểm soát xung đột đồng thời (Multiversion Concurrency Control - MVCC).
            
    - Nếu giao dịch vượt qua cả hai bài kiểm tra, nó được đánh dấu là hợp lệ (valid). Peer sẽ ghi khối mới vào sổ cái của mình và cập nhật trạng thái thế giới (world state) với các giá trị trong Write Set. Nếu không, giao dịch sẽ bị đánh dấu là không hợp lệ (invalid).
        

Như vậy, **sự đồng thuận trong Fabric** chính là kết quả của toàn bộ quy trình này: đảm bảo rằng một giao dịch không chỉ được các bên cần thiết _bảo chứng_ mà còn được _sắp xếp_ theo một thứ tự nhất quán và được tất cả các peer trong channel _xác thực_ trước khi ghi vào sổ cái.

---
