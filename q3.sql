SET SEARCH_PATH TO carschema;
DROP TABLE IF EXISTS q3 CASCADE;

/*
Find the most frequently rented car model in Toronto, where the reservation started and was fully completed in the year 2017.

In this case, you're asked to return the model name (e.g. BMW X5, Chevrolet Spark, etc.).
You should order by the total number of times the car model was rented (descending) and model name (ascending).

- As the question says, you should only consider completed reservations for this query. Cancelled, ongoing or confirmed don't count.

*/

CREATE TABLE q3(
    MODEL_NAME TEXT
);

DROP VIEW IF EXISTS all_fit_cars_with_frequency CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

CREATE VIEW all_fit_cars_with_frequency AS
    SELECT model.name AS name, count(car.model_id) as frequency
    FROM reservation
    JOIN car ON reservation.car_id = car.id
    JOIN rentalstation ON rentalstation.station_code = car.station_code
    JOIN model ON car.model_id = model.id
    WHERE '2017-01-01 00:00:00' <= reservation.from_date and reservation.to_date < '2018-01-01 00:00:00' and rentalstation.city = 'Toronto' and reservation.status = 'Completed'
    GROUP BY model.name
    ORDER BY frequency DESC, model.name
;

--SELECT * FROM all_fit_cars_with_frequency;
INSERT INTO q3 SELECT name FROM all_fit_cars_with_frequency LIMIT 1;
SELECT * FROM q3;