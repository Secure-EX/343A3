SET SEARCH_PATH TO carschema;
DROP TABLE IF EXISTS q4 CASCADE;

/*
Find the list of all customers younger than 30 years old who changed at least 2 reservations in the past 18 months.
Note: You’re required to return a list of customer IDs

- Customers ID in this case is customer e-mail.
- Since we don't have a timestamp indicating when the reservation was made in this schema, you may use FromDate for this query.
- Please note that it's in the past 18 month with reference to the time of query execution (i.e. server time).
- You may find some of the Date/Time functions and operators in this PostgreSQL documentation page helpful.

- You should not hard code specific dates in the query! In other words, your query should NOT say that FromDate > '2016-09-10' or any other specific date in there.
- You can assume that we meant 30 day months (i.e. 30 * 18 = 540 days).
- A reservation "change" refers to cases where the old reservation is cancelled AND replaced with a new reservation.
  In other words, we're concerned with reservations where OLD_RESERVATION_ID is not null.
  Simply canceling a reservation doesn't count in this case. (See discussion in @871).
*/

CREATE TABLE q4(
    CUSTOMER_EMAIL TEXT
);

DROP VIEW IF EXISTS res_info_with_right_age CASCADE;
DROP VIEW IF EXISTS have_changed CASCADE;
DROP VIEW IF EXISTS have_changed_with_diff CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- Get the resveration info of people who is yonger than 30
create view res_info_with_right_age as
    select customer.email as email, reservation.id as res_id, reservation.from_date as start_date, reservation.old_reservation_id as old_id
    from customer join customer_reservation on customer_reservation.customer_email = customer.email
    join reservation on customer_reservation.reservation_id = reservation.id
    where customer.age < 30;

-- Find all the people who have changed resveration
create view have_changed as
    select r1.*
    from res_info_with_right_age r1, res_info_with_right_age r2
    where r1.email = r2.email and r1.old_id = r2.res_id;

-- Get all the difference dates with target people
create view have_changed_with_diff as
    select have_changed.*, cast(extract(day from(age(start_date))) as int) as diff
    from have_changed;

-- Get the people who have changed at least two times in past 18 months
create view answer as
    select email as CUSTOMER_EMAIL
    from
    (select email, count(*) as changes
    from have_changed_with_diff
    where diff < 18
    group by email) sub
    where changes >= 2;
;

INSERT INTO q4 SELECT * FROM answer;
SELECT * FROM q4;
