
drop table client_dw;
drop view passenger_view;
drop view prospective_view;
drop procedure client_etl_proc;

-- 2)
CREATE TABLE client_dw 
        (client_id, 
        first_name,
        last_name,
        data_source,
        email,
        zipcode,
        phone,
        CONSTRAINT client_dw_pk PRIMARY KEY(client_id,data_source))
AS
  
      SELECT passenger_id AS client_id,
             first_name AS first_name,
             last_name AS last_name,
             'PASS' AS data_source,
             email AS email,
             mailing_zip AS zipcode,
             primary_phone AS phone
      FROM passenger
  
      UNION
  
      SELECT 
             prospective_id AS client_id,
             pc_first_name AS first_name,
             pc_last_name AS last_name,
             'PROS' AS data_source,
             email AS email,
             zip_code AS zipcode,
             SUBSTR(phone,1,3)||'-'||SUBSTR(phone,4,3)||'-'||SUBSTR(phone,7) AS phone
     FROM prospective_client
     ORDER BY data_source,client_id 
  ;
  
  SELECT * FROM client_dw;
  
-- 3)
CREATE OR REPLACE VIEW passenger_view AS
 SELECT 
      passenger_id,
      first_name,
      last_name,
      'PASS' AS data_source,
      email,
      mailing_zip AS zip_code,
      primary_phone AS phone
 FROM passenger;
 
CREATE OR REPLACE VIEW prospective_view AS
 SELECT 
      prospective_id,
      pc_first_name,
      pc_last_name,
      'PROS' as data_source,
      email,
      zip_code,
      SUBSTR(phone,1,3)||'-'||SUBSTR(phone,4,3)||'-'||SUBSTR(phone,7) AS phone
 FROM prospective_client;
 
 SELECT * FROM prospective_view;
 SELECT * FROM passenger_view;

-- 4) 

     INSERT INTO client_dw  
     SELECT *
     FROM passenger_view
     WHERE passenger_view.passenger_id NOT IN (SELECT DISTINCT client_id FROM client_dw);
      
     INSERT INTO client_dw  
     SELECT *
     FROM prospective_view
     WHERE prospective_view.prospective_id NOT IN (SELECT DISTINCT client_id FROM client_dw);
     
-- 5)

-- path 1
MERGE INTO client_dw   dw
   USING prospective_view  pros
   ON (dw.client_id = pros.prospective_id AND dw.data_source = pros.data_source)
      WHEN MATCHED THEN
       UPDATE 
         SET
         dw.first_name  = pros.pc_first_name,
         dw.last_name   = pros.pc_last_name,
         dw.email       = pros.email,
         dw.zipcode     = pros.zip_code,
         dw.phone       = pros.phone
      WHEN NOT MATCHED THEN
         INSERT (dw.client_id ,dw.first_name,dw.last_name ,dw.data_source,
                  dw.email,dw.zipcode,dw.phone  )
         VALUES (pros.prospective_id,pros.pc_first_name,pros.pc_last_name,
                 pros.data_source,pros.email,pros.zip_code,pros.phone);
                 
MERGE INTO client_dw   dw
   USING passenger_view  pass
   ON (dw.client_id = pass.passenger_id AND dw.data_source = pass.data_source)
      WHEN MATCHED THEN
       UPDATE 
         SET
         dw.first_name  = pass.first_name,
         dw.last_name   = pass.last_name,
         dw.email       = pass.email,
         dw.zipcode     = pass.zip_code,
         dw.phone       = pass.phone
      WHEN NOT MATCHED THEN
         INSERT (dw.client_id ,dw.first_name,dw.last_name ,dw.data_source,
                  dw.email,dw.zipcode,dw.phone  )
         VALUES (pass.passenger_id,pass.first_name,pass.last_name,
                 pass.data_source,pass.email,pass.zip_code,pass.phone);
                 

--    path 2  -- is this right?
     TRUNCATE TABLE client_dw;
     INSERT INTO client_dw  
     SELECT *
     FROM prospective_view;
     INSERT INTO client_dw  
     SELECT *
     FROM passenger_view;
     
     SELECT * FROM client_dw;


-- 6)

CREATE OR REPLACE PROCEDURE client_etl_proc 
AS
BEGIN
--- Nightly refresh of data warehouse
--- Update fields from passenger and prospective client views for existing passengers
--- otherwise, insert new records from corresponding views.
    MERGE INTO client_dw   dw
       USING prospective_view  pros
       ON (dw.client_id = pros.prospective_id AND dw.data_source = pros.data_source)
          WHEN MATCHED THEN
           UPDATE 
             SET
             dw.first_name  = pros.pc_first_name,
             dw.last_name   = pros.pc_last_name,
             dw.email       = pros.email,
             dw.zipcode     = pros.zip_code,
             dw.phone       = pros.phone
          WHEN NOT MATCHED THEN
             INSERT (dw.client_id ,dw.first_name,dw.last_name ,dw.data_source,
                      dw.email,dw.zipcode,dw.phone  )
             VALUES (pros.prospective_id,pros.pc_first_name,pros.pc_last_name,
                     pros.data_source,pros.email,pros.zip_code,pros.phone);
                     
    MERGE INTO client_dw   dw
       USING passenger_view  pass
       ON (dw.client_id = pass.passenger_id AND dw.data_source = pass.data_source)
          WHEN MATCHED THEN
           UPDATE 
             SET
             dw.first_name  = pass.first_name,
             dw.last_name   = pass.last_name,
             dw.email       = pass.email,
             dw.zipcode     = pass.zip_code,
             dw.phone       = pass.phone
          WHEN NOT MATCHED THEN
             INSERT (dw.client_id ,dw.first_name,dw.last_name ,dw.data_source,
                      dw.email,dw.zipcode,dw.phone  )
             VALUES (pass.passenger_id,pass.first_name,pass.last_name,
                     pass.data_source,pass.email,pass.zip_code,pass.phone);
END;
/

CALL client_etl_proc();
-------------------------------------------------------------------------------------------
------------------------------- Additional testing ----------------------------------------
-------------------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------------------
------------------------ inserting more rows into prospective_client-----------------------
-------------------------------------------------------------------------------------------

INSERT INTO Prospective_Client (PROSPECTIVE_ID, PC_FIRST_NAME, PC_LAST_NAME, EMAIL, ZIP_CODE, PHONE)
VALUES (24, 'Arya', 'Test', 'aryatest@pmail.com', '62248', '5013819555');

INSERT INTO Prospective_Client (PROSPECTIVE_ID, PC_FIRST_NAME, PC_LAST_NAME, EMAIL, ZIP_CODE, PHONE)
VALUES (25, 'Barya', 'Test', 'baryatest@pmail.com', '27949', '3378183073');
 
-------------------------------------------------------------------------------------------
------------------------- updating a row in passenger  ------------------------------------
-------------------------------------------------------------------------------------------
UPDATE passenger
  SET first_name = 'Carya',
      last_name  = 'Test'
  WHERE passenger_id = 1;

-------------------------------------------------------------------------------------------
------------------------- replacing views -------------------------------------------------
-------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW passenger_view AS
 SELECT 
      passenger_id,
      first_name,
      last_name,
      'PASS' AS data_source,
      email,
      mailing_zip AS zip_code,
      primary_phone AS phone
 FROM passenger;
 
CREATE OR REPLACE VIEW prospective_view AS
 SELECT 
      prospective_id,
      pc_first_name,
      pc_last_name,
      'PROS' as data_source,
      email,
      zip_code,
      SUBSTR(phone,1,3)||'-'||SUBSTR(phone,4,3)||'-'||SUBSTR(phone,7) AS phone
 FROM prospective_client;
 

-------------------------------------------------------------------------------------------
------------------------- calling procedure -------------------------------------------------
-------------------------------------------------------------------------------------------
CALL client_etl_proc();