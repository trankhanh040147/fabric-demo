# Hyperledger Fabric: Tổng Quan

Đây là một tài liệu tổng hợp toàn diện, giải thích các khái niệm cốt lõi, kiến trúc và luồng hoạt động của **Hyperledger Fabric**, một nền tảng blockchain được thiết kế đặc biệt cho các ứng dụng cấp doanh nghiệp.

## 📖 Mục lục

- [1. Giới thiệu chung về Hyperledger Fabric](#1-giới-thiệu-chung-về-hyperledger-fabric-)
- [2. Mạng Được Cấp Phép và Quản lý Danh tính](#2-mạng-được-cấp-phép-và-quản-lý-danh-tính-)
- [3. Các thành phần chính của Fabric](#3-các-thành-phần-chính-của-fabric-)
- [4. Luồng xử lý chi tiết của một Giao dịch](#4-luồng-xử-lý-chi-tiết-của-một-giao-dịch-)
- [5. Lưu trữ Dữ liệu trong Fabric](#5-lưu-trữ-dữ-liệu-trong-fabric-)
- [6. So sánh Tiền Mã Hóa và Tiền Pháp Định](#6-so-sánh-tiền-mã-hóa-và-tiền-pháp-định-)
- [7. Kiến trúc Mô-đun và Linh hoạt](#7-kiến-trúc-mô-đun-và-linh-hoạt-)
- [8. Q&A - Các câu hỏi thường gặp](#8-qa---các-câu-hỏi-thường-gặp-)

---

## 1. Giới thiệu chung về Hyperledger Fabric 🚀

**Hyperledger Fabric** là một **khung sườn (framework)** mã nguồn mở để xây dựng các ứng dụng và giải pháp sổ cái phân tán cho doanh nghiệp. Nó thuộc dự án Hyperledger của Linux Foundation, một nỗ lực hợp tác toàn cầu nhằm thúc đẩy các công nghệ blockchain liên ngành.

Mục tiêu chính của Fabric là giải quyết các vấn đề cố hữu trong kinh doanh mà các hệ thống truyền thống gặp phải, chẳng hạn như:

- **Thiếu tin cậy:** Khi nhiều bên cùng tham gia vào một quy trình (ví dụ: chuỗi cung ứng), họ thường phải dựa vào các bên trung gian hoặc các quy trình đối chiếu tốn kém để tạo sự tin tưởng.
- **Kém hiệu quả:** Việc mỗi bên duy trì một hệ thống ghi nhận riêng biệt dẫn đến sự trùng lặp, sai sót và chậm trễ trong việc đồng bộ hóa dữ liệu.
- **Thiếu minh bạch:** Khó có thể truy xuất nguồn gốc của một tài sản hay xác minh một giao dịch một cách nhanh chóng và đáng tin cậy.

Fabric giải quyết những vấn đề này bằng cách cung cấp một sổ cái chung, bất biến và được chia sẻ, nơi các quy tắc kinh doanh (chaincode) được thực thi một cách nhất quán cho tất cả các bên tham gia.

---

## 2. Mạng Được Cấp Phép và Quản lý Danh tính 🏛️

Khái niệm "được cấp phép" (permissioned) là nền tảng của Fabric và được thực thi về mặt kỹ thuật thông qua **Nhà cung cấp Dịch vụ Thành viên (Membership Service Provider - MSP)**.

### Cơ chế hoạt động của MSP

**MSP** là một thành phần định nghĩa các quy tắc xác định danh tính hợp lệ và vai trò của các thành viên trong mạng. Hãy coi nó như một "danh bạ" của tổ chức, chứa thông tin về những ai được phép tham gia.

1.  **Cấp phát danh tính:** Mỗi khi một thực thể (peer, orderer, người dùng) muốn tham gia mạng, nó phải có một danh tính. Danh tính này là một **chứng chỉ số (digital certificate)** theo chuẩn X.509, được cấp bởi một **Nhà cung cấp Chứng thực (Certificate Authority - CA)** mà tổ chức đó tin tưởng.
2.  **Định nghĩa trong MSP:** Tổ chức sẽ cấu hình MSP của mình, khai báo rằng tất cả các chứng chỉ được cấp bởi CA đó sẽ được coi là thành viên hợp lệ của tổ chức.
3.  **Xác thực:** Khi một thành viên gửi một giao dịch, họ sẽ ký nó bằng khóa riêng tư của mình. Các thành viên khác trong mạng có thể sử dụng MSP để kiểm tra.

### Quản lý CA và Vòng đời Danh tính 📇

Việc quản lý danh tính không chỉ dừng lại ở việc cấp phát. Fabric cung cấp một vòng đời hoàn chỉnh:

- **Đăng ký (Enrollment):** Là quá trình một người dùng hoặc một nút mạng đăng ký lần đầu với CA để nhận về cặp khóa (công khai và bí mật) cùng với chứng chỉ X.509.
- **Gia hạn (Renewal):** Chứng chỉ có thời hạn sử dụng. Trước khi hết hạn, người dùng phải thực hiện quy trình gia hạn với CA.
- **Thu hồi (Revocation):** Khi một danh tính bị xâm phạm, CA sẽ công bố một **Danh sách Thu hồi Chứng chỉ (Certificate Revocation List - CRL)** để vô hiệu hóa danh tính đó.

**Fabric CA** là triển khai CA mặc định của Hyperledger Fabric, cung cấp đầy đủ các chức năng này.

---

## 3. Các thành phần chính của Fabric 🏗️

Các thành phần trong Hyperledger Fabric được thiết kế theo dạng mô-đun, cho phép chúng tương tác với nhau để tạo thành một hệ thống sổ cái phân tán hoàn chỉnh.

### Sổ cái (Ledger)

Sổ cái không phải là một file dữ liệu đơn lẻ mà là một cấu trúc logic bao gồm hai phần khác biệt nhưng có mối liên hệ mật thiết.

- **World State (Trạng thái thế giới):**

    - **Chức năng:** Đây là cơ sở dữ liệu (database) lưu trữ trạng thái **hiện tại** của tất cả các cặp khóa-giá trị (key-value) trên kênh. Nó được tối ưu hóa cho việc truy vấn nhanh, cho phép các ứng dụng đọc giá trị mới nhất của một tài sản mà không cần phải quét qua toàn bộ lịch sử giao dịch.
    - **Tùy chọn lưu trữ:**
        - **LevelDB (Mặc định):** Một cơ sở dữ liệu khóa-giá trị hiệu suất cao được nhúng trực tiếp vào tiến trình của peer. Phù hợp nhất cho các truy vấn đơn giản, trực tiếp bằng khóa.
        - **CouchDB:** Một cơ sở dữ liệu tài liệu JSON bên ngoài. Lợi thế lớn nhất của nó là hỗ trợ **truy vấn phức tạp (rich queries)**. Bạn có thể truy vấn dữ liệu dựa trên nội dung của các thuộc tính trong tài liệu JSON, một tính năng cực kỳ hữu ích cho việc báo cáo và phân tích.

- **Blockchain (Nhật ký giao dịch):**
    - **Chức năng:** Đây là phần lưu trữ **bất biến**, ghi lại toàn bộ lịch sử các giao dịch đã xảy ra. Nó được cấu trúc như một chuỗi các khối được liên kết với nhau bằng mã băm. Mọi thay đổi đối với World State đều phải được ghi nhận tại đây.
    - **Vai trò:** Nó là nguồn chân lý duy nhất, đảm bảo tính minh bạch, khả năng kiểm toán và không thể chối bỏ của hệ thống. Nếu World State gặp sự cố, nó luôn có thể được tái tạo lại từ phần blockchain này.

---

### Hợp đồng thông minh (Chaincode)

Chaincode là "trái tim" logic của một ứng dụng Fabric.

- **Môi trường thực thi:** Để đảm bảo an toàn, chaincode không chạy trực tiếp trên tiến trình của peer. Thay vào đó, nó được thực thi trong một môi trường biệt lập, thường là một **container Docker**. Điều này ngăn chặn chaincode độc hại có thể ảnh hưởng đến peer hoặc hệ thống máy chủ.
- **Vòng đời (Lifecycle):** Việc quản trị chaincode được kiểm soát chặt chẽ thông qua một quy trình gồm nhiều bước, đòi hỏi sự đồng thuận từ các tổ chức:
    1.  **Đóng gói (Package):** Mã nguồn chaincode được đóng gói thành một tệp tin.
    2.  **Cài đặt (Install):** Quản trị viên cài đặt gói chaincode lên các peer sẽ tham gia thực thi.
    3.  **Phê duyệt (Approve):** Mỗi tổ chức cần tham gia sẽ phê duyệt một định nghĩa chaincode cho kênh (bao gồm tên, phiên bản, và chính sách xác thực).
    4.  **Cam kết (Commit):** Khi đủ số lượng tổ chức phê duyệt, một quản trị viên sẽ cam kết định nghĩa chaincode lên kênh, chính thức kích hoạt nó.
- **Tương tác với sổ cái:** Chaincode sử dụng các API `GetState` (để đọc từ World State) và `PutState` (để ghi vào World State) để tương tác với dữ liệu.

---

### Peer (Nút ngang hàng)

Peer là thành phần lao động chính của mạng lưới, được sở hữu và quản lý bởi các tổ chức thành viên.

- **Phân loại vai trò:**
    - **Endorsing Peer (Peer xác thực):** Vai trò chính là **mô phỏng** một đề xuất giao dịch bằng cách thực thi chaincode. Nếu kết quả hợp lệ, nó sẽ ký tên lên đó (tạo ra một endorsement) và gửi lại cho ứng dụng client.
    - **Committing Peer (Peer cam kết):** Mọi peer trên kênh đều là một committing peer. Sau khi các giao dịch đã được sắp xếp bởi Ordering Service và đóng thành khối, vai trò của nó là **xác thực** (kiểm tra chữ ký, kiểm tra xung đột phiên bản) và **ghi** khối đó vào bản sao sổ cái của mình.
- **Anchor Peer (Peer đại diện):** Đây là một peer được cấu hình đặc biệt trong một kênh để có thể được phát hiện bởi các peer của những tổ chức khác. Anchor Peer là thành phần thiết yếu để **giao thức Gossip** xuyên tổ chức hoạt động, giúp các peer từ các tổ chức khác nhau có thể chia sẻ thông tin về trạng thái sổ cái.
- **Giao thức Gossip:** Peer sử dụng giao thức này để phân phối dữ liệu một cách hiệu quả. Nó giúp lan truyền các khối đã được xác nhận đến các peer khác trong cùng tổ chức và chia sẻ thông tin trạng thái mạng với các tổ chức khác.

---

### Ordering Service (Dịch vụ sắp xếp thứ tự)

Đây là thành phần đảm bảo tính nhất quán trên toàn kênh.

- **Chức năng cốt lõi:** Vai trò duy nhất của Ordering Service là tiếp nhận các giao dịch đã được endorse, thiết lập một **thứ tự tuần tự, không thể chối cãi** cho chúng, sau đó đóng gói chúng vào các khối và phát sóng đến tất cả các peer. Nó **không** kiểm tra nội dung hay tính hợp lệ của giao dịch; việc đó là của các peer.
- **Cơ chế đồng thuận:**
    - **Raft (Khuyến nghị):** Là một cơ chế đồng thuận dựa trên mô hình leader-follower. Nó có khả năng chịu lỗi khi có sự cố (Crash Fault Tolerant - CFT), nghĩa là hệ thống vẫn hoạt động khi một số nút orderer bị sập. Raft phù hợp cho các mạng doanh nghiệp, nơi các thành viên có một mức độ tin cậy nhất định và không có hành vi phá hoại (Byzantine).

---

### Channel (Kênh)

Channel là cơ chế mạnh mẽ nhất của Fabric để đảm bảo **tính bảo mật và cô lập dữ liệu**.

- **Cấu trúc:** Một kênh về cơ bản là một sổ cái riêng biệt. Mỗi kênh được định nghĩa bởi một **khối cấu hình (configuration block)**, trong đó chứa các thông tin quan trọng như:
    - Các thành viên (tổ chức) được tham gia kênh.
    - Các chính sách (policies) quản lý kênh (ví dụ: ai có quyền đọc, ai có quyền ghi, chính sách xác thực chaincode).
    - Thông tin về các Anchor Peer của mỗi tổ chức.
- **Tính bảo mật:** Các giao dịch, sổ cái và thành viên của một kênh hoàn toàn bị cô lập với các kênh khác. Một tổ chức có thể tham gia nhiều kênh khác nhau trên cùng một mạng lưới Fabric, nhưng dữ liệu giữa các kênh này không thể bị truy cập chéo.

---

## 4. Luồng xử lý chi tiết của một Giao dịch 🔄

Kiến trúc của Fabric chia quy trình xử lý giao dịch thành 3 giai đoạn chính: **Thực thi (Execute)**, **Sắp xếp (Order)**, và **Xác thực (Validate)**. Hãy xem xét luồng này từ góc nhìn của người dùng cuối.

### Từ góc nhìn của người dùng cuối (End-User)

1.  **Khởi tạo yêu cầu:** Một **người dùng cuối** (end-user) tương tác với một **ứng dụng client** (ví dụ: một ứng dụng di động hoặc trang web) để thực hiện một hành động, chẳng hạn như nhấn nút "Chuyển tài sản".
2.  **Ứng dụng Client chuẩn bị:** Ứng dụng client, sử dụng **Fabric SDK**, sẽ thu thập thông tin định danh của người dùng (chứng chỉ số). Nó biết rằng để thực hiện hành động này, cần phải gọi hàm `transferAsset` trong chaincode.

### Giai đoạn 1: Thực thi & Xác thực (Execute & Endorse)

3.  **Tạo Đề xuất (Proposal):** SDK thay mặt người dùng tạo ra một **đề xuất giao dịch**. Đề xuất này chứa các thông tin như: ID của chaincode, hàm cần gọi (`transferAsset`), các tham số đầu vào (ví dụ: `assetID`, `newOwner`), và chữ ký của người dùng.
4.  **Gửi để Xác thực:** SDK gửi đề xuất này đến các **Endorsing Peer** của các tổ chức được quy định trong **Chính sách xác thực (Endorsement Policy)**.
5.  **Mô phỏng và Ký:** Mỗi Endorsing Peer nhận đề xuất và thực hiện các bước sau:
    - **Xác minh chữ ký:** Kiểm tra xem người dùng có quyền thực hiện hành động này không.
    - **Mô phỏng giao dịch:** Thực thi hàm `transferAsset` trên một bản sao tạm thời của World State. **Lưu ý:** Sổ cái thật chưa bị thay đổi.
    - **Tạo Tập đọc-ghi (Read-Write Set):** Kết quả của việc mô phỏng là một "Tập đọc-ghi", ghi lại những dữ liệu đã được đọc (Read Set) và những dữ liệu sẽ được ghi nếu giao dịch thành công (Write Set).
    - **Ký xác thực:** Peer ký tên lên Tập đọc-ghi này bằng khóa riêng của mình và gửi lại cho ứng dụng client. Đây chính là một **sự xác thực (endorsement)**.

### Giai đoạn 2: Sắp xếp (Order)

6.  **Tập hợp Phản hồi:** Ứng dụng client nhận các phản hồi đã được ký từ các Endorsing Peer. Nó kiểm tra xem các chữ ký có hợp lệ và kết quả (Tập đọc-ghi) có nhất quán không.
7.  **Gửi giao dịch để Sắp xếp:** Nếu đủ số lượng xác thực yêu cầu, client sẽ gói đề xuất gốc cùng tất cả các phản hồi đã ký vào một **giao dịch** hoàn chỉnh và gửi nó đến **Ordering Service**.
8.  **Tạo Khối:** Ordering Service nhận các giao dịch từ nhiều client khác nhau. Nó không quan tâm đến nội dung giao dịch. Nhiệm vụ duy nhất của nó là sử dụng cơ chế đồng thuận (Raft) để thống nhất về một **thứ tự** cho tất cả các giao dịch này, sau đó đóng gói chúng vào một **khối (block)** mới.

### Giai đoạn 3: Xác thực & Cam kết (Validate & Commit)

9.  **Phân phối Khối:** Ordering Service phát sóng khối mới đến tất cả các **peer** trong kênh.
10. **Xác thực trên từng Peer:** Mỗi peer (kể cả các Endorsing Peer ban đầu) nhận khối mới và thực hiện một loạt các bước kiểm tra cho **từng giao dịch** trong khối:
    - **Kiểm tra Chính sách xác thực:** Giao dịch có đủ chữ ký hợp lệ từ các tổ chức được yêu cầu không?
    - **Kiểm tra xung đột phiên bản (MVCC check):** Peer xem xét **Read Set** của giao dịch. Nó kiểm tra xem các dữ liệu mà giao dịch này đã đọc trong lúc mô phỏng (bước 5) có bị một giao dịch khác (đã được xác nhận trước đó) thay đổi hay không. Nếu có, giao dịch này sẽ bị đánh dấu là không hợp lệ để tránh tình trạng "chi tiêu hai lần".
11. **Cam kết vào Sổ cái:**
    - Nếu giao dịch vượt qua tất cả các bước kiểm tra, peer sẽ ghi khối vào **blockchain** của mình và cập nhật **World State** với dữ liệu từ **Write Set**.
    - Nếu giao dịch không hợp lệ, nó vẫn được ghi lại trên blockchain nhưng được đánh dấu là "không hợp lệ", và World State sẽ không được cập nhật.
12. **Thông báo:** Peer phát ra một sự kiện để thông báo cho ứng dụng client rằng giao dịch đã được cam kết thành công (hoặc thất bại) vào sổ cái. Ứng dụng client sau đó có thể cập nhật giao diện cho người dùng cuối.

---

## 5. Phân tích chi tiết: Lưu trữ Dữ liệu và Lựa chọn Cơ sở dữ liệu 🗄️

Việc hiểu cách Hyperledger Fabric lưu trữ dữ liệu là yếu tố then chốt để thiết kế một ứng dụng hiệu quả. Dữ liệu trên mỗi peer được chia thành các thành phần riêng biệt, mỗi thành phần có một mục đích và cơ chế lưu trữ khác nhau.

### 5.1. Các thành phần lưu trữ dữ liệu

Dữ liệu sổ cái trên mỗi peer được lưu trữ vật lý trên hệ thống tệp và bao gồm các thành phần sau:

- **Blockchain (Nhật ký giao dịch):**

    - **Mục đích:** Đây là thành phần cốt lõi, lưu trữ một chuỗi các khối (block) bất biến và chỉ cho phép ghi thêm (append-only). Nó chứa toàn bộ lịch sử của tất cả các giao dịch đã từng xảy ra trên kênh.
    - **Lưu trữ:** Được lưu dưới dạng một chuỗi các tệp tin nhị phân đơn giản trên hệ thống tệp của peer. Cấu trúc này đảm bảo tính toàn vẹn và khả năng kiểm toán tuyệt đối.

- **World State (Trạng thái thế giới):**

    - **Mục đích:** Là một cơ sở dữ liệu, đóng vai trò như một "bản chụp nhanh" của trạng thái hiện tại của tất cả các cặp khóa-giá trị trong sổ cái. Nó được tối ưu hóa để truy vấn nhanh chóng, giúp các ứng dụng không cần phải quét lại toàn bộ blockchain để biết giá trị mới nhất của một tài sản.
    - **Lưu trữ:** Đây là nơi bạn phải đưa ra lựa chọn quan trọng giữa **LevelDB** và **CouchDB**.

- **Private Data Collections (Bộ sưu tập Dữ liệu Riêng tư):**
    - **Mục đích:** Dùng để lưu trữ các dữ liệu nhạy cảm mà chỉ một nhóm tổ chức trong kênh được phép xem.
    - **Lưu trữ:** Dữ liệu thực tế được lưu trong một cơ sở dữ liệu riêng biệt trên các peer của các tổ chức được cấp phép. Chỉ có **mã băm (hash)** của dữ liệu này được ghi lên sổ cái chung của kênh làm bằng chứng.

### 5.2. So sánh chi tiết: Khi nào nên dùng CouchDB thay vì LevelDB?

Lựa chọn giữa LevelDB và CouchDB cho World State là một trong những quyết định kiến trúc quan trọng nhất khi xây dựng ứng dụng Fabric.

| Tiêu chí               | **LevelDB (Mặc định)**                                                                                     | **CouchDB (Tùy chọn)**                                                                                                                                                 |
| :--------------------- | :--------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Mô hình Dữ liệu**    | **Khóa-Giá trị (Key-Value)**. Dữ liệu được lưu trữ đơn giản dưới dạng một khóa và một giá trị (dạng byte). | **Tài liệu (Document-based)**. Dữ liệu được lưu dưới dạng tài liệu **JSON**, cho phép cấu trúc phức tạp và có thứ bậc.                                                 |
| **Khả năng Truy vấn**  | **Đơn giản**. Chỉ hỗ trợ truy vấn bằng khóa (`GetStateByKey`) và theo dải khóa (`GetStateByRange`).        | **Phức tạp & Linh hoạt (Rich Queries)**. Hỗ trợ truy vấn dựa trên nội dung của tài liệu JSON. Bạn có thể lọc, sắp xếp, và tổng hợp dữ liệu.                            |
| **Chỉ mục (Indexing)** | Không hỗ trợ chỉ mục trên giá trị. Việc tìm kiếm dựa trên giá trị đòi hỏi phải quét toàn bộ dữ liệu.       | **Hỗ trợ chỉ mục**. Bạn có thể tạo chỉ mục trên bất kỳ trường nào trong tài liệu JSON để tăng tốc độ truy vấn phức tạp một cách đáng kể.                               |
| **Hiệu suất**          | **Rất nhanh** cho các thao tác đọc/ghi đơn giản dựa trên khóa.                                             | **Chậm hơn** một chút cho các thao tác đơn giản do chi phí xử lý JSON và giao tiếp qua mạng, nhưng **cực kỳ hiệu quả** cho các truy vấn phức tạp đã được đánh chỉ mục. |
| **Vận hành**           | **Nhúng sẵn**. Chạy trong cùng tiến trình của peer, không cần quản lý thêm.                                | **Dịch vụ ngoài**. Cần phải triển khai, quản lý, sao lưu và bảo mật như một cụm cơ sở dữ liệu riêng biệt.                                                              |

#### **Kết luận và Lời khuyên:**

- **Hãy dùng LevelDB khi:**

    - Ứng dụng của bạn chủ yếu thực hiện các giao dịch đơn giản, truy vấn bằng một ID duy nhất (ví dụ: truy xuất thông tin xe bằng số VIN, kiểm tra số dư tài khoản bằng ID người dùng).
    - Bạn ưu tiên hiệu suất giao dịch thô ở mức cao nhất.
    - Mọi phân tích dữ liệu phức tạp sẽ được thực hiện off-chain (ngoài chuỗi), bằng cách sao chép dữ liệu sang một hệ thống phân tích khác.
    - Bạn muốn một hệ thống đơn giản, dễ triển khai và vận hành.

- **Hãy dùng CouchDB khi:**
    - Ứng dụng của bạn **yêu cầu khả năng truy vấn dữ liệu theo nhiều thuộc tính khác nhau**, không chỉ dựa vào khóa chính.
    - Bạn cần xây dựng các tính năng báo cáo, bảng điều khiển (dashboard), hoặc phân tích trực tiếp trên dữ liệu sổ cái.
    - Dữ liệu của bạn có cấu trúc phức tạp và việc lưu trữ dưới dạng JSON sẽ tự nhiên và dễ quản lý hơn.
    - **Ví dụ điển hình:**
        - **Chuỗi cung ứng:** "Tìm tất cả các lô hàng từ cảng X, đã đến nơi trong tháng trước, và có nhiệt độ bảo quản dưới 5°C."
        - **Quản lý tài sản:** "Liệt kê tất cả các bất động sản ở Quận 1 có diện tích trên 100m² và chưa được bán."
        - **Y tế:** "Tìm tất cả các hồ sơ bệnh nhân nam, trên 40 tuổi, có chẩn đoán liên quan đến bệnh tim."

Việc sử dụng CouchDB sẽ làm tăng độ phức tạp trong việc triển khai và vận hành, nhưng sức mạnh mà nó mang lại cho việc truy vấn dữ liệu thường là sự đánh đổi xứng đáng cho các ứng dụng doanh nghiệp phức tạp.

---

## 6. So sánh Tiền Mã Hóa và Tiền Pháp Định ⚖️

Hyperledger Fabric được thiết kế để không cần đến tiền mã hóa. Bảng dưới đây làm rõ sự khác biệt.

| Đặc điểm            | **Tiền Mã Hóa (ví dụ: Bitcoin)**                                                                                                                                                                                                                | **Tiền Pháp Định (ví dụ: VNĐ, USD)**                                    |
| :------------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------- |
| **Kiểm soát**       | **Phi tập trung**. Không do ngân hàng trung ương hay chính phủ nào kiểm soát.                                                                                                                                                                   | **Tập trung**. Do ngân hàng trung ương và chính phủ phát hành, quản lý. |
| **Cơ sở Công nghệ** | Hoạt động trên **Blockchain**. Ví dụ, **Bitcoin** sử dụng cơ chế đồng thuận **Proof-of-Work**, nơi các 'thợ đào' (miners) dùng năng lượng tính toán để xác thực giao dịch và tạo ra các khối mới, đổi lại họ nhận được Bitcoin làm phần thưởng. | Giao dịch qua các trung gian tài chính như ngân hàng.                   |
| **Giá trị**         | Dựa trên **cung và cầu** thị trường, rất biến động.                                                                                                                                                                                             | Được **chính phủ bảo đảm** và có tính ổn định tương đối.                |

---

## 7. Kiến trúc Mô-đun và Linh hoạt 🧩

Một trong những sức mạnh lớn nhất của Fabric là kiến trúc mô-đun, cho phép "cắm và chạy" (pluggable) nhiều thành phần để phù hợp với nhu cầu cụ thể của doanh nghiệp. Điều này có nghĩa là Fabric không phải là một giải pháp "một kích cỡ cho tất cả", mà là một bộ công cụ linh hoạt.

- **Đồng thuận (Consensus) có thể cắm và chạy:**

    - **Ý nghĩa:** Dịch vụ sắp xếp thứ tự không bị ràng buộc với một thuật toán duy nhất. Doanh nghiệp có thể chọn cơ chế phù hợp nhất với mô hình tin cậy của mình.
    - **Ví dụ:**
        - **Raft (CFT):** Được khuyến nghị cho hầu hết các trường hợp sử dụng. Nó nhanh, hiệu quả và giả định rằng các nút orderer có thể bị sập (crash) nhưng sẽ không cố tình gửi thông tin sai lệch. Điều này phù hợp với một consortium nơi các tổ chức tin tưởng lẫn nhau ở một mức độ nhất định.
        - **BFT (Byzantine Fault Tolerant):** Các cơ chế như PBFT có thể được triển khai nếu mạng lưới yêu cầu mức độ bảo mật cao nhất, có khả năng chống lại cả các nút orderer độc hại, cố tình phá hoại. Sự đánh đổi là hiệu suất thường sẽ thấp hơn so với Raft.

- **Cơ sở dữ liệu Trạng thái (State DB) có thể cắm và chạy:**

    - **Ý nghĩa:** Việc lựa chọn cơ sở dữ liệu cho World State ảnh hưởng trực tiếp đến khả năng và hiệu suất của ứng dụng.
    - **Ví dụ:**
        - **LevelDB:** Nếu ứng dụng của bạn chủ yếu thực hiện các giao dịch đơn giản như cập nhật quyền sở hữu tài sản (truy vấn bằng ID tài sản), LevelDB là lựa chọn tối ưu vì tốc độ cao và không cần quản lý cơ sở dữ liệu ngoài.
        - **CouchDB:** Nếu bạn cần xây dựng một bảng điều khiển (dashboard) để phân tích "tất cả các xe ô tô màu đỏ được sản xuất sau năm 2020", CouchDB là lựa chọn bắt buộc. Nó cho phép bạn thực hiện các truy vấn phức tạp trực tiếp trên dữ liệu sổ cái mà không cần phải sao chép dữ liệu sang một hệ thống phân tích riêng biệt.

- **Quản lý danh tính (Identity) có thể cắm và chạy:**

    - **Ý nghĩa:** Lớp **MSP** là một giao diện trừu tượng. Điều này cho phép doanh nghiệp tích hợp liền mạch Fabric với các hệ thống quản lý danh tính mà họ đã và đang sử dụng.
    - **Ví dụ:** Một ngân hàng lớn đã có sẵn hệ thống **Active Directory** để quản lý nhân viên. Thay vì tạo ra một hệ thống danh tính mới chỉ cho blockchain, họ có thể phát triển một MSP tùy chỉnh để kết nối với Active Directory. Khi một nhân viên được thêm hoặc xóa khỏi Active Directory, quyền truy cập của họ vào mạng Fabric cũng sẽ được cập nhật tương ứng. Điều này giúp giảm đáng kể chi phí vận hành và quản lý.

- **Logic nghiệp vụ (Business Logic) có thể cắm và chạy:**
    - **Ý nghĩa:** Bản thân **Chaincode** chính là một mô-đun. Các quy tắc kinh doanh, chính sách xác thực và logic giao dịch hoàn toàn do người phát triển định nghĩa và có thể được nâng cấp độc lập với phần còn lại của mạng lưới.
    - **Ví dụ:** Một mạng lưới chuỗi cung ứng ban đầu có thể có một chaincode đơn giản để theo dõi việc vận chuyển. Sau đó, họ có thể dễ dàng nâng cấp chaincode để thêm các chức năng mới như thanh toán tự động khi nhận hàng hoặc kiểm tra chất lượng sản phẩm, mà không cần phải xây dựng lại toàn bộ mạng lưới.

---

## 8. Q&A - Các câu hỏi thường gặp ❓

**1. Hyperledger Fabric có cần tiền mã hóa (crypto) không?**

> **Không.** Fabric được thiết kế cho các mạng lưới doanh nghiệp nơi các thành viên đã được xác định. Nó không cần một đồng tiền mã hóa để tạo động lực cho "thợ đào" hay để trả phí gas. Điều này giúp loại bỏ sự biến động giá và các rào cản pháp lý.

**2. Sự khác biệt chính giữa Fabric và Ethereum là gì?**

> - **Đối tượng:** Fabric dành cho doanh nghiệp (B2B), Ethereum chủ yếu là công cộng (B2C).
> - **Quyền truy cập:** Fabric là mạng **riêng tư, được cấp phép** (permissioned). Ethereum là mạng **công khai, không cần cấp phép** (permissionless).
> - **Bảo mật:** Fabric dùng kênh (channels) để bảo mật dữ liệu. Trên Ethereum công khai, mọi dữ liệu đều công khai.
> - **Đồng thuận:** Fabric dùng Raft. Ethereum dùng Proof-of-Stake.
> - **Tiền tệ:** Fabric không có tiền tệ gốc. Ethereum có Ether (ETH).

**3. Khi nào nên dùng CouchDB thay vì LevelDB?**

> Hãy dùng **CouchDB** khi ứng dụng của bạn cần thực hiện các **truy vấn phức tạp** trên dữ liệu (ví dụ: "tìm tất cả các tài sản có màu đỏ và giá trị lớn hơn 100"). Nếu bạn chỉ cần truy vấn dữ liệu bằng khóa chính của nó, **LevelDB** sẽ nhanh hơn và đơn giản hơn.

**4. Một tổ chức có thể tham gia nhiều kênh không?**

> **Có.** Đây là một tính năng rất mạnh mẽ. Một tổ chức có thể tham gia vào nhiều kênh khác nhau, mỗi kênh có một sổ cái và một nhóm thành viên riêng, cho phép họ tham gia vào nhiều mạng lưới kinh doanh khác nhau một cách riêng biệt và an toàn.

**5. "Endorsement Policy" (Chính sách xác thực) là gì?**

> Đây là một chính sách được định nghĩa cho mỗi chaincode, quy định rằng **những tổ an chức nào** và **bao nhiêu tổ chức** phải ký tên (xác thực) lên một giao dịch thì giao dịch đó mới được coi là hợp lệ. Ví dụ, một chính sách có thể yêu cầu "Cả Tổ chức A VÀ Tổ chức B phải cùng xác thực" hoặc "Ít nhất 2 trong số 3 tổ chức A, B, C phải xác thực".

---