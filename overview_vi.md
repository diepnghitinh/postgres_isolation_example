# Isolation Levels / Mức độ độc lập
+ Isolation levels là các mức cô lập dữ liệu. Mỗi transaction được chỉ định 1 isolation level để chỉ định mức độ mà nó phải được cách ly khỏi các sự sửa đổi dữ liệu được thực hiện bởi các transaction khác.
+ Các Isolation levels kiểm soát :
  + Lock có được sử dụng khi dữ liệu được đọc hay không và loại Lock được sử dụng.
  + Read lock tồn tại bao lâu?
  + Liệu 1 thao tác đọc tham chiếu đến các hàng có thể được sửa bởi 1 transaction khác hay không?
+ Mức độ cô lập dữ liệu thấp giúp tăng khả năng xử lý đồng thời từ đó hiệu suất cũng tăng theo nhưng nó sẽ làm tăng nguy cơ xảy ra các tác động xấu đã nêu ở phần trước.
+ Tùy từng hoàn cảnh, môi trường và yêu cầu của ứng dụng, ta chọn lựa các mức cô lập dữ liệu phù hợp nhất.
+ SQL cung cấp các mức isolation levels sau xếp theo thứ tự tăng dần của mức độ cô lập của dữ liệu: Read Uncommitted, Read Commited, Repeatable Read, Serializable, Snapshot

## Read uncommitted

Đây là mức cô lập thấp nhất. Khi transaction thực hiện ở mức này, các truy vấn vẫn có thể truy nhập vào các bản ghi đang được cập nhật bởi một transaction khác và nhận được dữ liệu tại thời điểm đó mặc dù dữ liệu đó chưa được commit (uncommited data). Điều này sẽ dẫn đến có thể xảy ra Dirty read

## Read commited

Đây là mức isolation mặc định, nếu bạn không đặt gì cả thì transaction sẽ hoạt động ở mức này. Transaction sẽ không đọc được dữ liệu đang được cập nhật mà phải đợi đến khi việc cập nhật thực hiện xong. Vì thế nó tránh được dirty read như ở mức trên nhưng có thể xảy ra phantom read

## Repeatable read

Mức isolation này hoạt động như mức read commited nhưng nâng thêm một nấc nữa bằng cách ngăn không cho transaction ghi vào dữ liệu đang được đọc bởi một transaction khác cho đến khi transaction khác đó hoàn tất
Mức isolation này đảm bảo các lệnh đọc trong cùng một transaction cho cùng kết quả, nói cách khác dữ liệu đang được đọc sẽ được bảo vệ khỏi cập nhật bởi các transaction khác. Tuy nhiên nó không bảo vệ được dữ liệu khỏi insert hoặc delete: nếu bạn thay lệnh update ở cửa sổ thứ hai bằng lệnh insert, hai lệnh select ở cửa sổ đầu sẽ cho kết quả khác nhau. Vì thế nó vẫn không tránh được hiện tượng phantom read

## Serializable

Đây là mức cô lập cao nhất, các transactions hoàn toàn tách biệt với nhau, SQL đặt read + write lock trên dữ liệu cho tới khi transaction kết thúc. Vì thế hiện tượng phantom read sẽ không còn ở mức này.
