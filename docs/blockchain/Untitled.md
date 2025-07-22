Các **public blockchain** như Bitcoin hay Ethereum được thiết kế để đảm bảo tính minh bạch và toàn vẹn tuyệt đối. Mọi giao dịch (transaction) được thực hiện trên mạng lưới đều được ghi lại công khai và tất cả các node tham gia đều có một bản sao của toàn bộ sổ cái (ledger).

- **Toàn bộ dữ liệu được sao chép:** Để đạt được sự đồng thuận phân tán (distributed consensus), mọi người tham gia phải có khả năng xác thực mọi giao dịch. Điều này có nghĩa là không có khái niệm về bảo mật hay che giấu dữ liệu.
    
- **Mục tiêu là minh bạch:** Kiến trúc này phù hợp với các ứng dụng công khai, nơi tính minh bạch là ưu tiên hàng đầu. Tuy nhiên, đối với các doanh nghiệp, việc để lộ dữ liệu kinh doanh nhạy cảm (như thông tin giá cả, chi tiết hợp đồng, thông tin khách hàng) cho tất cả các bên, đặc biệt là đối thủ cạnh tranh, là điều không thể chấp nhận.

Do đó, mô hình của public blockchain vốn không được thiết kế cho các trường hợp sử dụng cần đến tính bảo mật dữ liệu.

---

### Giải pháp của Hyperledger Fabric

Hyperledger Fabric là một **permissioned blockchain**, được xây dựng từ đầu để đáp ứng các yêu cầu của doanh nghiệp, trong đó bảo mật dữ liệu là một trong những ưu tiên hàng đầu. Fabric giải quyết vấn đề này thông qua hai cơ chế chính: **Channels** và **Private Data Collections**.

#### 1. Kiến trúc Channel

**Channel** là cơ chế bảo mật nền tảng trong Fabric. Về bản chất, một channel là một "subnet" giao tiếp riêng tư giữa một tập hợp các thành viên cụ thể trong mạng lưới blockchain.

- **Phân vùng Sổ cái (Ledger Segregation):** Mỗi channel có một sổ cái hoàn toàn riêng biệt. Dữ liệu giao dịch và trạng thái thế giới (world state) của một channel chỉ được lưu trữ và truy cập bởi các peer (node) của những tổ chức là thành viên của channel đó.
    
- **Cách ly Giao dịch (Transaction Isolation):** Các giao dịch được gửi đến một channel sẽ hoàn toàn vô hình đối với các thành viên không thuộc channel đó. Điều này cho phép các nhóm tổ chức khác nhau thực hiện giao dịch một cách riêng tư và bảo mật trên cùng một mạng lưới vật lý mà không làm lộ thông tin cho nhau.
    
- **Kiểm soát truy cập:** Chính sách (policy) của channel sẽ định nghĩa quyền đọc/ghi và các quy tắc quản trị khác, đảm bảo chỉ những thành viên được cấp phép mới có thể tham gia và tương tác.
    

Ví dụ, trong một mạng lưới chuỗi cung ứng, Nhà sản xuất, Nhà vận chuyển A và Nhà bán lẻ A có thể tạo một channel để giao dịch riêng tư, trong khi Nhà sản xuất, Nhà vận chuyển B và Nhà bán lẻ B có thể hoạt động trên một channel khác.

#### 2. Private Data Collections (PDC)

Channels cung cấp một lớp bảo mật mạnh mẽ, nhưng đôi khi doanh nghiệp cần sự riêng tư ở mức độ chi tiết hơn nữa. Giả sử trong một channel có nhiều thành viên, nhưng một giao dịch cụ thể chỉ nên được chia sẻ giữa một nhóm nhỏ các thành viên đó. Đây là lúc **Private Data Collections (PDC)** phát huy tác dụng.

- **Mục tiêu:** Cho phép một tập hợp con các tổ chức trong cùng một channel chia sẻ dữ liệu riêng tư mà không cần phải tạo một channel mới.
    
- **Cơ chế hoạt động:**
    
    1. **Dữ liệu thực tế:** Dữ liệu riêng tư thực sự không được ghi lên sổ cái chung của channel. Thay vào đó, nó được truyền trực tiếp **peer-to-peer** thông qua giao thức gossip và chỉ đến các peer của những tổ chức được ủy quyền trong collection policy.
        
    2. **Bằng chứng trên Sổ cái:** Một **hash** của dữ liệu riêng tư đó sẽ được ghi lên sổ cái chung của channel.
        
- **Lợi ích:**
    
    - **Bảo mật dữ liệu:** Dữ liệu nhạy cảm được giữ bí mật tuyệt đối với các bên không được phép ngay cả khi họ ở trong cùng một channel.
        
    - **Tính xác thực:** Hash trên sổ cái công khai đóng vai trò là bằng chứng không thể thay đổi (immutable proof) về sự tồn tại và tính toàn vẹn của giao dịch mà không tiết lộ nội dung. Mọi thành viên trong channel đều có thể xác thực giao dịch dựa trên hash này.
        

Bằng cách kết hợp **Channels** để phân vùng sổ cái và **Private Data Collections** để bảo mật dữ liệu ở cấp độ giao dịch, Hyperledger Fabric cung cấp một kiến trúc linh hoạt và mạnh mẽ, cho phép các doanh nghiệp cộng tác trên một mạng lưới chung trong khi vẫn duy trì được sự kiểm soát chặt chẽ đối với tài sản dữ liệu của mình.