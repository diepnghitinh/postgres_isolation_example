CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA PUBLIC;

CREATE TABLE IF NOT EXISTS public.accounts
(
    id             UUID PRIMARY KEY NOT NULL DEFAULT PUBLIC.uuid_generate_v4(),
    owner          TEXT,
    balance        integer  DEFAULT 0,
    currency       TEXT,
    created_at     TIMESTAMP WITH TIME ZONE  DEFAULT current_timestamp
);

INSERT INTO public.accounts (owner, balance, currency) VALUES ('boss', 200, 'usd');

/* lệnh test sẽ bị dirty read */
CREATE OR REPLACE PROCEDURE dirty_read_execute_t1()
language plpgsql
as $$
declare
begin
SET TRANSACTION isolation level read uncommitted;
    select * from accounts;
end; $$


CREATE FUNCTION dirty_read_execute_t2() AS $$
BEGIN
    sum := x + y;
    prod := x * y;
END;
$$ LANGUAGE plpgsql;