**Bước 3: Giai đoạn Xác thực & Commit (Validation & Commit) - ĐÂY LÀ NƠI LOGIC KIỂM TRA NẰM**

1. Ordering Service gửi khối mới này đến **tất cả các peer** trong channel (bao gồm cả endorsing peer và non-endorsing peer).
2. Mỗi peer nhận được khối này sẽ thực hiện một loạt các kiểm tra cho **từng giao dịch** trong khối trước khi commit:
    - **Kiểm tra Policy:** Giao dịch có đủ chữ ký hợp lệ từ các Endorsing Peer đúng theo policy không?
    - **Kiểm tra MVCC (Quan trọng nhất):** Peer sẽ nhìn vào **Read Set** của giao dịch. Đối với mỗi key trong Read Set, nó sẽ so sánh **phiên bản được ghi trong Read Set** với **phiên bản hiện tại của key đó trong World State (CouchDB) của chính nó**.
        - **TRƯỜNG HỢP 1 (Hợp lệ):** Nếu tất cả các phiên bản đều khớp, điều này có nghĩa là không có giao dịch nào khác đã thay đổi dữ liệu này kể từ khi nó được mô phỏng. Giao dịch được coi là **hợp lệ**. Peer sẽ ghi khối vào blockchain của mình và áp dụng **Write Set** vào World State (Cập nhật CouchDB và tăng số phiên bản của key).
        - **TRƯỜDNG HỢP 2 (Không hợp lệ):** Nếu có ít nhất một phiên bản không khớp, điều này có nghĩa là một giao dịch khác đã cập nhật key này trước. Giao dịch này được coi là **không hợp lệ**. Peer sẽ đánh dấu giao dịch này là invalid trong khối, ghi khối vào blockchain (để lưu lại dấu vết), nhưng **sẽ không áp dụng Write Set vào World State**.
