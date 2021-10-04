# postgres_isolation_example

## Dirty read
	A transaction reads data written by a concurrent uncommitted transaction.
## Nonrepeatable read
	A transaction re-reads data it has previously read and finds that data has been modified by another transaction (that committed since the initial read).
## Phantom read
	A transaction re-executes a query returning a set of rows that satisfy a search condition and finds that the set of rows satisfying the condition has changed due to another recently committed transaction.
## Serialization anomaly
	The result of successfully committing a group of transactions is inconsistent with all possible orderings of running those transactions one at a time.

https://www.postgresql.org/docs/current/transaction-iso.html
https://www.postgresql.org/docs/9.1/explicit-locking.html
