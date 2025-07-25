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

B. CHÍNH SÁCH ĐỒNG THUẬN:
1. Cách để phân quyền chỉ cho các tổ chức có thể gọi các hàm trong chaincode (vd: tổ chức 1 có thể gọi hàm A, B, tổ chức 2,3 có thể gọi hàm B, C)?

C. CƠ CHẾ MANUAL ĐỂ ENDORSE VÀ COMMIT TRANSACTION  
1. Có thể cho phép endorse một transaction bằng cách thủ công?

D. CƠ CHẾ PHỤC HỒI:
1. Tại sao khi thay đổi dữ liệu World State thì GetAllAssets lại trả về dữ liệu bị sửa đổi (dữ liệu lấy trực tiếp từ World State) còn khi lấy dữ liệu bị thay đổi bằng ReadAsset thì lại có thể lấy được dữ liệu gốc ?
2. Cách để phục hồi peer khi bị xóa blockchain (transaction log) ?
3. Nếu sửa dữ liệu trên blockchain của một peer, thì chuyện gì xảy ra ? Làm sao để phục hồi ? 