---------------------------------------------------------------------------
-- DROP INDEXES and sequences FOR FLIGHT RESERVATION MODEL --  
---------------------------------------------------------------------------
DROP INDEX employee_last_name_ix;
DROP INDEX flight_flight_num_ix;

DROP SEQUENCE flight_id_seq;
DROP SEQUENCE passenger_id_seq;
DROP SEQUENCE reservation_id_seq;
DROP SEQUENCE payment_id_seq;
DROP SEQUENCE employee_id_seq;

---------------------------------------------------------------------------
-- DROPPING TABLES FOR FLIGHT RESERVATION MODEL --  
---------------------------------------------------------------------------
DROP TABLE pass_resv_flight_linking; 
DROP TABLE reservation;
DROP TABLE flight;
DROP TABLE employee;
DROP TABLE frequent_flyer_profile;
DROP TABLE passenger_payment;
DROP TABLE passenger;
---------------------------------------------------------------------------
-- CREATING TABLES FOR FLIGHT RESERVATION MODEL --  
---------------------------------------------------------------------------
CREATE TABLE passenger 
(
    passenger_id NUMBER(5),
    first_name VARCHAR(25),
    middle_name VARCHAR(25) NULL,
    last_name VARCHAR(25),
    email CHAR(25),
    gender CHAR(25),
    country_of_residence VARCHAR(25),
    state_of_residence VARCHAR(25),
    mailing_address_1 VARCHAR(25),
    mailing_address_2 VARCHAR(25) NULL,
    mailing_city CHAR(25),
    mailing_state CHAR(2),
    mailing_zip CHAR(5),
    primary_phone CHAR(12),
    secondary_phone CHAR(12) NULL,
    CONSTRAINT passenger_pk 
    PRIMARY KEY(passenger_id),
    CONSTRAINT passenger_email_ck 
    CHECK(LENGTH(email) >=7),
    CONSTRAINT passenger_email_uq
    UNIQUE (email)
);

CREATE TABLE passenger_payment
(
    payment_id NUMBER(5), 
    passenger_id NUMBER(5),
    cardholder_first_name VARCHAR(25),
    cardholder_mid_name VARCHAR(25),
    cardholder_last_name VARCHAR(25),
    cardtype VARCHAR(25),
    cardnumber VARCHAR(25),
    expiration_date DATE,
    cc_id VARCHAR(25),
    billing_address VARCHAR(25),
    billing_city CHAR(25),
    billing_state CHAR(2),
    billing_zip CHAR(5),
    CONSTRAINT passenger_payment_pk 
    PRIMARY KEY(payment_id), 
    CONSTRAINT passenger_fk_payment 
    FOREIGN KEY(passenger_id) 
    REFERENCES passenger(passenger_id)
);

CREATE TABLE frequent_flyer_profile
(
    passenger_id NUMBER(5), 
    frequent_flyer_id VARCHAR(25),
    ff_password VARCHAR(25),
    ff_level VARCHAR(25),
    ff_miles_balance NUMBER(20) DEFAULT 5000,
    CONSTRAINT ff_profile_pk 
    PRIMARY KEY(passenger_id),
    CONSTRAINT ff_profile_fk_passenger 
    FOREIGN KEY(passenger_id) 
    REFERENCES passenger(passenger_id),
    CONSTRAINT frequent_flyer_id_uq 
    UNIQUE(frequent_flyer_id),
    CONSTRAINT ff_level_ck  
    CHECK(ff_level IN ('B','S','G','P'))
);

CREATE TABLE employee 
(
    employee_id NUMBER(5),
    first_name VARCHAR(25),
    last_name VARCHAR(25),
    birthday DATE,
    tax_id_number VARCHAR(25),
    mailing_address  VARCHAR(25),
    mailing_city VARCHAR(25),
    mailing_state CHAR(2),
    mailing_zip CHAR(5),
    emp_level CHAR(1),
    CONSTRAINT employee_pk 
    PRIMARY KEY(employee_id),
    CONSTRAINT tax_id_number_uq 
    UNIQUE (tax_id_number), 
    CONSTRAINT emp_level_ck  
    CHECK(emp_level IN ('1','2','3'))
);

CREATE TABLE flight
(
    flight_id NUMBER(5), 
    flight_number VARCHAR(5),
    departure_datetime TIMESTAMP,
    departure_city CHAR(3),
    arrival_city CHAR(3),
    assigned_employee NUMBER NULL,
    CONSTRAINT flight_pk 
    PRIMARY KEY(flight_id),
    CONSTRAINT flight_fk_employee 
    FOREIGN KEY(assigned_employee) 
    REFERENCES employee(employee_id)
);

CREATE TABLE reservation
(
    reservation_id NUMBER(5), 
    confirmation_number VARCHAR(25),
    date_booked DATE DEFAULT SYSDATE,
    trip_contact_email VARCHAR(25),
    trip_contact_phone CHAR(12),
    CONSTRAINT reservation_pk 
    PRIMARY KEY(reservation_id),
    CONSTRAINT reservation_conf_num_uq 
    UNIQUE (confirmation_number)
);

CREATE TABLE pass_resv_flight_linking 
(
    passenger_id NUMBER(5),
    reservation_id NUMBER(5),
    flight_id NUMBER(5),
    seat_assignment VARCHAR(25) NULL,
    ticket_number VARCHAR(25) NULL,
    checked_in_flag  CHAR(1),
    boarded_flag CHAR(1),
    CONSTRAINT pass_resv_flight_linking_pk 
    PRIMARY KEY(passenger_id,reservation_id,flight_id), 
    CONSTRAINT pass_resv_flight_linking_fk_passenger 
    FOREIGN KEY(passenger_id)
    REFERENCES passenger(passenger_id),
    CONSTRAINT pass_resv_flight_linking_fk_resv 
    FOREIGN KEY(reservation_id)
    REFERENCES reservation(reservation_id),
    CONSTRAINT pass_resv_flight_linking_fk_flight 
    FOREIGN KEY(flight_id)
    REFERENCES flight(flight_id)
);
---------------------------------------------------------------------------
-- CREATING INDEXES FOR FLIGHT RESERVATION MODEL -- 
---------------------------------------------------------------------------
CREATE INDEX employee_last_name_ix
 ON employee (last_name);

CREATE INDEX flight_flight_num_ix
  ON flight (flight_number);
  
---------------------------------------------------------------------------
-- CREATING SEQUENCES FOR FLIGHT RESERVATION MODEL -- 
---------------------------------------------------------------------------
CREATE SEQUENCE flight_id_seq
  START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE passenger_id_seq
  START WITH 1 INCREMENT BY 1;
  
CREATE SEQUENCE reservation_id_seq
  START WITH 1 INCREMENT BY 1;
  
CREATE SEQUENCE payment_id_seq
  START WITH 1 INCREMENT BY 1;
  
CREATE SEQUENCE employee_id_seq
  START WITH 100001 INCREMENT BY 1; 

---------------------------------------------------------------------------
-- INSERTING VALUES FOR FLIGHT RESERVATION MODEL --  
---------------------------------------------------------------------------
INSERT INTO employee 
(employee_id,first_name,last_name,birthday,tax_id_number,mailing_address,mailing_city,mailing_state,mailing_zip,emp_level)
VALUES 
(1,'Jenna','Watson',TO_DATE('01-MAY-1994','DD-MON-RRRR'),'11111','10 east city way','BeeCave','TX','78726','1');

INSERT INTO employee 
(employee_id,first_name,last_name,birthday,tax_id_number,mailing_address,mailing_city,mailing_state,mailing_zip,emp_level)
VALUES 
(2,'Wendy','Smith',TO_DATE('02-MAY-1994','DD-MON-RRRR'),'22222','20 west city way','Brentwood','TX','78732','2');

INSERT INTO employee 
(employee_id,first_name,last_name,birthday,tax_id_number,mailing_address,mailing_city,mailing_state,mailing_zip,emp_level)
VALUES 
(3,'Smitha','Saxena',TO_DATE('03-MAY-1994','DD-MON-RRRR'),'33333','30 east city way','San Jose','CA','94536','1');

INSERT INTO employee 
(employee_id,first_name,last_name,birthday,tax_id_number,mailing_address,mailing_city,mailing_state,mailing_zip,emp_level)
VALUES 
(4,'Lee','Hemmingway',TO_DATE('04-MAY-1994','DD-MON-RRRR'),'44444','40 west city way','San Ramon','CA','94538','3');

INSERT INTO employee 
(employee_id,first_name,last_name,birthday,tax_id_number,mailing_address,mailing_city,mailing_state,mailing_zip,emp_level)
VALUES 
(5,'Barbie','Singer',TO_DATE('05-MAY-1994','DD-MON-RRRR'),'55555','50 east city way','Bronx','NY','70856','1');

INSERT INTO employee 
(employee_id,first_name,last_name,birthday,tax_id_number,mailing_address,mailing_city,mailing_state,mailing_zip,emp_level)
VALUES 
(6,'Carlos','Leslie',TO_DATE('06-MAY-1994','DD-MON-RRRR'),'66666','60 west city way','Queens','NY','70964','3');

COMMIT;

INSERT INTO passenger
(passenger_id, first_name,middle_name,last_name,email,gender,country_of_residence,state_of_residence,mailing_address_1,
mailing_address_2,mailing_city,mailing_state,mailing_zip,primary_phone,secondary_phone)
VALUES 
(1,'Rathi',NULL,'Kannan','rk27867@utexas.edu','Female','USA','TX','30000 Blueberry St',
NULL,'Mueller','TX','78736','408-931-5998',NULL);

INSERT INTO passenger
(passenger_id, first_name,middle_name,last_name,email,gender,country_of_residence,state_of_residence,mailing_address_1,
mailing_address_2,mailing_city,mailing_state,mailing_zip,primary_phone,secondary_phone)
VALUES 
(2,'Will','Mena','Bruce','wb99999@utexas.edu','Male','USA','TX','30000 Sandhill St',
NULL,'Spicewood','TX','78750','512-800-9000','512-700-8900');

COMMIT;

INSERT INTO frequent_flyer_profile 
(passenger_id,frequent_flyer_id,ff_password,ff_level,ff_miles_balance)
VALUES 
(1,'FF89ABC','secret007','B',6000);

INSERT INTO frequent_flyer_profile 
(passenger_id,frequent_flyer_id,ff_password,ff_level,ff_miles_balance)
VALUES 
(2,'FF90ABC','bond007','S',10000);

COMMIT;

INSERT INTO passenger_payment 
(payment_id,passenger_id,cardholder_first_name,cardholder_mid_name,cardholder_last_name,cardtype,cardnumber,expiration_date,
cc_id,billing_address,billing_city,billing_state,billing_zip)
VALUES 
(1,1,'Rathi',NULL,'Kannan','VISA','426678231100',TO_DATE('01-JUN-2024','DD-MON-RRRR'),
'000','30000 Blueberry St','Mueller','TX','78736');

INSERT INTO passenger_payment 
(payment_id,passenger_id,cardholder_first_name,cardholder_mid_name,cardholder_last_name,cardtype,cardnumber,expiration_date,
cc_id,billing_address,billing_city,billing_state,billing_zip)
VALUES 
(2,1,'Rathi',NULL,'Kannan','MASTER','511567671122',TO_DATE('11-JUN-2024','DD-MON-RRRR'),
'111','50000 Jamberry St','BeeCave','TX','78731');

INSERT INTO passenger_payment 
(payment_id,passenger_id,cardholder_first_name,cardholder_mid_name,cardholder_last_name,cardtype,cardnumber,expiration_date,
cc_id,billing_address,billing_city,billing_state,billing_zip)
VALUES 
(3,2,'Will','Mena','Bruce','VISA','426681812233',TO_DATE('11-SEP-2024','DD-MON-RRRR'),
'222','30000 Sandhill St','Spicewood','TX','78750');

COMMIT;

INSERT INTO flight 
(flight_id,flight_number,departure_datetime,departure_city,arrival_city,assigned_employee)
VALUES 
(1,'UA231',TIMESTAMP '2012-06-01 08:00:00','SAT','ELP',1);

INSERT INTO flight 
(flight_id,flight_number,departure_datetime,departure_city,arrival_city,assigned_employee)
VALUES 
(2,'UA232',TIMESTAMP '2021-06-01 11:00:00','ELP','SAN',1);

INSERT INTO flight 
(flight_id,flight_number,departure_datetime,departure_city,arrival_city,assigned_employee)
VALUES 
(3,'UA451',TIMESTAMP '2021-06-01 15:00:00','SAN','ELP',2);

INSERT INTO flight 
(flight_id,flight_number,departure_datetime,departure_city,arrival_city,assigned_employee)
VALUES 
(4,'UA452',TIMESTAMP '2021-06-01 17:00:00','ELP','SAT',2);

INSERT INTO flight 
(flight_id,flight_number,departure_datetime,departure_city,arrival_city,assigned_employee)
VALUES 
(5,'UA231',TIMESTAMP '2021-06-02 08:00:00','SAT','ELP',3);

INSERT INTO flight 
(flight_id,flight_number,departure_datetime,departure_city,arrival_city,assigned_employee)
VALUES 
(6,'UA232',TIMESTAMP '2021-06-02 11:00:00','ELP','SAN',3);

INSERT INTO flight 
(flight_id,flight_number,departure_datetime,departure_city,arrival_city,assigned_employee)
VALUES 
(7,'UA451',TIMESTAMP '2021-06-02 15:00:00','SAN','ELP',4);

INSERT INTO flight 
(flight_id,flight_number,departure_datetime,departure_city,arrival_city,assigned_employee)
VALUES 
(8,'UA452',TIMESTAMP '2021-06-02 17:00:00','ELP','SAT',4);

COMMIT;

INSERT INTO reservation 
(reservation_id,confirmation_number, date_booked,trip_contact_email,trip_contact_phone)
VALUES 
(1,'23BEE',TO_DATE('21-APR-2021','DD-MON-RRRR'),'Janice','5128099044');

COMMIT;

INSERT INTO pass_resv_flight_linking 
(passenger_id,reservation_id,flight_id,seat_assignment,ticket_number,checked_in_flag,boarded_flag) 
VALUES 
(1,1,1,'38E','TICK123','N','N');

INSERT INTO pass_resv_flight_linking 
(passenger_id,reservation_id,flight_id,seat_assignment,ticket_number,checked_in_flag,boarded_flag) 
VALUES 
(1,1,2,'29E','TICK123','N','N');

INSERT INTO pass_resv_flight_linking 
(passenger_id,reservation_id,flight_id,seat_assignment,ticket_number,checked_in_flag,boarded_flag) 
VALUES 
(1,1,3,'18E','TICK123','N','N');

INSERT INTO pass_resv_flight_linking 
(passenger_id,reservation_id,flight_id,seat_assignment,ticket_number,checked_in_flag,boarded_flag) 
VALUES 
(1,1,4,'48E','TICK123','N','N');

INSERT INTO pass_resv_flight_linking 
(passenger_id,reservation_id,flight_id,seat_assignment,ticket_number,checked_in_flag,boarded_flag) 
VALUES 
(2,1,1,'38F','TICK123','N','N');

INSERT INTO pass_resv_flight_linking 
(passenger_id,reservation_id,flight_id,seat_assignment,ticket_number,checked_in_flag,boarded_flag) 
VALUES 
(2,1,2,'29F','TICK123','N','N');

INSERT INTO pass_resv_flight_linking 
(passenger_id,reservation_id,flight_id,seat_assignment,ticket_number,checked_in_flag,boarded_flag) 
VALUES 
(2,1,3,'18F','TICK123','N','N');

INSERT INTO pass_resv_flight_linking 
(passenger_id,reservation_id,flight_id,seat_assignment,ticket_number,checked_in_flag,boarded_flag) 
VALUES 
(2,1,4,'48F','TICK123','N','N');

COMMIT;

