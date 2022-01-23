-- Kannan_Rathi_RK27867

-- 1)
SELECT COUNT(*) AS frequent_flyer_count, MIN(miles_balance) AS min_miles, MAX(miles_balance) AS max_miles
FROM frequent_flyer_profile;

-- 2)
    
SELECT summary1.passenger_id, summary2.cards_on_file,summary2.latest_exp_date
FROM
        (SELECT passenger_id 
        FROM passenger)summary1
    LEFT JOIN
        (SELECT passenger_id, COUNT(*) AS cards_on_file,MAX(expiration_date) AS latest_exp_date
        FROM passenger_payment
        GROUP BY passenger_id)summary2
    ON summary1.passenger_id = summary2.passenger_id
ORDER BY summary1.passenger_id
;

-- 3) 
SELECT mailing_city,COUNT(*) AS passenger_count,ROUND(AVG(miles_balance))  AS average_miles_balance
FROM
    (SELECT p.passenger_id,mailing_city,miles_balance
    FROM passenger p
         JOIN frequent_flyer_profile ff
         ON p.passenger_id = ff.passenger_id)
GROUP BY mailing_city
ORDER BY average_miles_balance DESC;

-- 4)
SELECT DISTINCT summary1.passenger_id,summary2.trip_contact_email,summary1.flight_count 
FROM
    (
    SELECT passenger_id, COUNT(flight_id) as flight_count 
    FROM 
    (
    SELECT  linktbl.passenger_id,linktbl.flight_id,r.trip_contact_email 
        FROM pass_resv_flight_linking linktbl
            JOIN reservation r
            ON linktbl.reservation_id = r.reservation_id
    )
    GROUP BY passenger_id
    )
    summary1
    JOIN
    (
        SELECT  linktbl.passenger_id,linktbl.flight_id,r.trip_contact_email 
        FROM pass_resv_flight_linking linktbl
            JOIN reservation r
            ON linktbl.reservation_id = r.reservation_id
    )    
    summary2
    ON summary1.passenger_id = summary2.passenger_id
ORDER BY flight_count DESC;


-- 5)
   
SELECT first_name,last_name,FLOOR((miles_balance-5000)/10000) AS vouchers_earned
FROM passenger p
     JOIN frequent_flyer_profile ff
     ON p.passenger_id = ff.passenger_id
WHERE FLOOR((miles_balance-5000)/10000) > 2
ORDER BY vouchers_earned ASC,last_name ASC;

-- 6)

SELECT first_name,last_name,FLOOR((miles_balance-5000)/10000) AS vouchers_earned
FROM passenger p
     JOIN frequent_flyer_profile ff
     ON p.passenger_id = ff.passenger_id
WHERE (ff_level <> 'G') AND FLOOR((miles_balance-5000)/10000) > 2
ORDER BY vouchers_earned ASC,last_name ASC;

-- 7)
SELECT mailing_city,gender,COUNT(flight_id)
FROM passenger p
     JOIN pass_resv_flight_linking linkingtbl
     ON p.passenger_id = linkingtbl.passenger_id
WHERE mailing_state = 'TX'
GROUP BY ROLLUP(mailing_city,gender)
ORDER BY mailing_city;

-- CUBE operator provides tally based on different column combinations. It is useful for detailed
-- data analysis when considering different scenarios.

-- 8)
SELECT flight_number,departure_city,arrival_city,COUNT(DISTINCT passenger_id) AS unique_passengers
FROM flight f
     JOIN pass_resv_flight_linking linktbl
     ON f.flight_id = linktbl.flight_id
GROUP BY flight_number,departure_city,arrival_city
HAVING COUNT(DISTINCT passenger_id) >= 2
ORDER BY flight_number ASC;
     

-- 9)
SELECT DISTINCT employee_id, first_name, last_name
FROM employee 
WHERE employee_id IN 
            (SELECT assigned_employee 
             FROM FLIGHT 
             WHERE assigned_employee is NOT NULL)
ORDER BY employee_id;
    
-- 10)
SELECT frequent_flyer_id, ff_level,miles_balance 
FROM frequent_flyer_profile
WHERE miles_balance > 
                  (
                    SELECT AVG(miles_balance)
                    FROM frequent_flyer_profile
                    )
ORDER BY miles_balance;

-- 11)
-- Using JOIN
SELECT first_name, last_name, email, primary_phone, secondary_phone, mailing_city 
FROM passenger p
LEFT JOIN pass_resv_flight_linking linktbl
ON p.passenger_id = linktbl.passenger_id
WHERE reservation_id IS NULL
ORDER BY mailing_city ;

-- Using Subquery
SELECT first_name, last_name, email, primary_phone, secondary_phone, mailing_city   
FROM passenger  
WHERE passenger_id NOT IN (SELECT DISTINCT passenger_id FROM pass_resv_flight_linking)
ORDER BY mailing_city ;

-- 12)
SELECT last_name, first_name, (num_flight - num_seat) AS flights_no_seat
FROM
    (
    SELECT p.passenger_id, last_name, first_name, count(flight_id) AS num_flight,count(seat_assignment) AS num_seat 
    FROM passenger p
            JOIN pass_resv_flight_linking linktbl
            ON p.passenger_id = linktbl.passenger_id
    GROUP BY p.passenger_id, last_name, first_name
    )
ORDER BY last_name;

-- 13)
SELECT r.reservation_id,date_booked,seat_assignment
FROM reservation r
         JOIN pass_resv_flight_linking linktbl
         ON r.reservation_id = linktbl.reservation_id
WHERE seat_assignment IN 
                        (
                        SELECT seat_assignment 
                        FROM pass_resv_flight_linking
                        GROUP BY seat_assignment
                        HAVING COUNT(seat_assignment) = 1 
                        )
ORDER BY seat_assignment;

-- 14)

SELECT summary1.passenger_id, summary1.email,floor(SYSDATE - summary2.recent_date_booked) AS days_since_latest_booking
FROM passenger summary1
    JOIN 
        (SELECT passenger_id,MAX(date_booked) AS recent_date_booked
        FROM pass_resv_flight_linking linktbl
             JOIN reservation r
             ON linktbl.reservation_id = r.reservation_id
        GROUP BY passenger_id)summary2
    ON summary1.passenger_id = summary2.passenger_id
    
