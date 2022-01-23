-- Kannan_Rathi_RK27867

-- 1)
SELECT first_name, last_name, email, primary_phone
FROM passenger
ORDER BY last_name ASC;

-- 2)
SELECT first_name||' '||last_name AS passenger_full_name 
FROM passenger
WHERE SUBSTR(last_name,1,1) IN ('A','B','C')
ORDER BY first_name ASC;

-- 3)
SELECT employee_id, first_name, last_name, birthday, mailing_address
FROM employee
WHERE (birthday > '01-JAN-70') AND (birthday <= '31-DEC-79')
ORDER BY birthday DESC;

-- 4)
SELECT employee_id, first_name, last_name, birthday, mailing_address
FROM employee
WHERE birthday BETWEEN '02-JAN-70' AND  '31-DEC-79' 
ORDER BY birthday DESC;

-- 5)
SELECT passenger_id,frequent_flyer_id,ff_level AS Status,miles_balance AS Miles_Earned, 
           floor(miles_balance/12500) AS free_flights
FROM frequent_flyer_profile
WHERE ROWNUM <= 8
ORDER BY Miles_Earned DESC;

-- 6)
SELECT passenger_id,frequent_flyer_id,ff_level AS Status_level,miles_balance AS Balance 
FROM frequent_flyer_profile
WHERE floor((miles_balance-5000)/10000) > 4;

-- 7)
SELECT first_name, last_name, mailing_address_1, mailing_address_2, mailing_state, mailing_zip 
FROM passenger
WHERE mailing_address_2 IS NULL
ORDER BY last_name;

-- 8)
SELECT SYSDATE AS today_unformatted, TO_CHAR(SYSDATE,'MM/DD/YYYY') AS today_formatted,price,
tax_rate, tax_sum, price+tax_sum AS final_total
FROM (SELECT 100 AS price,0.0825 AS tax_rate, 100*.0825 AS tax_sum FROM dual);

-- 9)
SELECT *
FROM (SELECT passenger_id, frequent_flyer_id, ff_level,miles_balance 
      FROM frequent_flyer_profile
      ORDER BY miles_balance DESC)
WHERE ROWNUM<=5;      

-- 10)
SELECT first_name,last_name,ff_level AS STATUS
FROM passenger p
     JOIN frequent_flyer_profile f
        ON p.passenger_id = f.passenger_id
ORDER BY miles_balance DESC;  

-- 11)
SELECT reservation_id,first_name||' '||middle_name||' '||last_name  AS passenger_name,flight_id,seat_assignment
FROM passenger p
     JOIN pass_resv_flight_linking linktbl
         ON p.passenger_id = linktbl.passenger_id      
WHERE email ='meredithburrel@pmail.com';

-- 12)
SELECT departure_city, arrival_city, first_name, last_name, seat_assignment,checked_in_flag
FROM passenger p
     JOIN pass_resv_flight_linking linktbl
         ON p.passenger_id = linktbl.passenger_id
     JOIN flight f
         ON linktbl.flight_id  = f.flight_id 
WHERE f.flight_id  = 44
ORDER BY p.last_name;

-- 13)

SELECT DISTINCT first_name, last_name, email
FROM passenger p
     LEFT JOIN pass_resv_flight_linking linktbl
         ON p.passenger_id = linktbl.passenger_id
WHERE linktbl.reservation_id IS NULL         
ORDER BY p.last_name;

-- 14)
    SELECT '1-Top-Tier' AS passenger_tier,frequent_flyer_id,ff_level, miles_balance 
    FROM frequent_flyer_profile
    WHERE miles_balance > 75000 
UNION 
    SELECT '2-Mid-Tier' AS passenger_tier,frequent_flyer_id,ff_level, miles_balance 
    FROM frequent_flyer_profile
    WHERE miles_balance BETWEEN 25000 AND 75000 
UNION
    SELECT '3-Low-Tier' AS passenger_tier,frequent_flyer_id,ff_level, miles_balance  
    FROM frequent_flyer_profile
    WHERE miles_balance < 25000 
ORDER BY miles_balance DESC;

