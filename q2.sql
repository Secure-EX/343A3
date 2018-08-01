SET SEARCH_PATH TO carschema;
DROP TABLE IF EXISTS q2 CASCADE;

/*
Find the top 2 customers who rent cars with driver(s) most frequently.
What's meant by "driver(s)" here is other customers.
To phrase it a bit more clearly, the question is asking you to return the top 2 customers who share reservations with other customers most frequently.
And again, for cases where customers can have the same value, you may order by customer e-mail (ascending).

Update 1 (March 21st): We apologize for the confusion, but we're asking you for the following:

- You should exclude cancelled reservations from this calculation. Reservation status can be Completed, Ongoing, or Confirmed.
- By "most frequently", we mean in terms of the absolute number of reservations, not ratios.
- So, if customer A rented a car on their own 4 times and with other customers 6 times, we're asking you to return 6 and not 6 / 10 = 0.6.
*/

CREATE TABLE q2(
    email TEXT,
    num_shared_reservations INT
);

DROP VIEW IF EXISTS absolutely_reservations CASCADE;
DROP VIEW IF EXISTS book_only_once CASCADE;
DROP VIEW IF EXISTS count_book_only_once_cus CASCADE;
DROP VIEW IF EXISTS all_reservation_time_per_cus CASCADE;
DROP VIEW IF EXISTS full_count_only_once_table CASCADE;
DROP VIEW IF EXISTS partial_full_table CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- the customers that absolutely booking the reservation <-
CREATE VIEW absolutely_reservations AS
    SELECT customer_reservation.customer_email AS email, reservation.id AS res_id
    FROM customer_reservation, reservation
    WHERE status != 'Cancelled' AND customer_reservation.reservation_id = reservation.id
;

-- the reservation id that only appear once, which means that customer only book cars by themseleves
CREATE VIEW book_only_once AS
    SELECT customer_email AS email, res_id_book_only_once.res_id AS only_once
    FROM customer_reservation, 
    (SELECT res_id
     FROM absolutely_reservations
     GROUP BY res_id
     HAVING COUNT(res_id) = 1) res_id_book_only_once
    WHERE res_id_book_only_once.res_id = customer_reservation.reservation_id
;

-- count the time that a customer only book a reservation once
CREATE VIEW count_book_only_once_cus AS 
    SELECT email, COUNT(only_once) AS only_once
    FROM book_only_once
    GROUP BY email
;

-- all reservation time per customer
CREATE VIEW all_reservation_time_per_cus AS 
    SELECT email, COUNT(res_id) AS total_time
    FROM absolutely_reservations
    GROUP BY email
;
/*
       email        | total_time 
--------------------+------------
 a.n@mail.com       |          1
 cyngu@mail.com     |          3
 dchen@mail.com     |          3
 j.s@mail.com       |          2
 jj.swtz@mail.com   |          1
 jparki@mail.com    |          2
 ma.smith@mail.com  |          1
 malik_aa@mail.com  |          2
 orlows@mail.com    |          2
 r.k@mail.com       |          1
 s.hilbert@mail.com |          4
 shenian@mail.com   |          4
 t.g@gmail.com      |          3
 terry.su@mail.com  |          2
 y.c@mail.com       |          3
(15 rows)

*/

-- cast those who does not book a reservation anytime to 0 and union the previous with the view count_book_only_once_cus
CREATE VIEW full_count_only_once_table AS
    (SELECT sub.email AS email, CAST(0 AS INT) AS only_once
     FROM ((SELECT email FROM all_reservation_time_per_cus) EXCEPT (SELECT email FROM count_book_only_once_cus)) sub)
    UNION
    (SELECT * FROM count_book_only_once_cus)
;
/*
       email        | only_once_time 
--------------------+----------------
 a.n@mail.com       |              0
 cyngu@mail.com     |              2
 dchen@mail.com     |              2
 j.s@mail.com       |              1
 jj.swtz@mail.com   |              1
 jparki@mail.com    |              1
 ma.smith@mail.com  |              0
 malik_aa@mail.com  |              1
 orlows@mail.com    |              2
 r.k@mail.com       |              0
 s.hilbert@mail.com |              4
 shenian@mail.com   |              3
 t.g@gmail.com      |              3
 terry.su@mail.com  |              1
 y.c@mail.com       |              2
(15 rows)
*/

-- join all_reservation_time_per_cus and full_count_only_once_table together
CREATE VIEW partial_full_table AS
    SELECT all_reservation_time_per_cus.email, total_time, only_once, total_time - only_once AS num_shared_reservations
    FROM all_reservation_time_per_cus, full_count_only_once_table
    WHERE all_reservation_time_per_cus.email = full_count_only_once_table.email
;
/*
       email        | total_time | only_once_time | num_shared_reservations 
--------------------+------------+----------------+-------------------------
 a.n@mail.com       |          1 |              0 |                       1
 cyngu@mail.com     |          3 |              2 |                       1
 dchen@mail.com     |          3 |              2 |                       1
 j.s@mail.com       |          2 |              1 |                       1
 jj.swtz@mail.com   |          1 |              1 |                       0
 jparki@mail.com    |          2 |              1 |                       1
 ma.smith@mail.com  |          1 |              0 |                       1
 malik_aa@mail.com  |          2 |              1 |                       1
 orlows@mail.com    |          2 |              2 |                       0
 r.k@mail.com       |          1 |              0 |                       1
 s.hilbert@mail.com |          4 |              4 |                       0
 shenian@mail.com   |          4 |              3 |                       1
 t.g@gmail.com      |          3 |              3 |                       0
 terry.su@mail.com  |          2 |              1 |                       1
 y.c@mail.com       |          3 |              2 |                       1
(15 rows)
*/

-- final answer
CREATE VIEW answer AS
    SELECT email, num_shared_reservations
    FROM partial_full_table
    ORDER BY num_shared_reservations DESC, email
;

/*
INSERT INTO abs_res SELECT * FROM absolutely_reservations ORDER BY res_id;
INSERT INTO res_time SELECT * FROM all_reservation_time_per_cus ORDER BY email;
INSERT INTO only_once_info SELECT * FROM book_only_once ORDER BY email;
INSERT INTO count_only_once SELECT * FROM count_book_only_once_cus ORDER BY email;
INSERT INTO full_once SELECT * FROM full_count_only_once_table ORDER BY email;
INSERT INTO partial_full SELECT * FROM partial_full_table ORDER BY email;
*/

INSERT INTO q2 SELECT * FROM answer LIMIT 2;
SELECT * FROM q2;
