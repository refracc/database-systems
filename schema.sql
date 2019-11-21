/*
*  Author: Stewart Anderson
*  Matric: 40345422
*/
SET FOREIGN_KEY_CHECKS=OFF;

DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS enquiry;
DROP TABLE IF EXISTS cam;

SOURCE haulage.sql

SET FOREIGN_KEY_CHECKS=ON;

-- Question 1
SELECT COUNT(*) AS items
FROM manifest
WHERE trip_id=73440;

-- Question 2:
SELECT trip_id
FROM manifest
GROUP BY trip_id
HAVING COUNT(*)=1;

-- Question 3:
SELECT DISTINCT company_name
FROM customer
JOIN manifest ON customer.reference=manifest.delivery_customer_ref
JOIN trip ON trip.trip_id=manifest.trip_id
JOIN driver ON driver.employee_no=trip.employee_no
WHERE driver.first_name='Gavin' AND driver.last_name='Brandon' AND trip.departure_date BETWEEN '2012-04-24' AND '2012-04-25';

-- Question 6:
SELECT make, vehicle.model, registration, COUNT(trip_id) AS trips
FROM vehicle
JOIN model ON model.model=vehicle.model
JOIN trip ON vehicle.vehicle_id=trip.vehicle_id
GROUP BY model.make, vehicle.model, vehicle.registration
ORDER BY COUNT(trip_id) ASC
LIMIT 5;

-- Question 8:
SELECT first_name, last_name
FROM driver
JOIN trip ON trip.employee_no=driver.employee_no
JOIN manifest ON manifest.trip_id=trip.trip_id
WHERE manifest.category IN ('A', 'C')
EXCEPT
SELECT first_name, last_name
FROM driver
JOIN trip ON trip.employee_no=driver.employee_no
JOIN manifest ON manifest.trip_id=trip.trip_id
WHERE manifest.category='B';

SET FOREIGN_KEY_CHECKS=OFF;

ALTER TABLE customer ADD COLUMN assigned_cam varchar(7) NOT NULL;
ALTER TABLE customer ADD COLUMN enquiry_ref integer;

CREATE TABLE IF NOT EXISTS staff (
        employee_no varchar(7) PRIMARY KEY NOT NULL,
        first_name varchar(20) NOT NULL,
        last_name varchar(20) NOT NULL,
        ni_no varchar(13),
        telephone varchar(20),
        mobile varchar(20)
);

CREATE TABLE IF NOT EXISTS enquiry (
        enquiry_ref integer PRIMARY KEY NOT NULL AUTO_INCREMENT,
        employee_no varchar(7) NOT NULL,
        initial_enquiry text NOT NULL,
        enquiry_date datetime NOT NULL,
        cam_response text NOT NULL,
        response_date datetime NOT NULL,
        marking varchar(7)
);

CREATE TABLE IF NOT EXISTS cam (
        employee_no varchar(7) PRIMARY KEY NOT NULL,
        reference integer NOT NULL,
        enquiry_ref integer NOT NULL,
        FOREIGN KEY (enquiry_ref) REFERENCES enquiry(enquiry_ref),
        FOREIGN KEY (reference) REFERENCES customer(reference),
        FOREIGN KEY (employee_no) REFERENCES staff(employee_no)
);


INSERT INTO staff(employee_no, first_name, last_name, ni_no, telephone, mobile) SELECT employee_no, first_name, last_name, ni_no, telephone, mobile FROM driver;

ALTER TABLE enquiry ADD FOREIGN KEY (employee_no) REFERENCES cam(employee_no);

ALTER TABLE driver DROP COLUMN first_name;
ALTER TABLE driver DROP COLUMN last_name;
ALTER TABLE driver DROP COLUMN ni_no;
ALTER TABLE driver DROP COLUMN telephone;
ALTER TABLE driver DROP COLUMN mobile;

ALTER TABLE customer ADD FOREIGN KEY (enquiry_ref) REFERENCES enquiry(enquiry_ref);
ALTER TABLE customer ADD FOREIGN KEY (assigned_cam) REFERENCES cam(employee_no);

ALTER TABLE driver ADD FOREIGN KEY (employee_no) REFERENCES staff(employee_no);

SET FOREIGN_KEY_CHECKS=ON;
