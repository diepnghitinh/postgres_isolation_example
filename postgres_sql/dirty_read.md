Postgres mặc định mức cô lập là read committed. Xem lại chapter 1. Vì vậy ở Postgres Dirty read gần như không xảy ra trừ khi ta cố tình set Isolation về Read uncommitted

Cách kiểm tra.
```
simple_bank> show transaction isolation level;
 transaction_isolation
-----------------------
 read committed
(1 row)
```

