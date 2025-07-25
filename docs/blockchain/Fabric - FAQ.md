# Q: Tại sao khi thay đổi dữ liệu trên tất cả các  peers (couchdb) trong một channel, thì khi query ReadAsset lại dữ liệu vẫn không thay đổi ? Có cách nào thay đổi dữ liệu mà khi query ReadAsset thì lấy được dữ liệu đã thay đổi đó ?


### Tại sao `ReadAsset` không trả về dữ liệu đã sửa trong CouchDB?

Lý do chính là: **Hyperledger Fabric không coi CouchDB là nguồn chân lý (Source of Truth) duy nhất. Nguồn chân lý thực sự là chuỗi khối (blockchain) bất biến.**

1. **Kiến trúc Ledger của Fabric:** Mỗi peer trong Fabric quản lý một "ledger" (sổ cái). Sổ cái này bao gồm hai phần chính:
    
    - **Blockchain (Transaction Log):** Một chuỗi các khối được liên kết với nhau, chứa toàn bộ lịch sử giao dịch đã được xác thực và sắp xếp. Phần này là **bất biến (immutable)**. Một khi giao dịch đã được ghi vào đây, nó không thể bị thay đổi.
    - **World State (Trạng thái thế giới):** Một cơ sở dữ liệu (trong trường hợp của bạn là CouchDB) lưu trữ giá trị _hiện tại_ của tất cả các cặp key-value (assets). World State hoạt động như một bộ đệm (cache) được tối ưu hóa để truy vấn nhanh chóng trạng thái mới nhất của dữ liệu, mà không cần phải quét lại toàn bộ blockchain.
2. **Mối quan hệ giữa Blockchain và World State:** World State được **tạo ra và cập nhật** từ các giao dịch hợp lệ trong blockchain. Khi một peer nhận một khối mới từ Ordering Service, nó sẽ:
    
    - Xác thực từng giao dịch trong khối.
    - Nếu giao dịch hợp lệ, peer sẽ "commit" khối đó vào blockchain của mình.
    - Sau đó, nó sẽ cập nhật World State (CouchDB) dựa trên kết quả đọc/ghi (read/write set) của giao dịch đó.
3. **Vấn đề khi sửa trực tiếp CouchDB:** Khi bạn đăng nhập vào CouchDB và thay đổi một bản ghi, bạn chỉ đang can thiệp vào **bộ đệm (World State)**. Hành động này **không tạo ra một giao dịch mới, không được xác thực bởi các peer, và không được ghi vào chuỗi khối bất biến**.
    
    Do đó, khi bạn gọi hàm chaincode `ReadAsset`, peer sẽ thực hiện kiểm tra tính hợp lệ. Nó sẽ so sánh trạng thái trong CouchDB với những gì được ghi nhận trên blockchain. Vì không có giao dịch nào trên blockchain tương ứng với sự thay đổi của bạn, peer sẽ coi dữ liệu bạn sửa trong CouchDB là **không hợp lệ** hoặc đơn giản là nó sẽ trả về phiên bản dữ liệu cuối cùng được xác thực bởi một giao dịch hợp lệ trên blockchain.
    

Nói cách khác, bạn đã phá vỡ sự đồng bộ giữa World State và Blockchain, và Fabric luôn ưu tiên Blockchain là nguồn dữ liệu đáng tin cậy nhất.

---
### Tóm lại

1. **KHÔNG BAO GIỜ** sửa đổi dữ liệu trực tiếp trong CouchDB (hoặc LevelDB). Đây là hành động đi ngược lại nguyên tắc cốt lõi của blockchain là tính toàn vẹn và bất biến.
2. **LUÔN LUÔN** thay đổi dữ liệu bằng cách gửi một **giao dịch** thông qua việc gọi một hàm trong chaincode (ví dụ: `UpdateAsset`, `TransferAsset`).
3. Luồng giao dịch chuẩn (Client -> Endorse -> Order -> Commit) là cách **duy nhất** được hỗ trợ và đảm bảo để cập nhật World State một cách nhất quán và hợp lệ trên toàn bộ mạng lưới.

Khi bạn làm theo cách này, giao dịch cập nhật sẽ được ghi vào blockchain, và sau đó tất cả các peer sẽ cập nhật World State (CouchDB) của họ. Lúc này, hàm `ReadAsset` sẽ truy vấn CouchDB và trả về dữ liệu mới nhất một cách chính xác.

---

# Q: Logic mà Fabric kiểm tra dữ liệu được thay đổi trên world state (couchDB) không khớp với blockchain là ở đâu ? Dữ liệu blockchain (transaction log) nằm ở đâu ? Có cách nào thay đổi dữ liệu world state và transaction log mà không thông qua chaincode không ?

### 1. Logic kiểm tra dữ liệu không khớp nằm ở đâu?

Logic này không phải là một dòng code `if-else` đơn giản ở một nơi duy nhất. Nó là một phần cốt lõi trong kiến trúc của Fabric, được gọi là **Kiểm soát đồng thời đa phiên bản (Multi-Version Concurrency Control - MVCC)**.

Cơ chế này hoạt động trong suốt vòng đời của một giao dịch, đặc biệt là ở **giai đoạn xác thực và commit (Validation & Commit Phase)**.

Đây là cách nó hoạt động chi tiết:

**Bối cảnh:** Mỗi cặp key-value trong World State (CouchDB) không chỉ có giá trị, mà còn có một **phiên bản (version)** đi kèm. Phiên bản này về cơ bản là một con trỏ chỉ đến block và giao dịch đã tạo ra nó (ví dụ: `version(block:5, tx:2)`).

**Bước 1: Giai đoạn Mô phỏng & Thu thập chữ ký (Simulation & Endorsement)**

1. Ứng dụng client gửi một đề xuất giao dịch (ví dụ: gọi hàm `UpdateAsset('asset1', ...)`).
2. Đề xuất này được gửi đến các **Endorsing Peers** được chỉ định trong policy.
3. Mỗi Endorsing Peer sẽ **mô phỏng** việc thực thi chaincode.
    - Khi chaincode đọc một key (ví dụ: `GetState('asset1')`), peer sẽ ghi lại cả **giá trị và phiên bản hiện tại** của key đó vào một bộ gọi là **Read Set**.
    - Khi chaincode ghi một key (ví dụ: `PutState('asset1', ...)`), peer sẽ ghi lại **giá trị mới** vào một bộ gọi là **Write Set**.
4. Peer sẽ ký (sign) vào Read Set và Write Set này và gửi lại cho client dưới dạng một "endorsement" (chữ ký xác thực).

**Bước 2: Giai đoạn Sắp xếp (Ordering)**

1. Client thu thập đủ chữ ký, gói chúng lại thành một giao dịch hoàn chỉnh và gửi đến **Ordering Service**.
2. Ordering Service không quan tâm đến nội dung giao dịch. Nó chỉ làm một việc: sắp xếp các giao dịch từ khắp nơi trong mạng lưới theo thứ tự và đóng gói chúng vào một **khối (block)** mới.

**Bước 3: Giai đoạn Xác thực & Commit (Validation & Commit) - ĐÂY LÀ NƠI LOGIC KIỂM TRA NẰM**

1. Ordering Service gửi khối mới này đến **tất cả các peer** trong channel (bao gồm cả endorsing peer và non-endorsing peer).
2. Mỗi peer nhận được khối này sẽ thực hiện một loạt các kiểm tra cho **từng giao dịch** trong khối trước khi commit:
    - **Kiểm tra Policy:** Giao dịch có đủ chữ ký hợp lệ từ các Endorsing Peer đúng theo policy không?
    - **Kiểm tra MVCC (Quan trọng nhất):** Peer sẽ nhìn vào **Read Set** của giao dịch. Đối với mỗi key trong Read Set, nó sẽ so sánh **phiên bản được ghi trong Read Set** với **phiên bản hiện tại của key đó trong World State (CouchDB) của chính nó**.
        - **TRƯỜNG HỢP 1 (Hợp lệ):** Nếu tất cả các phiên bản đều khớp, điều này có nghĩa là không có giao dịch nào khác đã thay đổi dữ liệu này kể từ khi nó được mô phỏng. Giao dịch được coi là **hợp lệ**. Peer sẽ ghi khối vào blockchain của mình và áp dụng **Write Set** vào World State (Cập nhật CouchDB và tăng số phiên bản của key).
        - **TRƯỜDNG HỢP 2 (Không hợp lệ):** Nếu có ít nhất một phiên bản không khớp, điều này có nghĩa là một giao dịch khác đã cập nhật key này trước. Giao dịch này được coi là **không hợp lệ**. Peer sẽ đánh dấu giao dịch này là invalid trong khối, ghi khối vào blockchain (để lưu lại dấu vết), nhưng **sẽ không áp dụng Write Set vào World State**.

> **Trả lời trực tiếp câu hỏi của bạn:** Khi bạn sửa CouchDB bằng tay, bạn chỉ thay đổi giá trị chứ không cập nhật "phiên bản" một cách hợp lệ. Khi một giao dịch mới đọc key đó, nó sẽ đọc phiên bản cũ. Nhưng khi đến giai đoạn commit, peer khác (hoặc chính peer đó) đã có một phiên bản khác (do một giao dịch hợp lệ nào đó đã xảy ra). Sự không khớp này khiến giao dịch bị vô hiệu hóa. Logic này nằm ở **mỗi peer** khi nó xác thực một khối mới nhận được từ Ordering Service.

---

### 2. Dữ liệu blockchain (transaction log) nằm ở đâu?

Dữ liệu này nằm trên **hệ thống tệp (filesystem)** của mỗi peer. Nó không nằm trong CouchDB.

Đường dẫn mặc định thường là: `/var/hyperledger/production/ledgersData/chains/chains/<channel_name>/`

Bên trong thư mục này, bạn sẽ thấy:

- **Các file `blockfile_XXXXXX`:** Đây chính là các khối của blockchain. Chúng là các file nhị phân chứa các giao dịch đã được sắp xếp và ký số. Các khối này được liên kết với nhau bằng hash, tạo thành một chuỗi bất biến.
- **Thư mục `index`:** Chứa các chỉ mục (thường dùng LevelDB) để giúp peer truy vấn nhanh chóng các khối, giao dịch, hoặc các thông tin khác từ file block mà không cần phải quét toàn bộ chuỗi.

**Tóm lại:**

- **Transaction Log (Blockchain):** Lưu trên filesystem của peer, dạng file block.
- **World State (Trạng thái hiện tại):** Lưu trong một DB riêng (CouchDB hoặc LevelDB), được quản lý bởi peer.

---

### 3. Có cách nào thay đổi cả hai mà không qua chaincode không?

**Câu trả lời ngắn gọn: Về mặt lý thuyết là có thể, nhưng về mặt thực tế là cực kỳ khó, nguy hiểm, và sẽ phá vỡ hoàn toàn tính toàn vẹn và mục đích của blockchain.**

Đây là lý do tại sao:

1. **Thay đổi World State (CouchDB):** Như bạn đã thử, việc này rất dễ. Nhưng nó ngay lập tức tạo ra sự không nhất quán và sẽ bị cơ chế MVCC phát hiện và từ chối. Hệ thống tự "chữa lành" bằng cách không cho phép các thay đổi không hợp lệ này ảnh hưởng đến các giao dịch trong tương lai.
    
2. **Thay đổi Transaction Log (Blockchain):** Đây là phần gần như **bất khả thi**.
    
    - **Tính liên kết bằng Hash:** Mỗi khối trong blockchain chứa hash của khối trước đó. Nếu bạn thay đổi dù chỉ một byte trong một giao dịch ở khối số 10, hash của khối 10 sẽ thay đổi.
    - **Hiệu ứng Domino:** Vì hash của khối 10 thay đổi, nó sẽ không còn khớp với "hash của khối trước" được lưu trong khối 11. Điều này làm cho khối 11 trở nên không hợp lệ. Để sửa khối 11, bạn phải cập nhật hash và tính lại hash của khối 11. Điều này lại làm cho khối 12 không hợp lệ, và cứ thế tiếp diễn... Bạn sẽ phải tính toán lại và thay thế **tất cả các khối** từ khối bạn sửa cho đến khối mới nhất.
    - **Vấn đề Đồng thuận (Consensus):** Ngay cả khi bạn có đủ năng lực để thực hiện việc tính toán lại toàn bộ chuỗi trên **một peer**, peer đó sẽ ngay lập tức bị mạng lưới phát hiện. Khi nó giao tiếp với các peer khác, chúng sẽ thấy rằng hash của chuỗi trên peer bị sửa đổi không khớp với hash của chúng. Theo cơ chế đồng thuận, phiên bản sổ cái của peer bị sửa đổi sẽ bị từ chối.

Để một sự thay đổi như vậy thành công, bạn phải: a. Kiểm soát được **phần lớn** số peer trong mạng lưới (ví dụ: tấn công 51%). b. Thực hiện việc thay đổi và tính toán lại hash trên tất cả các peer đó **cùng một lúc**. c. Đảm bảo rằng không ai phát hiện ra.

Điều này là cực kỳ khó và đi ngược lại hoàn toàn với nguyên tắc thiết kế của blockchain.

**Kết luận:** Cách duy nhất được hỗ trợ, an toàn và đúng đắn để thay đổi dữ liệu trong Hyperledger Fabric là đi qua "cửa chính": **gửi một giao dịch hợp lệ thông qua chaincode.**

---
# Q: Dữ liệu được lưu trong blockchain (transaction_log) là dữ liệu như thế nào ? Khi chạy chaincode CreateAsset, blockchain được append vào dữ liệu sau, hãy giải thích ý nghĩa ? Trường hợp blockchain bị thay đổi bởi hacker thì chuyện gì sẽ xảy ra ?
```
kJ1:M܉ʮ?]ځQ)
             ^SK7G}4


h
î"      mychannel*@267aad89db54660c8c2bf7f7ff71efd52f5902bb5b2fcfb5fd4d472c19ed37ad:    basic

Org1MSP-----BEGIN CERTIFICATE-----
MIICKjCCAdCgAwIBAgIQIbEmGpauahgNAqiDkCYLiTAKBggqhkjOPQQDAjBzMQsw
CQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy
YW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEcMBoGA1UEAxMTY2Eu
b3JnMS5leGFtcGxlLmNvbTAeFw0yNTA3MjIwMjUwMDBaFw0zNTA3MjAwMjUwMDBa
MGwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1T
YW4gRnJhbmNpc2NvMQ8wDQYDVQQLEwZjbGllbnQxHzAdBgNVBAMMFlVzZXIxQG9y
ZzEuZXhhbXBsZS5jb20wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQglcY5IpDt
RS7j1rOCzv3VPSbVXfPXUE2MQSgOf2q9YlHthPyaBvkmdQcfNt11/QmCSlcv0mbq
Vy8FQFAIyghdo00wSzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADArBgNV
HSMEJDAigCCcfaikKQNODkFTvwyhbKjSM3AZa7sKXAK916mI1Dr11zAKBggqhkjO
PQQDAgNIADBFAiEAzTH2Uyz4FW+sr6i/4SMMhzIeeLuN9u05B28Yzvy/DXMCICjM
8FCn8OU0pExGk2nWp768YkDMt+VocOK8dB1j3ec4
-----END CERTIFICATE-----
NV}C)'W$z8m{`



Org1MSP-----BEGIN CERTIFICATE-----
MIICKjCCAdCgAwIBAgIQIbEmGpauahgNAqiDkCYLiTAKBggqhkjOPQQDAjBzMQsw
CQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy
YW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEcMBoGA1UEAxMTY2Eu
b3JnMS5leGFtcGxlLmNvbTAeFw0yNTA3MjIwMjUwMDBaFw0zNTA3MjAwMjUwMDBa
MGwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1T
YW4gRnJhbmNpc2NvMQ8wDQYDVQQLEwZjbGllbnQxHzAdBgNVBAMMFlVzZXIxQG9y
ZzEuZXhhbXBsZS5jb20wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQglcY5IpDt
RS7j1rOCzv3VPSbVXfPXUE2MQSgOf2q9YlHthPyaBvkmdQcfNt11/QmCSlcv0mbq
Vy8FQFAIyghdo00wSzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADArBgNV
HSMEJDAigCCcfaikKQNODkFTvwyhbKjSM3AZa7sKXAK916mI1Dr11zAKBggqhkjO
PQQDAgNIADBFAiEAzTH2Uyz4FW+sr6i/4SMMhzIeeLuN9u05B28Yzvy/DXMCICjM
8FCn8OU0pExGk2nWp768YkDMt+VocOK8dB1j3ec4
-----END CERTIFICATE-----
NV}C)'W$z8m{`
A
?
=basic2

CreateAsset
        id_ken_02

color_red_02
10
ken
1

 *7>2K({e,;l$
6

_lifecycle(
&
 namespaces/fields/basic/Sequency
basicp


        id_ken_02a
        id_ken_02T{"AppraisedValue":1,"Color":"color_red_02","ID":"id_ken_02","Owner":"ken","Size":10"
                                                                                                      basic1.0

Org1MSP-----BEGIN CERTIFICATE-----
MIICKDCCAc+gAwIBAgIRAKNOneoN4Uy5jjnjbPiQXZYwCgYIKoZIzj0EAwIwczEL
MAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNhbiBG
cmFuY2lzY28xGTAXBgNVBAoTEG9yZzEuZXhhbXBsZS5jb20xHDAaBgNVBAMTE2Nh
Lm9yZzEuZXhhbXBsZS5jb20wHhcNMjUwNzIyMDI1MDAwWhcNMzUwNzIwMDI1MDAw
WjBqMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMN
U2FuIEZyYW5jaXNjbzENMAsGA1UECxMEcGVlcjEfMB0GA1UEAxMWcGVlcjAub3Jn
MS5leGFtcGxlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABFlRll1YKNU5
It3qPzUEyV3fCsGNlMERdUIPrFQCxSR7lgLUVNWjmoze6Kd0bMGT8ZtcaZrg8y5k
89KZOuZ2g6KjTTBLMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMCsGA1Ud
IwQkMCKAIJx9qKQpA04OQVO/DKFsqNIzcBlruwpcAr3XqYjUOvXXMAoGCCqGSM49
BAMCA0cAMEQCIAhKVraZ2lAu7rOvtH6Lio4AE1U6fulM0hNZmD325cyJAiACMh0v
P46tTKVNs+/IFipJp7IyOmu2TQg75TqzB/zkhw==
-----END CERTIFICATE-----
F0D PHgEScE2
            .m=? }y!HdM,A*      q5LF0D 80X,rExU.i*0`A kHP)&z}U).FtI







OrdererMSP-----BEGIN CERTIFICATE-----
MIICHjCCAcSgAwIBAgIQPqEhw0SvwG5IXpO6Wr8lLzAKBggqhkjOPQQDAjBpMQsw
CQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy
YW5jaXNjbzEUMBIGA1UEChMLZXhhbXBsZS5jb20xFzAVBgNVBAMTDmNhLmV4YW1w
bGUuY29tMB4XDTI1MDcyMjAyNTAwMFoXDTM1MDcyMDAyNTAwMFowajELMAkGA1UE
BhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNhbiBGcmFuY2lz
Y28xEDAOBgNVBAsTB29yZGVyZXIxHDAaBgNVBAMTE29yZGVyZXIuZXhhbXBsZS5j
b20wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARrlLlTF/KC+dU1KE1v5UxYQ4DU
ActlvdKtw7gIZZCAhAt4NNkfkRbnxJJw8VRdEQghATP3VPdY5W8uDCZCU2kPo00w
SzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADArBgNVHSMEJDAigCALSC4x
ou/DwPSN2ItpAX8fvnEOasRBVUDG0d+85mxHADAKBggqhkjOPQQDAgNIADBFAiEA
7Dx60Gcf+RLgG0ettywviv8rV0sAL+0TnGU/Q++Jc2wCIEUk9bYyNHqKALA7QnP/
8sW2dRk5lmN0WFAgUpbIdipt
-----END CERTIFICATE-----

xE8TGq7J{
G0E!]BQKbA8L
            jwk>.b n^   k]j+=,%2x#_jUZ
"
 7+MH@f)u5w|    p

```

### 1. Dữ liệu được lưu trong Blockchain (Transaction Log) là gì?

Dữ liệu được lưu trong transaction log **không phải** là giá trị cuối cùng của asset, mà là một bản ghi chi tiết, có chữ ký số, về **toàn bộ quá trình của giao dịch** đã dẫn đến sự thay đổi đó. Nó giống như một tờ hóa đơn chi tiết có chữ ký của tất cả các bên liên quan, thay vì chỉ là số tiền cuối cùng trong tài khoản của bạn.

Một giao dịch được ghi vào blockchain thường bao gồm các thành phần chính sau:

- **Transaction Header:** Chứa thông tin metadata như:
    
    - **Channel ID:** Kênh mà giao dịch này thuộc về (`mychannel`).
    - **Transaction ID:** Một mã định danh duy nhất cho giao dịch này.
    - **Timestamp:** Thời gian giao dịch được tạo.
    - **Creator's Identity:** Ai đã khởi tạo giao dịch này? Đây chính là **chứng chỉ số (Certificate)** của người dùng hoặc ứng dụng client.
- **Transaction Payload (Nội dung):**
    
    - **Chaincode ID:** Tên của chaincode được gọi (`basic`).
    - **Proposed Operation:** Tên hàm được gọi (`CreateAsset`) và các tham số đầu vào của nó (`id_ken_02`, `color_red_02`, `10`, `ken`, `1`).
    - **Endorsements (Chữ ký xác thực):** Đây là phần quan trọng nhất. Nó chứa bằng chứng rằng các peer cần thiết đã xác thực giao dịch này. Mỗi endorsement bao gồm:
        - **Endorser's Identity:** Chứng chỉ số của peer đã xác thực (ví dụ: `peer0.org1.example.com`).
        - **Read-Write Set:**
            - **Read Set:** Danh sách các key và phiên bản của chúng mà chaincode đã đọc trong quá trình mô phỏng. (Với `CreateAsset`, Read Set có thể chỉ chứa một lần kiểm tra xem asset đã tồn tại chưa).
            - **Write Set:** Danh sách các key và giá trị mới mà chaincode đề xuất ghi vào World State. Đây chính là `T{"AppraisedValue":1,...}` mà bạn thấy.
        - **Endorser's Signature:** Chữ ký số của peer trên Read-Write Set, chứng minh rằng họ đồng ý với kết quả mô phỏng.

### 2. Giải thích dữ liệu bạn cung cấp

Hãy cùng "giải phẫu" đoạn dữ liệu bạn dán ra. Mặc dù có nhiều ký tự nhị phân khó đọc (đó là dữ liệu đã được serialize), chúng ta có thể nhận ra các phần quan trọng:

```
... (Binary Data) ...
mychannel*@... (Transaction ID) ... basic (Chaincode Name)

// --- Phần định danh người tạo giao dịch ---
Org1MSP-----BEGIN CERTIFICATE-----
...
CN=User1@org1.example.com  // <-- Đây là User1 thuộc Org1
...
-----END CERTIFICATE-----
... (Chữ ký của User1) ...

// --- Phần Payload của giao dịch ---
A
?
=basic2

CreateAsset             // <-- Tên hàm được gọi
        id_ken_02       // <-- Tham số 1
        color_red_02    // <-- Tham số 2
        10              // <-- Tham số 3
        ken             // <-- Tham số 4
        1               // <-- Tham số 5

... (Binary Data) ...

// --- Phần Write Set (kết quả của mô phỏng) ---
_lifecycle(
&
 namespaces/fields/basic/Sequency
basicp
        id_ken_02a
        id_ken_02T{"AppraisedValue":1,"Color":"color_red_02","ID":"id_ken_02","Owner":"ken","Size":10" // <-- Key và Value sẽ được ghi vào World State
                                                                                                      basic1.0

// --- Phần Endorsement từ Peer ---
Org1MSP-----BEGIN CERTIFICATE-----
...
CN=peer0.org1.example.com // <-- Đây là Peer0 thuộc Org1 đã xác thực
...
-----END CERTIFICATE-----
... (Chữ ký của Peer0 trên Read-Write Set) ...

// --- Phần thông tin từ Orderer (người tạo khối) ---
OrdererMSP-----BEGIN CERTIFICATE-----
...
CN=orderer.example.com // <-- Đây là Orderer đã đóng gói giao dịch này vào khối
...
-----END CERTIFICATE-----
... (Chữ ký của Orderer) ...
```

**Tóm lại:** Đoạn log này là một "bằng chứng không thể chối cãi" rằng: **User1** đã yêu cầu thực hiện hàm `CreateAsset` với các tham số cụ thể, **Peer0 của Org1** đã xác thực và đồng ý rằng kết quả là tạo ra một asset mới với dữ liệu JSON như trên, và cuối cùng **Orderer** đã sắp xếp và đưa giao dịch này vào một khối chính thức của `mychannel`.

### 3. Trường hợp Blockchain bị thay đổi bởi Hacker thì chuyện gì sẽ xảy ra?

Đây chính là điểm cốt lõi làm nên giá trị của công nghệ blockchain. Việc thay đổi dữ liệu này là **gần như bất khả thi** và nếu có xảy ra, nó sẽ **ngay lập tức bị phát hiện**.

Giả sử một hacker có quyền truy cập vào máy chủ của một peer và cố gắng sửa file `blockfile_XXXXXX`.

**Kịch bản 1: Hacker sửa một giao dịch trong khối số `N`**

1. **Hash của khối `N` thay đổi:** Ngay khi hacker thay đổi dù chỉ một byte trong khối `N` (ví dụ, đổi `color_red_02` thành `color_blue_02`), giá trị hash của toàn bộ khối `N` sẽ thay đổi hoàn toàn.
2. **Chuỗi bị "gãy":** Khối tiếp theo, khối `N+1`, đang lưu một trường gọi là `PreviousBlockHash` (Hash của khối trước đó). Giá trị này đang là hash _cũ_ của khối `N`. Bây giờ, hash _mới_ của khối `N` không còn khớp với `PreviousBlockHash` trong khối `N+1` nữa.
3. **Hệ thống phát hiện:** Khi peer khởi động hoặc khi có một yêu cầu truy vấn liên quan đến khối `N` hoặc `N+1`, phần mềm của Fabric sẽ tự động kiểm tra tính liên tục của chuỗi hash. Nó sẽ ngay lập tức phát hiện ra sự không khớp và báo lỗi "ledger corrupted" (sổ cái bị hỏng). Chuỗi khối trên peer này trở nên vô giá trị.

**Kịch bản 2: Peer bị tấn công giao tiếp với mạng lưới**

Giả sử hacker đủ tinh vi để sửa khối `N` và tính toán lại toàn bộ hash cho các khối `N+1`, `N+2`,... cho đến khối mới nhất trên peer đó (một việc cực kỳ tốn kém).

1. **Xung đột Đồng thuận (Consensus Conflict):** Peer bị tấn công bây giờ có một phiên bản blockchain khác với tất cả các peer còn lại trong mạng lưới.
2. **Mạng lưới từ chối:** Khi một giao dịch mới được tạo ra, các peer sẽ giao tiếp với nhau. Các peer "khỏe mạnh" khác sẽ so sánh hash của khối mới nhất của chúng với hash của peer bị tấn công. Chúng sẽ thấy hai hash này không khớp nhau.
3. **Bị cô lập:** Theo cơ chế đồng thuận, phiên bản blockchain nào được đa số các peer nắm giữ sẽ được coi là phiên bản đúng. Phiên bản trên peer của hacker sẽ bị coi là một nhánh sai (fork) và bị mạng lưới từ chối, cô lập. Peer đó không thể tham gia vào các giao dịch mới nữa.

**Kết luận:** Hacker không thể chỉ thay đổi dữ liệu. Họ phải đánh bại cả hai lớp bảo vệ: **mật mã học (cryptography)** bằng cách tính toán lại toàn bộ chuỗi hash, và **cơ chế đồng thuận (consensus)** bằng cách chiếm quyền kiểm soát phần lớn các peer trong mạng lưới cùng một lúc. Đối với một mạng lưới doanh nghiệp được cấp phép như Hyperledger Fabric, việc này là gần như bất khả thi.

---
# Q: Làm sao để biết đang có bao nhiêu peer tham gia vào quá trình đồng thuận, và làm sao để thay đổi ?
---
# Q: Luồng query giá trị một asset khi dữ liệu bị thay đổi trên world state của tất cả các peers: GetAsset --> (1) lấy dữ liệu cache từ world state --> (2) verify dữ liệu liệu cache với transaction log --> (3) verify dữ liệu sai --> (4) lấy dữ liệu từ transaction log --> (5) trả về dữ liệu đúng. Luồng này có đúng không ? Nơi thực thi luồng này là ở đâu trong source code ?

---
# Q: Cách thay đổi chính sách chứng thực (endorsement policy) 


**Nguyên tắc cốt lõi cần nắm:**

Khi bạn lặp lại cùng một vai trò (ví dụ: `"Org1MSP.peer"`) nhiều lần bên trong một toán tử `AND` hoặc `OutOf`, Hyperledger Fabric sẽ hiểu rằng bạn đang yêu cầu các chữ ký từ các peer **riêng biệt (distinct)**. Một peer không thể ký một lần để thỏa mãn nhiều yêu cầu giống hệt nhau trong cùng một chính sách.

Dựa trên nguyên tắc này, chúng ta có thể xây dựng các chính sách bạn cần.

---

### (1) Chỉ cần một chữ ký từ một peer bất kỳ trong tổ chức 1

Đây là trường hợp đơn giản nhất.

**Cú pháp:**

```
'OR("Org1MSP.peer")'
```

**Giải thích:**

- `"Org1MSP.peer"`: Đại diện cho một vai trò yêu cầu chữ ký từ một peer bất kỳ thuộc `Org1MSP`.
- `OR(...)`: Đảm bảo chỉ cần một điều kiện được thỏa mãn. Vì chỉ có một điều kiện, nên chính sách này có nghĩa là "cần một chữ ký từ một peer bất kỳ của Org1".

**Ví dụ câu lệnh deploy:**

```
./network.sh deployCC -c mychannel -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go -ccep 'OR("Org1MSP.peer")'
```

---

### (2) Cần hơn 50% chữ ký từ các peer trong tổ chức 1

Với 3 peer, "hơn 50%" có nghĩa là cần ít nhất **2** chữ ký. Chúng ta sẽ sử dụng toán tử `OutOf`.

**Cú pháp:**

```
	'OutOf(2, "Org1MSP.peer", "Org1MSP.peer", "Org1MSP.peer")'
```

**Giải thích:**

- `OutOf(2, ...)`: Yêu cầu ít nhất **2** trong các quy tắc bên trong phải được thỏa mãn.
- `"Org1MSP.peer", "Org1MSP.peer", "Org1MSP.peer"`: Chúng ta lặp lại vai trò này 3 lần để nói với Fabric rằng có 3 "suất" chữ ký có thể được cung cấp bởi các peer của Org1.
- **Kết quả:** Chính sách này yêu cầu chữ ký từ **2 peer riêng biệt** trong tổng số 3 peer của Org1. Ví dụ: (peer0 và peer1), hoặc (peer0 và peer2), hoặc (peer1 và peer2) ký thì giao dịch sẽ hợp lệ.

**Ví dụ câu lệnh deploy:**

```
./network.sh deployCC -c mychannel -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go -ccep 'OutOf(2,"Org1MSP.peer","Org1MSP.peer","Org1MSP.peer")'
```

---

### (3) Cần chữ ký từ tất cả các peer trong tổ chức 1

Với 3 peer, chúng ta cần cả 3 chữ ký. Chúng ta sẽ sử dụng toán tử `AND`.

**Cú pháp:**

```
'AND("Org1MSP.peer", "Org1MSP.peer", "Org1MSP.peer")'
```

**Giải thích:**

- `AND(...)`: Yêu cầu **tất cả** các quy tắc bên trong phải được thỏa mãn.
- `"Org1MSP.peer", "Org1MSP.peer", "Org1MSP.peer"`: Bằng cách lặp lại vai trò này 3 lần, chúng ta đang thiết lập 3 yêu cầu riêng biệt.
- **Kết quả:** Chính sách này yêu cầu chữ ký từ **3 peer riêng biệt** của Org1. Vì tổ chức chỉ có 3 peer, điều này có nghĩa là **tất cả các peer** phải ký.

**Ví dụ câu lệnh deploy:**

```
./network.sh deployCC -c mychannel -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go -ccep 'AND("Org1MSP.peer", "Org1MSP.peer", "Org1MSP.peer")'
```

### Tóm tắt

|Yêu cầu|Số chữ ký cần (trên 3 peer)|Cú pháp Endorsement Policy|
|---|---|---|
|(1) Bất kỳ 1 peer|1|`'OR("Org1MSP.peer")'`|
|(2) Hơn 50%|2|`'OutOf(2, "Org1MSP.peer", "Org1MSP.peer", "Org1MSP.peer")'`|
|(3) Tất cả các peer|3|`'AND("Org1MSP.peer", "Org1MSP.peer", "Org1MSP.peer")'`|

Bạn chỉ cần sử dụng các chuỗi chính sách này với cờ `-ccep` khi deploy hoặc nâng cấp chaincode để áp dụng cơ chế chứng thực mong muốn.


---
# Q: Tại sao khi có duy nhất một peer hoạt động, transaction không thể được tạo ?
Khi 2 trong 3 peer mất kết nối, gửi transaction bị lỗi (dùng Endorsement Policy mặc định là "MAJORITY Endorsement")
```
Error: rpc error: code = FailedPrecondition desc = no peers available to evaluate chaincode basic in channel mychannel
```. How can we config this policy ?