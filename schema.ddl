-- 1. What constraints from the domain could not be enforced?
-- A: We could not implement a check constrain to check if the emial that the customer input is a valid email,
--    not only a correct format but also if the email is exist (really belongs to that guy) or not.

-- 2. What constraints that could have been enforced were not enforced? Why not?
-- A: The date of reservation could have been enforced but were not enforced. This means that if a customer rent a
--    car in a specific time range, another customer cannot reserve same car at the same time since the car has already
--    rent to previous customer. Also we cannot check same person can not reserve more than one car at the same time
--    since it requires a subquery check constrain.

DROP SCHEMA IF EXISTS carschema CASCADE;
CREATE SCHEMA carschema;

SET SEARCH_PATH TO carschema;

-- Customers provide their name, age and email to register into the system.
CREATE TABLE customer(
  -- The full name of a customer
  name VARCHAR(50) NOT NULL,
  -- The age of a customer
  age INT NOT NULL,
  CHECK (age >= 21),
  -- The email of the customer
  email TEXT UNIQUE NOT NULL,
  PRIMARY KEY (name, email)
);

-- The information of the car model.
CREATE TABLE model(
  -- id of the car model
  id INT PRIMARY KEY,
  -- name of the car
  name VARCHAR(50) UNIQUE NOT NULL,
  -- type of the car
  vehicle_type VARCHAR(50) NOT NULL,
  -- model number of the car
  model_number INT NOT NULL,
  -- how many people can that car have
  capacity INT NOT NULL
);

-- The information of the rental station.
CREATE TABLE rentalstation(
  -- station code of a car rental station
  station_code INT PRIMARY KEY,
  -- name of the station
  name VARCHAR(50) NOT NULL,
  -- address of the station
  address TEXT NOT NULL,
  -- general Canada zip code for the station
  area_code VARCHAR(6) NOT NULL,
  -- city name
  city VARCHAR(20) NOT NULL,
  UNIQUE(name, address, area_code, city)
);

-- The information of the customer's car
CREATE TABLE car(
  -- car id
  id INT PRIMARY KEY,
  -- license plate number of the car
  license_plate_number VARCHAR(20) NOT NULL UNIQUE,
  -- station that the car is from
  station_code INT REFERENCES rentalstation(station_code) NOT NULL,
  -- model id of the car
  model_id INT REFERENCES model(id) NOT NULL
);

CREATE TYPE status_type AS ENUM(
  'Confirmed', 'Ongoing', 'Completed', 'Cancelled'
);

-- A reservation status can be confirmed (before journey),
-- ongoing (during journey), completed (after journey completion)
-- or cancelled.
CREATE TABLE reservation(
  -- customer's reservation id
  id INT PRIMARY KEY,
  -- start date of the service
  from_date TIMESTAMP NOT NULL,
  -- expected end date of the service
  to_date TIMESTAMP NOT NULL,
  -- id of the car
  car_id INT REFERENCES car(id) NOT NULL,
  -- previous reservation id if exist otherwise NULL
  old_reservation_id INT REFERENCES reservation(id),
  -- the type of status this was
  status status_type NOT NULL
);

--
CREATE TABLE customer_reservation(
  -- customer's email
  customer_email TEXT REFERENCES customer(email) NOT NULL,
  -- reservation id of the customer
  reservation_id INT REFERENCES reservation(id) NOT NULL,
  PRIMARY KEY (customer_email, reservation_id)
);
