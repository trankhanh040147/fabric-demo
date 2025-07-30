# Q&A self
- [ ] Làm sao để kết đến mạng bằng CCP ?
# Q&A lần 1
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
# Q&A lần 2 (cho present buổi tiếp theo)
A. DEPLOY NHIỀU TỔ CHỨC:
1. Deploy với 3 tổ chức (mỗi tổ chức 3 peers) và chỉnh sửa cơ chế approve chaincode (ví dụ: cần 2 trong 3 tổ chức approve chaincode)
 - [x] Quy trình tạo tổ chức thứ 3 và tham gia vào mạng: 
    - Tạo tài nguyên cho tổ chức thứ 3
	    - chứng chỉ: chạy commands : `cryptogen generate --config=org3-crypto.yaml --output="../organizations"`
	    - CCP
    - Cập nhật lại config của channel (Cập nhật ntn ?)
- [x] Khi tổ chức 3 tham gia vào channel, tổ chức 3 không có quyền endorse, tại sao ?
      --> do chaincode policy được định nghĩa trước đó chỉ dành cho Org1 và Org2, để org3 có thể tham gia endorse transaction thì chaincode phải được upgrade
- [x] Nếu tất cả tổ chức 2 bị mất kết nối, thì chuyện gì sẽ xảy ra ?
      --> Không thể endorse transaction vì không đủ số phiếu (2 trong 3)
- [x] deploy chaincode trên 3 tổ chức (dùng -norgs 3)
- [x] Khi các peers của tổ chức 3 tham gia vào mạng, nó không được cài sẵn các chaincode đã có trên channel, phải làm sao để cài được các chaincode đã có ?
	-  **Cách 1**: cài đặt và approve chaincode đã có sẵn (sau khi cài đặt chaincode lên các peers của org3, org3 có thể tham gia vào quá trình endorse) 
	`./network.sh deployCCOrg3 -c mychannel -ccn basic -ccl go -ccp ../asset-transfer-basic/chaincode-go`
  
- [x] Cách xóa một chaincode đã có sẵn ?
	--> Không thể xóa một chaincode hoàn toàn ra khỏi channel, chỉ có thể xóa các container chạy chaincode đó. Trong Fabric, **không thể "xóa" hoàn toàn** một chaincode đã được commit ra khỏi lịch sử của channel để thỏa mãn tính bất biến của blockchain
	- [x] Nếu xóa hết tất cả chaincode thì sao ?
	--> Peer sẽ tự động restore lại chaincode
	- [x] Làm cái nào để disable, remove một chaincode đang hoạt động ?
	      - xóa container đang chạy 
	      - xóa file system 
	      - xóa image
	https://learn.microsoft.com/en-us/answers/questions/97249/how-to-remove-old-chaincode-containers-and-chainco
B. CHÍNH SÁCH ĐỒNG THUẬN:
1. Cách để phân quyền chỉ cho các tổ chức có thể gọi các hàm trong chaincode (vd: tổ chức 1 có thể gọi hàm A, B, tổ chức 2,3 có thể gọi hàm B, C)?
- [x] Thử nghiệm deploy một chaincode với 3 source code khác nhau
- Khi 2 chaincode có cùng một hàm CreateAsset, nhưng logic của 2 hàm khác nhau thì chuyện gì sẽ xảy ra khi thực thi CreateAsset ? --> gặp lỗi mismatch write value
- Khi policy là **OR(Org1, OutOf(2, Org1,Org2,Org3))**, và chỉ có tổ chức 1 có quyền CreateAsset, thì có thể thực thi CreateAsset hay không ? 
  --> Tổ chức 1 có thể thực thi, còn tổ chức 2 thì ko

C. CƠ CHẾ MANUAL ĐỂ ENDORSE VÀ COMMIT TRANSACTION  
1. Có thể cho phép endorse một transaction bằng cách thủ công?
- [ ] set up các dịch vụ cho phép:
	- [x] client tạo một proposal và trả về transaction id
	- [ ] peer endorse một transaction bằng transaction id đó (mỗi peer = 1 dịch vụ api)
	- [ ] test lấy cái events bằng cách gọi NewSignedChaincodeEventsRequest
	
D. CƠ CHẾ PHỤC HỒI:
1. Tại sao khi thay đổi dữ liệu World State thì GetAllAssets lại trả về dữ liệu bị sửa đổi (dữ liệu lấy trực tiếp từ World State) còn khi lấy dữ liệu bị thay đổi bằng ReadAsset thì lại có thể lấy được dữ liệu gốc ?
2. Cách để phục hồi peer khi bị xóa blockchain (transaction log) ?
3. Nếu sửa dữ liệu trên blockchain của một peer, thì chuyện gì xảy ra ? Làm sao để phục hồi ? 

---
## DEMO
### DEPLOY NHIỀU TỔ CHỨC 
- Kịch bản deploy 3 tổ chức là: Ban đầu chỉ có 2 tổ chức nắm giữ chaincode, sau đó tổ chức thứ 3 muốn tham gia vào mạng
- Deploy 2 tổ chức, sau đó chạy chaincode để cho thấy quá trình endorse diễn ra ở 2 org như thế nào ?
- Khi DeployCC trên 2 tổ chức mà không quy định policy chứng thực, nó sẽ mặc định dùng chính "MAJORITY" tức có nghĩa là cả 2 tổ chức phải chứng thực giao dịch (một peer mỗi tổ chức)
- Thay đổi policy và test lại: 
	- Chỉ tổ chức 1 endorse (50% peer của tổ chức 1)
	- 50% peer của tổ chức 1 và 50% peer của tổ chức 2
	- Thay đổi lại policy thành MAJORITY để test xem tổ chức 3 có được quyền endorse ko ? 
- Deploy tổ chức 3 vào mạng, sẽ đi qua các bước: 
	- Tương tự như quá trình deploy 2 tổ chức, thì tổ chức 3 cũng phải có file org3-crypto.yaml để generate ra số certs của các peers và user
	- Tạo các file compose cho 3 peers và 3 db
	- Tạo một config transaction để ghi nhận việc thêm org3 vào channel (nếu không ghi transaction vào thì sao ?)
- Sau khi deploy tổ chức 3 vào mạng, thì tổ chức 3 sẽ có thể:
	- Thực hiện query transaction 
	- Thực hiện invoke transaction để tạo, update asset
---
### Trả lời câu hỏi
1. Con peer nào sẽ làm boootstrap cho các peer trong một tổ chức ?