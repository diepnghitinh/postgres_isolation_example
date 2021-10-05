## Basic structure of a PL/pgSQL function

```
CREATE FUNCTION function_name(argument1 type,argument2 type)
 RETURNS type AS
BEGIN
  staments;
END;
LANGUAGE 'language_name';
```

Example:
```
CREATE FUNCTION sum_n_product(IN x int,IN y int, OUT sum int, OUT prod int) AS $$
BEGIN
    sum := x + y;
    prod := x * y;
END;
$$ LANGUAGE plpgsql;
```

* We specify the name of function followed by the CREATE FUNCTIONclause.
* Provide a list of parameters inside the paretheses, also specifying each data type (integer, boolean, geometry, etc..)
* RETURNS specifies the return type of the function.
* Place the block of code inside inside the BEGIN and END;.
* Indicate the procedural language of the function. For PostgreSQL is usually plpgsql.
* The conditions can be STRICT, IMMUTABLE or VOLATILE.
    * STRICT: write STRICT when the input arguments have NULL values. The function is not evaluated and returns a NULL value.
    * IMMUTABLE: The function ensures the same result (it caches it) if the same value is put as an input arguments. This function can’t change the database.
    * VOLATILE: opposite of IMMUTABLE. The function has a result that changes the result even when you write the same input values.