# postgres_isolation_example

## Dirty read
```
A transaction reads data written by a concurrent uncommitted transaction.
```

## Nonrepeatable read
```
A transaction re-reads data it has previously read and finds that data has been modified by another transaction (that committed since the initial read).
```

```
Trường hợp này xảy ra khi 1 transaction A đọc 1 đơn vị dữ liệu nhiều lần và kết quả khác nhau giữa các lần do giữa thời gian đọc của các lân đó, dữ liệu bị 1 transaction khác commit thay đổi.
```

## Phantom read
```
A transaction re-executes a query returning a set of rows that satisfy a search condition and finds that the set of rows satisfying the condition has changed due to another recently committed transaction.
```

## Serialization anomaly

```
The result of successfully committing a group of transactions is inconsistent with all possible orderings of running those transactions one at a time.
```

https://www.postgresql.org/docs/current/transaction-iso.html

https://www.postgresql.org/docs/9.1/explicit-locking.html
