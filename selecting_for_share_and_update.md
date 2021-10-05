Một câu lệnh select thông thường không cung cấp cho bạn đủ sự bảo vệ nếu bạn muốn truy vấn dữ liệu và thực hiện thay đổi trong cơ sở dữ liệu liên quan đến nó. Các giao dịch khác có thể cập nhật hoặc xóa dữ liệu bạn vừa truy vấn. PostgreSQL cung cấp thêm các câu lệnh chọn lọc để khóa khi đọc và cung cấp thêm một lớp an toàn.

## Safely Updating Data
Đôi khi, các ứng dụng đọc dữ liệu từ cơ sở dữ liệu, xử lý dữ liệu và lưu kết quả trở lại cơ sở dữ liệu. Đây là một ví dụ cổ điển trong đó select for update có thể cung cấp thêm sự an toàn.

Hãy xem xét ví dụ sau:

```
BEGIN;
SELECT * FROM purchases WHERE processed = false;
-- * application is now processing the purchases *

UPDATE purchases SET ...;
COMMIT;
```

Đoạn mã trên có thể là nạn nhân của một điều kiện chạy đua khó chịu. Vấn đề là một số phần khác của ứng dụng có thể cập nhật dữ liệu chưa được xử lý. Sau đó, các thay đổi đối với các hàng đó sẽ được ghi đè khi quá trình xử lý dữ liệu kết thúc.

Đây là một tình huống ví dụ trong đó dữ liệu gặp phải tình trạng chủng tộc xâm nhập.

```
process A: SELECT * FROM purchases WHERE processed = false;
--- process B updates the data while process A is processing it
process B: SELECT * FROM purchases;
process B: UPDATE purchases SET ...;
process A: UPDATE purchases SET ...;
```

Để giảm thiểu vấn đề này, chúng tôi có thể chọn dữ liệu để cập nhật . Đây là một ví dụ về cách chúng tôi sẽ làm điều đó:

```
BEGIN;
SELECT * FROM purchases WHERE processed = false FOR UPDATE;
-- * application is now processing the purchases *

UPDATE purchases SET ...;
COMMIT;
```

Có select ... for update ta có được một ROW SHARE LOCK trên một bảng. Khóa này xung đột với EXCLUSIVE cần thiết cho một câu lệnh update và ngăn bất kỳ thay đổi nào có thể xảy ra đồng thời.

```
process A: SELECT * FROM purchases WHERE processed = false FOR UPDATE;
process B: SELECT * FROM purchases FOR UDPATE;
--- process B blocks blocks and waits process A to finish

process A: UPDATE purchases SET ...;
process B: UPDATE purchases SET ...;
```

Tất cả các khóa sẽ được giải phóng khi giao dịch kết thúc.

## Non-blocking Select for Update Statements

Khi ứng dụng chọn một số row để cập nhật, các quy trình khác buộc phải đợi giao dịch kết thúc trước khi chúng có thể giữ khóa đó.

Nếu quá trình xử lý mất quá nhiều thời gian để hoàn thành, vì bất kỳ lý do gì, các phần khác của hệ thống có thể bị chặn. Điều này có thể không mong muốn. Chúng tôi có thể sử dụng "select ... for update nowait" câu lệnh để ngăn chặn các cuộc gọi đến cơ sở dữ liệu của chúng tôi. Truy vấn này sẽ xảy ra lỗi nếu các hàng không có sẵn để lựa chọn.

```
process A: SELECT * FROM purchases WHERE processed = false;
--- process B tries to select the data, but fails
process B: SELECT * FROM purchases FOR UPDATE NOWAIT;
process B: ERROR could not obtain lock on row in relation "purchases"
process A: UPDATE purchases SET ...;
```

## Processing Non-Locked Database Rows

Lựa chọn để cập nhật có thể là một khóa cứng trên bảng của bạn. Các quy trình đồng thời có thể bị chặn và bị chết. Chờ đợi là hình thức xử lý đồng thời chậm nhất. Nếu chỉ có một CPU có thể hoạt động tại một thời điểm, thì việc mở rộng máy chủ của bạn là vô nghĩa. Với mục đích này, trong PostgreSQL có một cơ chế chỉ chọn các hàng không bị khóa.

Câu lệnh "select ... for update skip locked" cho phép bạn truy vấn các hàng không có khóa. Hãy quan sát tình huống sau để nắm được trường hợp sử dụng của nó:

```
process A: SELECT * FROM purchases
process A:   WHERE processed = false FOR UPDATE SKIP LOCKED;
process B: SELECT * FROM purchases
process B:   WHERE created_at < now()::date - interval '1w';
process B:   FOR UPDATE SKIP LOCKED;
-- process A selects and locks all unprocess rows
-- process B selects all non locked purchases older than a week

process A: UPDATE purchases SET ...;
process B: UPDATE purchases SET ...;
```

Cả Quy trình A và Quy trình B có thể xử lý dữ liệu đồng thời.

## The Effect of Select For Update on Foreign Keys

Một điều mà chúng ta cần lưu ý khi làm việc với câu lệnh "select for update" là ảnh hưởng của nó đối với các khóa ngoại. Đặc biệt hơn, chúng ta không thể quên rằng các hàng được tham chiếu từ các bảng khác cũng bị khóa.

Hãy xem một ví dụ với hai bảng - người dùng và lượt mua hàng - với khái niệm rằng người dùng có nhiều lượt mua hàng.

```
\d purchases
              Table "public.purchases"
 Column  |  Type   | Collation | Nullable | Default
---------+---------+-----------+----------+---------
 id      | integer |           |          |
 payload | jsonb   |           |          |
 user_id | integer |           |          |
Foreign-key constraints:
    "purchases_user_id_fkey" FOREIGN KEY (user_id) REFERENCES
    users(id) ON UPDATE CASCADE ON DELETE CASCADE
```

Khi chọn dữ liệu từ bảng purchases "select for update", người dùng cũng sẽ bị khóa. Điều này là cần thiết vì nếu không sẽ có cơ hội phá vỡ ràng buộc khóa ngoại.

```
process A: SELECT * FROM purchases FOR UPDATE;
process B: UPDATE users SET id = 3 WHERE id = 1;
-- process B is blocked and is waiting for process A to finish
-- its transaction
```

Trong các hệ thống lớn hơn, "select for share" có thể gây ra hậu quả tiêu cực lớn nếu nó khóa một bảng được sử dụng rộng rãi. Hãy nhớ rằng các quy trình khác sẽ chỉ cần đợi nếu chúng muốn cập nhật trường được tham chiếu. Nếu quá trình khác muốn cập nhật một số dữ liệu không liên quan, sẽ không có quá trình chặn nào xảy ra.

```
process A: SELECT * FROM purchases FOR UPDATE;
process B: UPDATE users SET name = 'Peter' WHERE id = 1;
-- process B is completed without blocking because it does not change
-- the id field
```

## Safely Creating Related Records With Select for Share
Một dạng yếu hơn "select for update" là "select for share". Nó là một lý tưởng để đảm bảo tính toàn vẹn của tham chiếu khi tạo các bản ghi con cho cha mẹ.

Hãy sử dụng bảng users và purchases để chứng minh một trường hợp sử dụng cho truy vấn chọn để chia sẻ. Giả sử rằng chúng tôi muốn tạo một giao dịch mua mới cho một người dùng. Đầu tiên, chúng tôi sẽ chọn người dùng từ cơ sở dữ liệu và sau đó chèn một bản ghi mới vào cơ sở dữ liệu mua hàng. Chúng ta có thể chèn một giao dịch mua mới vào cơ sở dữ liệu một cách an toàn không? Với một câu lệnh chọn thông thường, chúng tôi không thể. Các quy trình khác có thể xóa người dùng trong những khoảnh khắc giữa việc chọn người dùng và chèn giao dịch mua.

```
process A: BEGIN;
process A: SELECT * FROM users WHERE id = 1 FOR SHARE;
process B: DELETE FROM users WHERE id = 1;
-- process B blocks and must wait for process A to finish

process A: INSERT INTO purchases (id, user_id) VALUES (1, 1);
process A: COMMIT;
-- process B now unblocks and deletes the user
```

Chọn để chia sẻ đã ngăn các quy trình khác xóa người dùng, nhưng không ngăn các quy trình đồng thời chọn người dùng. Đây là sự khác biệt chính giữa "select for share" và "select for update".

Các "select for share" ngăn chặn bản cập nhật và xóa các hàng, nhưng không ngăn cản quá trình khác từ việc mua một select for share. Mặt khác, "select for update" cũng chặn cập nhật và xóa, nhưng nó cũng ngăn các quy trình khác có được "select for update" khóa.

## The Select For No Key Updates and Select For Key Share

Có thêm hai mệnh đề khóa trong PostgreSQL được giới thiệu từ phiên bản 9.3. Là "select for no key updates" và "select for key share".

Hành vi "select for no key updates" tương tự như "select for update" nhưng nó không chặn "select for share". Lý tưởng nếu bạn đang thực hiện xử lý trên các row nhưng không muốn chặn việc tạo các bản ghi con.

Là "select key share" dạng yếu nhất của mệnh đề có khóa, và hoạt động tương tự như "select for share" mệnh đề khóa. Nó ngăn chặn việc xóa các row, nhưng không giống như "select for share" nó không ngăn cập nhật các hàng không sửa đổi các giá trị chính.


http://shiroyasha.io/selecting-for-share-and-update-in-postgresql.html