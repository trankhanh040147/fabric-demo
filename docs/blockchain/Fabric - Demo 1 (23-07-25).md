# A - Lý thuyết
## Smart contract trong Fabric

Smart contract là gì ? 
- **Smart contract** là một chương trình máy tính được lưu trữ và thực thi trên blockchain. Nó tự động thực thi các điều khoản của một hợp đồng hoặc thỏa thuận khi các điều kiện định trước được đáp ứng. Smart contract là phần business logic của blockchain.

Smart contract trong Fabric
 - Trong Hyperledger Fabric, Smart Contract được gọi là **Chaincode**. Khái niệm "chaincode" nhấn mạnh rằng đây không chỉ là một "hợp đồng" tĩnh, mà là một đoạn mã ứng dụng (application code) hoạt động trên blockchain (the chain).

Vai trò của chaincode
- Chaincode đóng vai trò là một ứng dụng **được tin tưởng** vì nó được cài đặt và phê duyệt bởi các thành viên tham gia mạng lưới. Mọi hành động của chaincode đều được ghi lại một cách minh bạch và không thể thay đổi trên sổ cái, đảm bảo tất cả các bên đều tuân thủ cùng một bộ quy tắc mà không cần một bên trung gian.

Chaincode = application code 
- Có thể hình dung chaincode như một backend application, nhưng thay vì chạy trên một server tập trung, nó được thực thi và xác thực bởi nhiều máy tính (peers) trong mạng lưới. Logic của nó là "nếu-thì" (if-this-then-that) và kết quả thực thi của nó là bất biến (immutable), được ghi lại vĩnh viễn trên sổ cái (ledger).

Mục đích của chaincode
- Mục đích chính của chaincode là để **định nghĩa và thực thi business logic** của một ứng dụng phi tập trung. Cụ thể:
1. **Định nghĩa Tài sản (Assets)**: Chaincode xác định cấu trúc dữ liệu của các tài sản sẽ được quản lý trên blockchain. Ví dụ: một chiếc xe, một lô hàng, một chứng chỉ tài chính.
2. **Định nghĩa Giao dịch (Transactions)**: Nó chứa các function để thay đổi trạng thái của các tài sản đó. Ví dụ: `createCar()`, `transferOwner()`, `updateShipmentLocation()`.
3. **Thực thi Quy tắc**: Nó đảm bảo các quy tắc kinh doanh đã được thống nhất được tuân thủ. Ví dụ: ngăn chặn việc chuyển quyền sở hữu một chiếc xe không tồn tại, hoặc chỉ cho phép một bên cụ thể cập nhật trạng thái lô hàng.

### Quy trình cài đặt chaincode ? 
#### Bước 1: Đóng gói Chaincode (Package)

Đầu tiên, chúng ta cần **đóng gói** mã nguồn của chaincode.

- **Mục đích:** Tạo ra một tệp nén duy nhất (thường có định dạng `.tar.gz`) chứa tất cả mã nguồn và các tệp phụ thuộc cần thiết.
    
- **Ai thực hiện:** Bước này có thể được thực hiện bởi **một tổ chức duy nhất** rồi chia sẻ cho các bên khác, hoặc **mỗi tổ chức** có thể tự đóng gói để đảm bảo tính toàn vẹn của mã nguồn mà họ sẽ chạy.
    

#### Bước 2: Cài đặt Chaincode (Install)

Tiếp theo, gói chaincode này phải được **cài đặt** lên các **peer**.

- **Mục đích:** Cung cấp mã nguồn cho các peer để chúng có thể thực thi logic của chaincode khi cần.
    
- **Ai thực hiện:** **Tất cả các tổ chức** sẽ tham gia vào việc **xác thực giao dịch** (endorse) hoặc **truy vấn sổ cái** (query) từ chaincode này đều **bắt buộc** phải thực hiện bước cài đặt trên các peer của mình.
    

#### Bước 3: Phê duyệt Định nghĩa Chaincode (Approve)

Sau khi cài đặt, **mỗi tổ chức** cần phải **phê duyệt một định nghĩa chaincode** cho tổ chức của mình.

- **Mục đích:** Các tổ chức chính thức đồng ý về các tham số của chaincode sẽ được sử dụng trên channel, chẳng hạn như **tên, phiên bản, và quan trọng nhất là chính sách xác thực (endorsement policy)**.
    
- **Điều kiện:** Chaincode chỉ có thể được kích hoạt trên channel khi có **đủ số lượng tổ chức phê duyệt**, theo quy định của chính sách `LifecycleEndorsement` của channel (mặc định là **đa số** các tổ chức trong channel).
    

#### Bước 4: Cam kết Định nghĩa lên Channel (Commit)

Đây là bước cuối cùng để kích hoạt chaincode.

- **Mục đích:** Ghi nhận định nghĩa chaincode đã được đa số đồng thuận lên sổ cái của channel, chính thức đưa chaincode vào hoạt động.
    
- **Ai thực hiện:** **Chỉ cần một tổ chức** đứng ra gửi giao dịch cam kết sau khi channel đã nhận đủ số lượt phê duyệt cần thiết. Tổ chức này sẽ thu thập các chữ ký xác thực (endorsements) từ peer của những tổ chức đã phê duyệt, sau đó gửi giao dịch **cam kết** (commit) lên channel.
    

Sau khi giao dịch này được ghi vào sổ cái, chaincode đã sẵn sàng để nhận các yêu cầu giao dịch đầu tiên.

- [ ] Tại sao lại cần go mod vendor ?

## Luồng thực thi của một transaction trong Fabric (Transaction Flow)

- [ ] Peer thực thi chaincode trên world state ? 
### Transaction Flow (V0)
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

---
### Transaction Flow (V1)
#### **Bước 1: Client Khởi tạo và Ký Giao dịch **
- **Tạo yêu cầu giao dịch (Transaction Proposal):**  Ứng dụng Client tạo một "yêu cầu giao dịch". Về bản chất, đây là một lời gọi đến một hàm cụ thể trong **Chaincode** với các tham số đầu vào cần thiết, nhằm mục đích đọc hoặc ghi dữ liệu lên sổ cái.

- Yêu cầu này được gửi đến các ** Endorsing Peers (nút xác thực)** được chỉ định bởi **Endorsement Policy (chính sách xác thực)** của chaincode. Chính sách này quy định rằng một giao dịch chỉ hợp lệ khi có đủ chữ ký từ các tổ chức cần thiết. 

- Yêu cầu giao dịch sẽ được đóng gói và sử dụng thông tin xác thực của client để tạo ra một **chữ ký số duy nhất** cho yêu cầu này. Chữ ký này chứng minh danh tính của người gửi và đảm bảo tính toàn vẹn của yêu cầu.

---

#### **Bước 2: Peer Xác thực và Mô phỏng Giao dịch **

Yêu cầu được gửi đến các **Endorsing Peer** (Peer xác thực) được quy định trong chính sách.
- **Kiểm tra & Xác minh:** Peer thực hiện các bước kiểm tra quan trọng:
    - Xác minh **chữ ký** của Client có hợp lệ không (thông qua **MSP**).
    - Kiểm tra xem Client có **quyền** thực hiện hành động này trên kênh không.
    - Đảm bảo yêu cầu này chưa từng được gửi trước đây (chống **tấn công lặp lại**).
- **Thực thi Mô phỏng:** Peer thực thi hàm Chaincode trên một bản sao của sổ cái. Quá trình này tạo ra:
    - **Read Set:** Danh sách các khóa-phiên bản dữ liệu đã được đọc.
    - **Write Set:** Danh sách các khóa-giá trị mới sẽ được ghi.
- **Ký và Phản hồi:** Peer ký vào kết quả (Read/Write Set) bằng chữ ký của chính mình và gửi lại cho Client.
    - **Quan trọng:** Ở bước này, sổ cái vẫn **chưa hề bị thay đổi**.

---

#### **Bước 3: Client Kiểm tra và Tập hợp Phản hồi 📦**

Client nhận lại các phản hồi đã được ký từ các Endorsing Peer.

- **Kiểm tra Phản hồi:** Ứng dụng Client sẽ:
    
    - Xác minh **chữ ký của các Peer** để đảm bảo phản hồi là thật.
        
    - So sánh các bộ **Read/Write Set** từ các Peer. Nếu chúng giống hệt nhau, giao dịch có tính nhất quán.
        
- **Tập hợp Giao dịch:** Nếu các phản hồi hợp lệ và đáp ứng **chính sách xác thực (endorsement policy)**, Client sẽ tập hợp yêu cầu ban đầu và tất cả các phản hồi đã ký thành một **giao dịch hoàn chỉnh**.
    

---

#### **Bước 4: Gửi Giao dịch đến Dịch vụ Sắp xếp 📨**

Giao dịch hoàn chỉnh sẵn sàng để được đưa vào sổ cái.

- **Phát sóng (Broadcast):** Client gửi giao dịch đã được tập hợp này đến **Ordering Service** (Dịch vụ Sắp xếp).
    
- **Chuyển giao Trách nhiệm:** Từ thời điểm này, Ordering Service chịu trách nhiệm cho giai đoạn tiếp theo của vòng đời giao dịch.
    

---

#### **Bước 5: Sắp xếp Giao dịch và Tạo Khối ⛓️**

Ordering Service thực hiện vai trò trung tâm trong việc tạo ra sự đồng thuận về thứ tự.

- **Chỉ Sắp xếp:** Ordering Service **không** kiểm tra nội dung chi tiết của giao dịch. Nhiệm vụ duy nhất của nó là nhận các giao dịch từ toàn bộ mạng lưới và sắp xếp chúng theo **thứ tự thời gian** một cách công bằng.
    
- **Đóng gói thành Khối (Block):** Các giao dịch đã được sắp xếp sẽ được nhóm lại thành các **khối** dữ liệu. Mỗi khối chứa một danh sách các giao dịch theo thứ tự.
    
- **Phân phối Khối:** Ordering Service sau đó "giao" (deliver) các khối mới này đến tất cả các Peer trên kênh.
    

---

#### **Bước 6: Peer Xác minh và Cam kết vào Sổ cái ledger**

Đây là bước cuối cùng, nơi dữ liệu được ghi vĩnh viễn.

- **Xác minh lần cuối:** Mỗi Peer trên kênh nhận khối mới và xác minh lại **từng giao dịch** bên trong khối:
    
    - **Kiểm tra Chính sách:** Giao dịch có đủ chữ ký xác thực hợp lệ theo quy định không?
        
    - **Kiểm tra Phiên bản (MVCC):** Dữ liệu trong **Read Set** của giao dịch có còn khớp với dữ liệu hiện tại trên sổ cái không? Điều này ngăn chặn xung đột và việc ghi đè dữ liệu không hợp lệ.
        
- **Cam kết (Commit):**
    
    - Các giao dịch được gắn cờ **hợp lệ (valid)** hoặc **không hợp lệ (invalid)**.
        
    - Peer nối khối mới vào chuỗi blockchain của mình.
        
    - Với mỗi giao dịch hợp lệ, **Write Set** của nó sẽ được ghi vào **cơ sở dữ liệu trạng thái (world state)**.
        
    - Cuối cùng, Peer phát ra một **sự kiện (event)** để thông báo cho ứng dụng Client về kết quả của giao dịch.

### Transaction Flow (v2)
#### **1. Client khởi tạo giao dịch**

- **Điều gì xảy ra?** Một Client (ví dụ: một ứng dụng người dùng) muốn thực hiện một hành động trên sổ cái, chẳng hạn như mua một tài sản. Client này sẽ tạo một **yêu cầu giao dịch (transaction proposal)**.
    
- **Gửi đến ai?** Yêu cầu này được gửi đến các **Endorsing Peers (nút xác thực)** được chỉ định bởi **Endorsement Policy (chính sách xác thực)** của chaincode. Chính sách này quy định rằng một giao dịch chỉ hợp lệ khi có đủ chữ ký từ các tổ chức cần thiết. Ví dụ, chính sách có thể yêu cầu cả Peer từ tổ chức của người mua và người bán đều phải xác thực giao- **Tạo yêu cầu giao dịch:** Sử dụng một **SDK (Bộ công cụ phát triển phần mềm)** hỗ trợ (như Node.js, Java, Python), ứng dụng sẽ tạo ra một yêu cầu giao dịch. Về bản chất, đây là một lời gọi đến một hàm trong **chaincode** (hợp đồng thông minh) với các tham số đầu vào cụ thể, nhằm mục đích đọc hoặc ghi dữ liệu lên sổ cái.
    
- **Ký và đóng gói:** SDK sẽ đóng gói yêu cầu giao dịch theo định dạng chuẩn (protocol buffer qua gRPC) và sử dụng thông tin xác thực (cryptographic credentials) của người dùng để tạo ra một **chữ ký số duy nhất** cho yêu cầu này. Chữ ký này đảm bảo tính xác thực và chống giả mạo.
    

---

#### **2. Các Endorsing Peer xác minh chữ ký và thực thi giao dịch**

Khi nhận được yêu cầu giao dịch, các Endorsing Peer sẽ thực hiện một loạt các bước kiểm tra quan trọng:

1. **Tính hợp lệ của yêu cầu:** Kiểm tra xem yêu cầu giao dịch có được định dạng đúng cách hay không.
    
2. **Chống tấn công lặp lại (Replay-attack protection):** Đảm bảo yêu cầu này chưa từng được gửi và xử lý trước đó.
    
3. **Tính hợp lệ của chữ ký:** Sử dụng **MSP (Membership Service Provider)** để xác minh rằng chữ ký trong yêu cầu là hợp lệ và đúng là của Client đã gửi.
    
4. **Kiểm tra quyền hạn:** Xác minh rằng người gửi (Client) có quyền thực hiện thao tác được đề xuất trên kênh đó. Cụ thể, mỗi Peer sẽ kiểm tra xem người gửi có đáp ứng **Chính sách ghi (Writers policy)** của kênh hay không.
    

- **Thực thi Chaincode:** Sau khi các bước kiểm tra thành công, Peer sẽ thực thi hàm chaincode được yêu cầu với các tham số đầu vào. Chaincode này sẽ tương tác với cơ sở dữ liệu trạng thái hiện tại (current state database) để tạo ra kết quả giao dịch, bao gồm:
    
    - **Response Value (Giá trị phản hồi):** Kết quả trả về của hàm chaincode.
        
    - **Read Set (Tập đọc):** Một danh sách các khóa và phiên bản của chúng mà chaincode đã đọc từ cơ sở dữ liệu.
        
    - **Write Set (Tập ghi):** Một danh sách các khóa và giá trị mới mà chaincode dự định ghi vào cơ sở dữ liệu.
        
- **Lưu ý quan trọng:** Ở bước này, **chưa có bất kỳ cập nhật nào được thực hiện trên sổ cái**. Peer chỉ mô phỏng việc thực thi và ghi lại kết quả.
    
- **Gửi lại phản hồi:** Tập hợp các giá trị này (Response Value, Read Set, Write Set) cùng với chữ ký của Endorsing Peer sẽ được đóng gói thành một **"phản hồi yêu cầu" (proposal response)** và gửi lại cho SDK của Client.
    

---

#### **3. Client kiểm tra các phản hồi**

Ứng dụng Client sau khi nhận được các phản hồi từ các Endorsing Peer sẽ:

- **Xác minh chữ ký:** Kiểm tra chữ ký của từng Endorsing Peer để đảm bảo các phản hồi là xác thực.
    
- **So sánh kết quả:** So sánh các phản hồi (đặc biệt là Read Set và Write Set) từ các Peer khác nhau. Nếu kết quả giống nhau, điều đó có nghĩa là các Peer đã đạt được sự đồng thuận về kết quả thực thi giao dịch.
    
- **Kiểm tra chính sách xác thực:** Ứng dụng sẽ kiểm tra xem đã nhận đủ số lượng phản hồi hợp lệ theo yêu cầu của Endorsement Policy hay chưa (ví dụ: cả Peer A và Peer B đều đã xác thực).
    
- **Trường hợp chỉ đọc (Query):** Nếu giao dịch chỉ là một truy vấn để đọc dữ liệu từ sổ cái, ứng dụng thường sẽ chỉ kiểm tra kết quả và **không** gửi giao dịch đến Ordering Service.
    
- **Trường hợp cập nhật (Update):** Nếu giao dịch nhằm mục đích cập nhật sổ cái, và chính sách xác thực đã được đáp ứng, Client sẽ chuyển sang bước tiếp theo.
    

---

#### **4. Client tập hợp các xác thực thành một giao dịch hoàn chỉnh**

- **"Phát sóng" giao dịch:** Ứng dụng Client sẽ "phát sóng" một **"thông điệp giao dịch" (transaction message)** đến **Ordering Service**. Thông điệp này chứa:
    
    - Yêu cầu giao dịch ban đầu.
        
    - Các phản hồi từ Endorsing Peer (bao gồm Read/Write Sets và chữ ký của các Peer).
        
    - ID của Kênh (Channel ID).
        
- **Vai trò của Ordering Service:** Ordering Service **không** cần phải kiểm tra toàn bộ nội dung của giao dịch. Nhiệm vụ chính của nó là:
    
    - Nhận giao dịch từ tất cả các kênh trong mạng lưới.
        
    - Sắp xếp chúng theo thứ tự thời gian cho từng kênh.
        
    - Tạo ra các **khối (blocks)** giao dịch cho mỗi kênh.
        

---

#### **5. Giao dịch được xác thực và cam kết (Commit)**

- **Phân phối khối:** Các khối giao dịch mới được tạo sẽ được Ordering Service "phân phối" đến tất cả các Peer trên kênh.
    
- **Xác thực cuối cùng:** Mỗi Peer khi nhận được khối mới sẽ thực hiện một lần xác thực cuối cùng cho từng giao dịch trong khối:
    
    - **Kiểm tra chính sách xác thực:** Đảm bảo rằng giao dịch có đủ chữ ký xác thực theo đúng chính sách.
        
    - **Kiểm tra xung đột phiên bản (MVCC Check):** Đảm bảo rằng không có sự thay đổi nào đối với trạng thái sổ cái cho các biến trong **Read Set** kể từ khi giao dịch được thực thi (ở bước 2). Điều này ngăn chặn các vấn đề về "đọc-ghi kép" (double-spending).
        
- **Đánh dấu giao dịch:** Các giao dịch trong khối sẽ được đánh dấu là **hợp lệ (valid)** hoặc **không hợp lệ (invalid)**.
    

---

#### **6. Cập nhật sổ cái**

- **Ghi vào chuỗi khối:** Mỗi Peer sẽ nối khối mới nhận được vào chuỗi khối (chain) của kênh.
    
- **Cập nhật cơ sở dữ liệu trạng thái:** Đối với mỗi giao dịch **hợp lệ**, **Write Set** của nó sẽ được ghi vào cơ sở dữ liệu trạng thái hiện tại (current state database), cập nhật giá trị của các tài sản.
    
- **Gửi sự kiện thông báo:** Mỗi Peer sẽ phát ra một sự kiện (event) để thông báo cho ứng dụng Client rằng:
    
    - Giao dịch đã được ghi vĩnh viễn vào chuỗi khối.
        
    - Trạng thái của giao dịch là hợp lệ hay không hợp lệ.
        

**Lưu ý:** Các ứng dụng nên lắng nghe sự kiện này sau khi gửi giao dịch (ví dụ: bằng cách sử dụng API `submitTransaction`, vốn tự động lắng nghe sự kiện). Nếu không, bạn sẽ không biết được liệu giao dịch của mình đã thực sự được sắp xếp, xác thực và cam kết vào sổ cái hay chưa.

### **Sơ đồ luồng giao dịch**
# B - Demo

1. Cách deploy Fabric với 3 peers trong 1 tổ chức
2. Cách tạo một channel và tham gia các peer vào channel
3. Cách deploy chaincode một channel
4. Quá trình thực thi một transaction

# C - FAQ

1. Giải thích các collections trong world state của peer dùng để làm gì ?
2. Nếu thay đổi giá trị world state của peer (trên couchDB) thì khi query lại có nhận được giá trị thay đổi ko ?
3. Khi user gửi một proposal và yêu cầu chứng thực (endorse) thông qua gateway của peer0, thì các peer1 hoặc peer2 có nhận được yêu cầu đó không và bằng cách nào ?
4. Cách thay đổi cơ chế chứng thực (endorsement policy) sao cho:  
    (1) Chỉ cần một chữ ký từ một peer bất kỳ trong tổ chức  
    (2) Cần hơn 50% chữ ký từ các peer   
    (3) Cần chữ ký từ tất cả các peer
5. Trường hợp cần 50% peers đồng thuận. Nếu có một peer bị mất kết nối, thì sẽ như nào ?  
    - Khi một peer bị mất kết nối. Quá trình đồng thuận vẫn diễn ra bình thường do có đủ 2 peers xác thực giao dịch.
6. Trường hợp cần 50% peers đồng thuận. Nếu có 2 peers bị mất kết nối, thì sẽ như nào?  
    - Khi đó invoke chaincode sẽ gặp lỗi do không có đủ số lượng peers tham gia:   
    
    Turn on wrapCopy as text
    
    `Error: rpc error: code = FailedPrecondition desc = no peers available to evaluate chaincode basic in channel mychannel`

---

# D - Q&A lần 1
1. Trong chaincode, có thể sử dụng thư viện ngoài không ?
2. Trường hợp xóa asset trên world state của một peer, update lại dữ liệu thì sao ?
3. Quy tắc viết chaincode (cách đặt tên file, đặt tên package, cấu trúc các files...) ?
4. Version của chaincode sử dụng làm gì ? 
5. Xóa chaincode được không, xóa bằng lệnh gì ?
6. Fields _rev và version trong asset được sử dụng cho mục đích gì ?
7. Lí do query dữ liệu ReadAsset và GetAllAssets chưa đồng bộ (GetAllAsset lấy dữ liệu sai từ world state, ReadAsset thì lấy dữ liệu đúng) ?
8. Nếu db world state của một peer bị thay đổi, làm sao để biết nó bị sai và làm sao để recover/sync (Fabric hỗ trợ như nào) ?
9. Nếu db world state của một peer bị outdated, làm sao để client biết được db mình bị sai ?
10. Anchor Peer dùng để làm gì ?
11. Cách config sao cho chỉ có 1 hoặc 1 nhóm user có quyền commit/approve chaincode ?
# E - Q&A lần 2 (cho present buổi tiếp theo)
A. DEPLOY NHIỀU TỔ CHỨC:
1. Deploy với 3 tổ chức (mỗi tổ chức 3 peers) và chỉnh sửa cơ chế approve chaincode (ví dụ: cần 2 trong 3 tổ chức approve chaincode)

B. CHÍNH SÁCH ĐỒNG THUẬN:
1. Cách để phân quyền chỉ cho các tổ chức có thể gọi các hàm trong chaincode (vd: tổ chức 1 có thể gọi hàm A, B, tổ chức 2,3 có thể gọi hàm B, C)?

C. CƠ CHẾ MANUAL ĐỂ ENDORSE VÀ COMMIT TRANSACTION  
1. Có thể cho phép endorse một transaction bằng cách thủ công?

D. CƠ CHẾ PHỤC HỒI:
1. Tại sao khi thay đổi dữ liệu World State thì GetAllAssets lại trả về dữ liệu bị sửa đổi (dữ liệu lấy trực tiếp từ World State) còn khi lấy dữ liệu bị thay đổi bằng ReadAsset thì lại có thể lấy được dữ liệu gốc ?
2. Cách để phục hồi peer khi bị xóa blockchain (transaction log) ?
3. Nếu sửa dữ liệu trên blockchain của một peer, thì chuyện gì xảy ra ? Làm sao để phục hồi ? 