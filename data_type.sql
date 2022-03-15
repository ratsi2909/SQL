 

-- 1)
SELECT SYSDATE AS unformatted,
       UPPER(TO_CHAR(SYSDATE,'Year')) AS year_caps,
       UPPER(TO_CHAR(SYSDATE,'DAY, Month')) AS day_week_month_caps,
       ROUND(TO_CHAR(SYSDATE,'HH24')) AS hours,
       ROUND(TO_DATE('31-DEC'||'-'||TO_CHAR(SYSDATE,'YYYY'))- SYSDATE) AS date_till_eoy,
       TO_CHAR(SYSDATE,'Mon')||' '||LOWER(TO_CHAR(SYSDATE,'Dy'))||' '||TO_CHAR(SYSDATE,'YYYY') AS abbr_date
FROM DUAL;

-- 2)
SELECT flight_id,
      flight_number,
      'Leaving on '||TO_CHAR(departure_datetime,'Day')||','||TO_CHAR(departure_datetime,'Mon')||' '||
       TO_CHAR(departure_datetime,'DD')||','||TO_CHAR(departure_datetime,'YYYY') as Departure_day,
        CASE departure_city
            WHEN 'SAT' THEN 'Leaving from '||'San Antonio'
            WHEN 'PHX' THEN 'Leaving from '||'Phoenix'
            WHEN 'DAL' THEN 'Leaving from '||'Dallas'
            WHEN 'HOU' THEN 'Leaving from '||'Houston'
            WHEN 'DEN' THEN 'Leaving from '||'Denver'
            WHEN 'ABQ' THEN 'Leaving from '||'Alburqueque'
            WHEN 'LAS' THEN 'Leaving from '||'Las Vegas'
            WHEN 'SAN' THEN 'Leaving from '||'San Diego'
        END AS departure_plan
FROM flight
ORDER BY departure_plan;

-- 3)
SELECT UPPER(SUBSTR(first_name,1,1))||'. '||UPPER(last_name) AS passenger_name,
       NVL(seat_assignment,'Need to add') AS update_seat_assignments
FROM passenger p
     JOIN pass_resv_flight_linking linktbl
     ON p.passenger_id = linktbl.passenger_id
ORDER BY last_name;

-- 4)
SELECT ff_id,point_in_dollars,fullfreeflight||'%' AS fullfreeflight_percent
FROM
    (
    SELECT LOWER(frequent_flyer_id) AS  FF_ID,
           TO_CHAR(ROUND(miles_balance/100),'$9,999,999') AS point_in_dollars,
           ROUND(ROUND((miles_balance/100) * 100)/600)   AS fullfreeflight
    FROM passenger p
         JOIN frequent_flyer_profile ff
         ON p.passenger_id = ff.passenger_id
    ORDER BY fullfreeflight DESC
    )
;
     
-- 5) 
SELECT cardholder_last_name,
       LENGTH(billing_address) AS billing_address_length,
       ROUND(expiration_date - SYSDATE) AS days_until_card_expiration
FROM passenger_payment
WHERE ROUND(expiration_date - SYSDATE) < 0;

-- 6)
SELECT cardholder_last_name, 
       SUBSTR(billing_address,1,INSTR(billing_address,' ')-1) AS Street_Num,
       SUBSTR(billing_address,INSTR(billing_address,' ')+1) AS Street_Name,
       NVL2(cardholder_mid_name,'Does list','None listed') AS mid_name_listed,
       billing_city,
       billing_state,
       billing_zip
FROM passenger_payment;

-- 7)
SELECT first_name,
       last_name,
       '****-****-****-'||SUBSTR(cardnumber,13,4) AS redacted_card_num
FROM passenger p
     JOIN passenger_payment pp 
     ON p.passenger_id = pp.passenger_id
WHERE cardtype <> 'AMEX'
ORDER BY last_name;

-- 8)

SELECT 
    CASE
     WHEN miles_balance >75000  THEN '1-Top-Tier'
     WHEN (miles_balance >=25000 and miles_balance <=75000)  THEN '2-Mid-Tier'
     WHEN miles_balance <25000  THEN '3-Lower-Tier'
    END AS customer_tier,
    frequent_flyer_id, 
    ff_level, 
    miles_balance
FROM frequent_flyer_profile
ORDER BY miles_balance DESC;

-- 9)
SELECT first_name,last_name,frequent_flyer_id,email,miles_balance,
DENSE_RANK() OVER (ORDER BY miles_balance DESC) AS passenger_rank
FROM passenger p
   JOIN frequent_flyer_profile ffp
   ON p.passenger_id = ffp.passenger_id;
   
-- 10)
SELECT *
FROM
(
SELECT  
ROW_NUMBER() OVER (ORDER BY miles_balance DESC) AS row_number,first_name,last_name,frequent_flyer_id,email,miles_balance  
FROM passenger p
   JOIN frequent_flyer_profile ffp
   ON p.passenger_id = ffp.passenger_id
)
WHERE ROW_NUMBER = 4;