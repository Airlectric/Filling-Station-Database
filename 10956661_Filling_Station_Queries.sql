--Automatic processes testing

/*To test the modified `show_inventory_alert()` function, an update was made in
`quantity_in_liters` for a fuel type and  to check if the alert message includes the correct fuel type.*/
UPDATE fuel_inventory
SET quantity_in_liters = 50 
WHERE fuel_type = 'Diesel';

--This query output should not show any notice message since the fuel level is above 100.
UPDATE fuel_inventory
SET quantity_in_liters = 150
WHERE fuel_Type = 'Diesel';


/* query to test auto update fuel inventory when ever a transaction is made*/
-- Before
SELECT * FROM fuel_inventory; 

INSERT INTO sale_transaction (transaction_date, fuel_id, quantity_in_liters, price, customer_id)
VALUES
  ('2022-01-01 10:00:00', 'fuel01', 20, 2.8, 1),
  ('2022-01-02 11:00:00', 'fuel02', 15, 3.2, 2),
  ('2022-01-02 12:00:00', 'fuel03', 25, 1.8, 3),
  ('2022-01-03 13:00:00', 'fuel04', 5, 2.1, 4),
  ('2022-01-03 14:00:00', 'fuel05', 10, 2.6, 5),
  ('2022-01-04 15:00:00', 'fuel06', 30, 0.5, 6),
  ('2022-01-04 16:00:00', 'fuel07', 8, 3.5, 7),
  ('2022-01-05 17:00:00', 'fuel08', 20, 2.1, 8),
  ('2022-01-05 18:00:00', 'fuel09', 12, 2.3, 9),
  ('2022-01-06 19:00:00', 'fuel10', 15, 2.9, 10),
  ('2022-01-06 20:00:00', 'fuel11', 5, 3.8, 11),
  ('2022-01-07 21:00:00', 'fuel12', 10, 2.4, 12),
  ('2022-01-07 22:00:00', 'fuel13', 7, 4.1, 13),
  ('2022-01-08 23:00:00', 'fuel14', 20, 1.5, 14);

-- After
SELECT * FROM fuel_inventory; 



--query to test which function is supposed to allow the database admin to easily add an new customer to the database:
SELECT add_customer('Kofi', 'Adu', '0241234567', 'kofi.adu@gmail.com');

SELECT add_customer('Adwoa', 'Boatemaa', '0501234567', 'adwoa.boatemaa@yahoo.com');

SELECT add_customer('Yaw', 'Owusu', '0271234567', 'yaw.owusu@hotmail.com');

SELECT add_customer('Abena', 'Asare', '0541234567', 'abena.asare@gmail.com');

SELECT add_customer('Kwabena', 'Nkrumah', '0201234567', 'kwabena.nkrumah@yahoo.com');

SELECT * FROM customer


--query to test function which is supposed to allow the database admin to easily add an new employee to the database:
SELECT add_employee('Kwame', 'Adu', 'kwameadu@example.com', '+233541234567', 'Sales Representative');

SELECT add_employee('Ama', 'Ababio', 'amaababio@example.com', '+233542345678', 'Operations Manager');

SELECT add_employee('Kofi', 'Darko', 'kofidarko@example.com', '+233543456789', 'Customer Service Representative');

SELECT add_employee('Adwoa', 'Mensah', 'adwoamensah@example.com', '+233544567890', 'Accountant');

SELECT add_employee('Yaw', 'Agyemang', 'yawagyemang@example.com', '+233545678901', 'Marketing Coordinator');

SELECT * FROM employee


-- General Query tests

--List all the fuel inventory items along with their quantity and supplier
SELECT fuel_id, fuel_type, quantity_in_liters, supplier_name
FROM fuel_inventory
INNER JOIN supplier ON fuel_inventory.supplier_id = supplier.supplier_id;


--List all the sale transactions along with the customer and payment method used
SELECT transaction_id, transaction_date, fuel_id, quantity_in_liters, price, first_name, last_name, payment_method_name
FROM sale_transaction
INNER JOIN customer ON sale_transaction.customer_id = customer.customer_id
INNER JOIN sales_transactions_payment_methods ON sale_transaction.transaction_id = sales_transactions_payment_methods.sales_transaction_id
INNER JOIN payment_methods ON sales_transactions_payment_methods.payment_method_id = payment_methods.payment_method_id;


--List all the fuel pumps along with their associated tank
SELECT pump_id, tank_id
FROM fuel_pumps;


--List all the employees along with their job title:
SELECT first_name, last_name, job_title
FROM employee;



--Find all fuel types and their corresponding tank capacities:
SELECT fuel_type_id, capacity_in_liters
FROM Fuel_tanks;


--Find all suppliers and their associated fuel types:
SELECT s.supplier_name, f.fuel_type_id 
FROM supplier as s
JOIN Fuel_tanks as f ON s.tank_id = f.tank_id;


--Find all fuel inventory items with their associated supplier and tank capacity:
SELECT f.fuel_id, f.fuel_type, f.quantity_in_liters, f.price_per_liter, s.supplier_name, t.capacity_in_liters
FROM fuel_inventory as f
JOIN supplier as s ON f.supplier_id = s.supplier_id
JOIN Fuel_tanks t ON s.tank_id = t.tank_id;


--Find all fuel pump IDs and their associated tank IDs:
SELECT pump_id, tank_id
FROM Fuel_pumps;


--Find all customer names and their associated email addresses
SELECT first_name, last_name, email
FROM customer;


--Find all sale transactions with their associated customer names and payment methods:
SELECT s.transaction_id, s.transaction_date, c.first_name, c.last_name, p.payment_method_name 
FROM sale_transaction as s
JOIN customer as c ON s.customer_id = c.customer_id
JOIN Sales_transactions_Payment_methods stpm ON s.transaction_id = stpm.sales_transaction_id
JOIN Payment_methods p ON stpm.payment_method_id = p.payment_method_id;



--List all sales transactions made by a particular customer
SELECT *
FROM sale_transaction
WHERE customer_id = (SELECT customer_id FROM customer WHERE first_name = 'Yaw' AND last_name = 'Danso');


--List all payment methods used in a particular transaction
SELECT payment_method_name
FROM Payment_methods
INNER JOIN Sales_transactions_Payment_methods ON Payment_methods.payment_method_id = Sales_transactions_Payment_methods.payment_method_id
WHERE Sales_transactions_Payment_methods.sales_transaction_id = 1;



--List all customers who made a purchase using a specific payment method
SELECT customer.first_name, customer.last_name, payment_method_name
FROM customer
INNER JOIN sale_transaction ON customer.customer_id = sale_transaction.customer_id
INNER JOIN Sales_transactions_Payment_methods ON sale_transaction.transaction_id = Sales_transactions_Payment_methods.sales_transaction_id
INNER JOIN Payment_methods ON Sales_transactions_Payment_methods.payment_method_id = Payment_methods.payment_method_id
WHERE payment_method_name = 'Mobile Money';


--List all suppliers and the fuel types they supply
SELECT supplier.supplier_name, fuel_inventory.fuel_Type
FROM supplier
INNER JOIN fuel_inventory ON supplier.supplier_id = fuel_inventory.supplier_id;


--List all sales transactions with their corresponding customer and fuel type
SELECT sale_transaction.transaction_id, customer.first_name, customer.last_name, fuel_inventory.fuel_Type
FROM sale_transaction
INNER JOIN customer ON sale_transaction.customer_id = customer.customer_id
INNER JOIN fuel_inventory ON sale_transaction.fuel_id = fuel_inventory.fuel_id;











  


