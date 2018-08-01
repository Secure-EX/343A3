SET SEARCH_PATH TO carschema;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    name VARCHAR(50),
    email TEXT,
    ratio REAL
);

-- A (numerator): is the total number of cancelled reservations. This number doesn't include changed reservations.
-- Remember that when a customer changes a reservation, the old one is cancelled and a new one is created.
-- The old ones in this case shouldn't be counted when calculating A and you have to account for that.
-- B (denominator): is the total number of reservations that weren't cancelled (this includes completed, ongoing, and confirmed reservations).
-- ratio = A/B, ratio can be greater than 1

DROP VIEW IF EXISTS all_cancelled CASCADE;
DROP VIEW IF EXISTS rescheduled CASCADE;
DROP VIEW IF EXISTS absolutely_cancelled CASCADE;
DROP VIEW IF EXISTS absolutely_reservations CASCADE;
DROP VIEW IF EXISTS count_cancel CASCADE;
DROP VIEW IF EXISTS count_reservation CASCADE;
DROP VIEW IF EXISTS cancel_res_cast_zero CASCADE;
DROP VIEW IF EXISTS res_cast_zero CASCADE;
DROP VIEW IF EXISTS union_cancel CASCADE;
DROP VIEW IF EXISTS union_reservation CASCADE;
DROP VIEW IF EXISTS final_table CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- all cancelled reservation 10 row
CREATE VIEW all_cancelled AS
    SELECT reservation.id AS res_id, reservation.car_id AS car_id
    FROM reservation
    WHERE status = 'Cancelled'
;

-- the customer actually 'rescheduled' rather than cancel the reservation 6 row
CREATE VIEW rescheduled AS
    SELECT r2.old_reservation_id AS res_id, r1.car_id AS car_id
    FROM reservation r1, reservation r2
    WHERE r2.old_reservation_id IS NOT NULL AND r1.id = r2.old_reservation_id AND r1.status = 'Cancelled'
;

-- the customers that absolutely cancelled the reservation 4 row <-
CREATE VIEW absolutely_cancelled AS
    SELECT customer_reservation.customer_email AS email, customer_reservation.reservation_id AS res_id 
    FROM customer_reservation JOIN
    ((SELECT * FROM all_cancelled)
     EXCEPT
    (SELECT * FROM rescheduled)) sub ON customer_reservation.reservation_id = sub.res_id
;

-- the customers that absolutely booking the reservation, including the reschedule people <-
CREATE VIEW absolutely_reservations AS
    SELECT customer_reservation.customer_email AS email, reservation.id AS res_id
    FROM customer_reservation, reservation
    WHERE status != 'Cancelled' AND customer_reservation.reservation_id = reservation.id
;

-- count the cancel reservation per person
CREATE VIEW count_cancel AS
    SELECT email, COUNT(res_id) AS cancel_time
    FROM absolutely_cancelled
    GROUP BY email
;

-- count the reservation per person
CREATE VIEW count_reservation AS
    SELECT email, COUNT(res_id) AS reservation_time
    FROM absolutely_reservations
    GROUP BY email
;

-- total minus cancel reservation per person and cast to 0
CREATE VIEW cancel_res_cast_zero AS
    SELECT sub.email AS email, CAST(0 AS INT) AS cancel_time
    FROM ((SELECT customer_email AS email FROM customer_reservation) EXCEPT (SELECT email FROM count_cancel)) sub
;

-- total minus reservation per person and cast to 0
CREATE VIEW res_cast_zero AS
    SELECT sub.email AS email, CAST(0 AS INT) AS reservation_time
    FROM ((SELECT customer_email AS email FROM customer_reservation) EXCEPT (SELECT email FROM count_reservation)) sub
;

-- union count_cancel and cancel_res_cast_zero to get a partial full table
CREATE VIEW union_cancel AS
    (SELECT * FROM count_cancel)
    UNION
    (SELECT * FROM cancel_res_cast_zero)
;

-- union count_reservation and res_cast_zero to get a partial full table
CREATE VIEW union_reservation AS
    (SELECT * FROM count_reservation)
    UNION
    (SELECT * FROM res_cast_zero)
;

-- join together and then join customer to get the name of the customer
CREATE VIEW final_table AS
    SELECT customer.name AS name, customer.email AS email, sub.cancel_time AS cancel_time, sub.reservation_time AS reservation_time
    FROM customer JOIN 
    (SELECT union_cancel.email AS email, union_cancel.cancel_time AS cancel_time, union_reservation.reservation_time AS reservation_time
    FROM union_cancel, union_reservation
    WHERE union_cancel.email = union_reservation.email) sub ON customer.email = sub.email
;

-- If a certain customer has only cancelled reservations in the system (i.e. the denominator B = 0), then you should return the number of cancelled reservations (A) as the ratio in this case.
-- If a certain customer has no cancelled reservations (A = 0) or no reservations at all (A + B = 0), then you should return 0.0 as the ratio.
-- You don't have to worry about the case where the reservation table is empty (i.e. no customer has made any reservations). Your query doesn't need to handle that case (though you're welcome to if you like)


CREATE VIEW answer AS
    -- SELECT name, email, COALESCE(cancel_time::FLOAT, cancel_time::FLOAT / NULLIF(reservation_time, 0)) AS ratio
    SELECT name, email, CASE reservation_time WHEN 0 THEN cancel_time::FLOAT
                                              ELSE cancel_time::FLOAT / reservation_time END
                                              AS ratio
    FROM final_table
;

INSERT INTO q1 SELECT * FROM answer ORDER BY ratio DESC, email LIMIT 2;
-- order by the cancellation ratio (descending) and customer e-mail (ascending)

/*
      name      |       email        | cancel_time | reservation_time 
----------------+--------------------+-------------+------------------
 Atena Najm     | a.n@mail.com       |           0 |                1
 Cynthia Nguyen | cyngu@mail.com     |           0 |                3
 David Chen     | dchen@mail.com     |           0 |                3
 Sofia Jan      | j.s@mail.com       |           0 |                2
 Jonah Swartz   | jj.swtz@mail.com   |           1 |                1
 John Parkinson | jparki@mail.com    |           0 |                2
 Marie Smith    | ma.smith@mail.com  |           0 |                1
 Malik Abdullah | malik_aa@mail.com  |           1 |                2
 Stan Orlowski  | orlows@mail.com    |           1 |                2
 Ryan King      | r.k@mail.com       |           0 |                1
 Sanja Hilbert  | s.hilbert@mail.com |           0 |                4
 Ian Hsu        | shenian@mail.com   |           0 |                4
 Thomas George  | t.g@gmail.com      |           0 |                3
 Terry Su       | terry.su@mail.com  |           0 |                2
 Yu Chang       | y.c@mail.com       |           1 |                3
(15 rows)
 *special row handle
 NIBABA         | bla.@mail.com      |           3 |                0
*/
SELECT * FROM q1;
