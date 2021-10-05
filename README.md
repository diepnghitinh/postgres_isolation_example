# postgres_isolation_example

* Transaction isolation and read phenomena
  * [ACID property & 4 isolation levels](acid_isolation_levels.md)
  * [4 read phenomena](4_read_phenomena.md)
  * [Relationship between isolation levels and read phenomena](isolation_phenomena.md)
* Others
  * [Selecting for Share and Update](selecting_for_share_and_update.md)

4 read phenomena ( 4 hiện tượng đọc )

## Dirty read

Một transaction đọc dữ liệu được ghi bởi một transaction khác chưa được commit.


## Nonrepeatable read

Trường hợp này xảy ra khi 1 transaction A đọc 1 đơn vị dữ liệu nhiều lần và kết quả khác nhau giữa các lần do giữa thời gian đọc của các lần đó, dữ liệu bị 1 transaction khác commit thay đổi.


## Phantom read

Xảy ra khi 2 queries giống nhau được thực hiện nhưng list rows kết quả trả về lại khác nhau. Ví dụ, có 2 transaction được thực thi cùng lúc. Hai câu lệnh SELECT trong transaction đầu tiên có thể trả về các kết quả khác nhau vì câu lệnh INSERT trong transaction thứ hai thay đổi dữ liệu được sử dụng bởi cả hai.

````
--Transaction 1  
BEGIN TRAN;  
SELECT ID FROM dbo.employee  
WHERE ID > 5 and ID < 10;  
--The INSERT statement from the second transaction occurs here.  
SELECT ID FROM dbo.employee  
WHERE ID > 5 and ID < 10;  
COMMIT;
````

````
--Transaction 2  
BEGIN TRAN;  
INSERT INTO dbo.employee  
 (Id, Name) VALUES(6 ,'New');  
COMMIT;
````

## Serialization anomaly

Xảy ra khi 2 transaction (có cùng code) cùng chạy 1 lúc, và kết quả đưa vào csdl một record trùng lặp không như mong muốn.

Để chặn serializable anomaly. Ta dùng:

```
set transaction isolation level serializable;
```

Sau đó 2 giao dịch đồng thời sau khi commit không còn tạo ra các bản ghi trùng lặp như trước đây nữa.

https://www.postgresql.org/docs/current/transaction-iso.html

https://www.postgresql.org/docs/9.1/explicit-locking.html

https://en.wikipedia.org/wiki/Isolation_%28database_systems%29

https://dev.to/techschoolguru/understand-isolation-levels-read-phenomena-in-mysql-postgres-c2e#serialization-anomaly-in-postgres
