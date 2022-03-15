 

-- 1)

SET SERVEROUTPUT ON;
DECLARE
 count_flight_var NUMBER;
BEGIN
    SELECT COUNT(DISTINCT flight_id)
    INTO count_flight_var
    FROM flight
    WHERE departure_city = 'SAT';
    IF count_flight_var > 30 THEN
      DBMS_OUTPUT.PUT_LINE('The number of flights from San Antonio is greater than 30.');
    ELSIF count_flight_var <= 30  THEN
      DBMS_OUTPUT.PUT_LINE('The number of flights from San Antonio is less than or equal to 30.');
    END IF;
END;
/


-- 2)

SET SERVEROUTPUT ON;
DECLARE
 count_flight_var NUMBER;
 departure_city_code_var flight.departure_city%TYPE;
BEGIN
    departure_city_code_var := &departure_city_code; 
    SELECT COUNT(DISTINCT flight_id)
    INTO count_flight_var
    FROM flight
    WHERE departure_city = ''''||departure_city_code_var||'''';
    IF count_flight_var > 30 THEN
      DBMS_OUTPUT.PUT_LINE('The number of flights from '|| departure_city_code_var ||' is greater than 30.');
    ELSIF count_flight_var <= 30  THEN
      DBMS_OUTPUT.PUT_LINE('The number of flights from '|| departure_city_code_var ||' is less than or equal to 30.');
    END IF;
END;
/

-- 3)

SET SERVEROUTPUT ON;

BEGIN

INSERT INTO flight
VALUES (flight_id_seq.NEXTVAL,
        '165',
        TO_DATE('04-MAR-20','DD-MON-YY'),
        'SAT',
        'PHX',
         100022);

DBMS_OUTPUT.PUT_LINE('1 row was inserted into the flight table.');       
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('Row was not inserted. Unexpected exception occurred.');

END;
/

-- 4)

SET SERVEROUTPUT ON;
DECLARE

CURSOR passenger_seat IS
    SELECT p.first_name||' '||p.last_name as passenger_name,linktbl.seat_assignment as seat_num 
            FROM passenger  p
            JOIN pass_resv_flight_linking linktbl
            ON p.passenger_id = linktbl.passenger_id
            JOIN flight f
            ON linktbl.flight_id = f.flight_id
            WHERE f.flight_id = 25
            ORDER BY p.passenger_id;

recs passenger_seat%ROWTYPE;

BEGIN
  FOR recs IN passenger_seat 
      LOOP
        DBMS_OUTPUT.PUT_LINE(recs.passenger_name || ' has seat ' || recs.seat_num);
      END LOOP;
END;
/
 
 
-- 5)

CREATE OR REPLACE FUNCTION count_flights
(
flight_number_param flight.flight_number%TYPE
)
RETURN NUMBER
AS
 count_flight_var NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO count_flight_var
    FROM flight
    WHERE flight_number = flight_number_param
    GROUP BY flight_number;

RETURN count_flight_var;    

END;
/
-- testing
SELECT DISTINCT  flight_number, count_flights(flight_number) as count_of_flights
FROM flight;

SELECT DISTINCT  flight_number, COUNT(*) as count_of_flights
FROM flight
GROUP BY flight_number;

-- 6)

CREATE OR REPLACE PROCEDURE update_employee_mailing
(
employee_id_param      employee.employee_id%TYPE,
mailing_address_param  employee.mailing_address%TYPE,
mailing_city_param     employee.mailing_city%TYPE,
mailing_state_param    employee.mailing_state%TYPE,
mailing_zip_param      employee.mailing_zip%TYPE
)
AS
BEGIN
UPDATE employee
SET mailing_address = mailing_address_param,  
    mailing_city = mailing_city_param,
    mailing_state = mailing_state_param, 
    mailing_zip = mailing_zip_param 
WHERE employee_id = employee_id_param;

COMMIT;

EXCEPTION
  WHEN OTHERS THEN 
   ROLLBACK;
END;
/
-- testing
CALL update_employee_mailing(100010 ,'1234 Happy Street','Austin','TX','78708');

SELECT * FROM EMPLOYEE
WHERE EMPLOYEE_ID = 100010;

-- 7)

CREATE OR REPLACE PROCEDURE insert_new_flight
(
flight_number_param      flight.flight_number%TYPE,
departure_datetime_param flight.departure_datetime%TYPE,
departure_city_param     flight.departure_city%TYPE,
arrival_city_param       flight.arrival_city%TYPE,
assigned_employee_param  flight.assigned_employee%TYPE
)
AS
flight_id_var  flight.flight_id%TYPE;
BEGIN

SELECT flight_id_seq.NEXTVAL INTO flight_id_var FROM dual;

INSERT INTO flight
VALUES (flight_id_var,
        flight_number_param,
        departure_datetime_param,
        departure_city_param ,
        arrival_city_param, 
        assigned_employee_param);

COMMIT;

EXCEPTION
WHEN OTHERS THEN
ROLLBACK;

END;
/

-- testing 
CALL insert_new_flight('500',TO_DATE('21-MAY-21','DD-MON-YY'),'AUS','SFO','100034');

SELECT * 
FROM flight
WHERE flight_number = '500';

-- 8) 

CREATE OR REPLACE FUNCTION ff_miles_lookup
(
  passenger_id_param passenger.passenger_id%TYPE
)
RETURN NUMBER
AS

ffp_miles_balance_var NUMBER;

BEGIN

SELECT miles_balance
  INTO ffp_miles_balance_var
FROM frequent_flyer_profile
WHERE passenger_id = passenger_id_param ;

RETURN ffp_miles_balance_var;
END;
/
-- testing
SELECT first_name, last_name, email, ff_miles_lookup(passenger_id) as passenger_miles
FROM passenger; 

