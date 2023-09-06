CREATE TABLE login (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL
);

CREATE TABLE login_audit (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  action VARCHAR(10) NOT NULL,
  timestamp TIMESTAMP DEFAULT NOW(),
  user_id VARCHAR(50) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES login(username)
);


CREATE OR REPLACE FUNCTION login_audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO login_audit (username, action, user_id)
    VALUES (OLD.username, TG_OP, OLD.username);
    RETURN OLD;
  ELSE
    INSERT INTO login_audit (username, action, user_id)
    VALUES (NEW.username, TG_OP, NEW.username);
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER login_audit
AFTER INSERT OR UPDATE OR DELETE
ON login
FOR EACH ROW
EXECUTE PROCEDURE login_audit_trigger();

INSERT INTO login (username, password)
VALUES
  ('Kwabena.Asante', 'password123'),
  ('Adwoa.Agyei', 'qwerty456'),
  ('Kwame.Owusu', 'securepass'),
  ('Esi.Amoah', 'pa$$word'),
  ('Yaw.Nkrumah', 'p@ssw0rd!'),
  ('Afia.Boateng', '12345678'),
  ('Kofi.Mensah', 'passw0rd'),
  ('Ama.Addo', 'examplepass'),
  ('Yaw.Akoto', 'password01'),
  ('Aba.Frimpong', 'secretpass'),
  ('Kojo.Asamoah', 'password1234'),
  ('Akosua.Agyeman', 'password12345'),
  ('Agyei.Annan', 'password123456'),
  ('Maa.Owusu', 'password1234567'),
  ('Yaw.Adomako', 'password12345678'),
  ('Akua.Boadu', 'password123456789'),
  ('Kwesi.Appiah', 'password1234567890'),
  ('Esi.Osei', 'password12345678901'),
  ('Kwadwo.Anokye', 'password123456789012'),
  ('Yaa.Asare', 'password1234567890123');




CREATE TABLE Fuel_tanks (
    tank_id VARCHAR(20) PRIMARY KEY,
    fuel_type_id VARCHAR(20),
    capacity_in_liters NUMERIC(100) NOT NULL
);



CREATE SEQUENCE fuel_tank_id_seq
  START 01
  INCREMENT 1;

CREATE OR REPLACE FUNCTION set_tank_id()
  RETURNS TRIGGER AS
$$
BEGIN
  NEW.tank_id := 'tank' || lpad(nextval('fuel_tank_id_seq')::text, 2, '0');
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER set_tank_id_trigger
  BEFORE INSERT OR UPDATE ON Fuel_tanks
  FOR EACH ROW
  EXECUTE PROCEDURE set_tank_id();


CREATE TABLE Fuel_tanks_audit (
    audit_id SERIAL PRIMARY KEY,
    tank_id VARCHAR(20),
    fuel_type_id VARCHAR(20),
    capacity_in_liters NUMERIC(100) NOT NULL,
    action TEXT NOT NULL,
    audit_time TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE OR REPLACE FUNCTION fuel_tanks_audit() 
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO Fuel_tanks_audit (tank_id, fuel_type_id, capacity_in_liters, action)
        VALUES (OLD.tank_id, OLD.fuel_type_id, OLD.capacity_in_liters, 'DELETE');
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO Fuel_tanks_audit (tank_id, fuel_type_id, capacity_in_liters, action)
        VALUES (NEW.tank_id, NEW.fuel_type_id, NEW.capacity_in_liters, 'UPDATE');
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO Fuel_tanks_audit (tank_id, fuel_type_id, capacity_in_liters, action)
        VALUES (NEW.tank_id, NEW.fuel_type_id, NEW.capacity_in_liters, 'INSERT');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER fuel_tanks_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON Fuel_tanks
FOR EACH ROW 
EXECUTE PROCEDURE fuel_tanks_audit();


INSERT INTO Fuel_tanks (fuel_type_id, capacity_in_liters)
VALUES 
('fuel05', 10000),
('fuel01', 20000),
('fuel02', 15000),
('fuel07', 8000),
('fuel08', 30000),
('fuel09', 20000),
('fuel05', 12000),
('fuel03', 25000),
('fuel11', 18000),
('fuel05', 9000),
('fuel01', 22000),
('fuel02', 17000),
('fuel05', 11000),
('fuel01', 28000),
('fuel02', 19000),
('fuel05', 10000),
('fuel01', 23000),
('fuel02', 16000),
('fuel02', 17000),
('fuel05', 13000),
('fuel01', 27000); 





CREATE TABLE supplier (
  supplier_id SERIAL PRIMARY KEY,
  supplier_name VARCHAR(50),
  contact_name VARCHAR(50),
  contact_email VARCHAR(50),
  contact_phone VARCHAR(20),
  tank_id VARCHAR(20) REFERENCES Fuel_tanks(tank_id)
);




CREATE TABLE supplier_audit (
  audit_id SERIAL PRIMARY KEY,
  supplier_id INT,
  changed_by VARCHAR(50),
  changed_at TIMESTAMP,
  operation CHAR(1),
  supplier_name VARCHAR(50),
  contact_name VARCHAR(50),
  contact_email VARCHAR(50),
  contact_phone VARCHAR(20),
  tank_id VARCHAR(20)
);


CREATE OR REPLACE FUNCTION supplier_audit_fn()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO supplier_audit(supplier_id, changed_by, changed_at, operation, supplier_name, contact_name, contact_email, contact_phone,tank_id)
    VALUES (NEW.supplier_id, current_user, current_timestamp, 'I', NEW.supplier_name, NEW.contact_name, NEW.contact_email, NEW.contact_phone,NEW.tank_id);
    RETURN NEW;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO supplier_audit(supplier_id, changed_by, changed_at, operation, supplier_name, contact_name, contact_email, contact_phone,tank_id)
    VALUES (NEW.supplier_id, current_user, current_timestamp, 'U', NEW.supplier_name, NEW.contact_name, NEW.contact_email, NEW.contact_phone,NEW.tank_id);
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO supplier_audit(supplier_id, changed_by, changed_at, operation, supplier_name, contact_name, contact_email, contact_phone,tank_id)
    VALUES (OLD.supplier_id, current_user, current_timestamp, 'D', OLD.supplier_name, OLD.contact_name, OLD.contact_email, OLD.contact_phone,OLD.tank_id);
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER supplier_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON supplier
FOR EACH ROW
EXECUTE PROCEDURE supplier_audit_fn();



INSERT INTO supplier (supplier_name, contact_name, contact_email, contact_phone, tank_id)
VALUES 
('Ghana Oil Company', 'Kwame Adu', 'kwameadu@goc.com', '+233-244-555-123', 'tank01'),
('Ampofo Gas', 'Yaw Ampofo', 'yawampofo@ampofogas.com', '+233-244-555-124', 'tank02'),
('Oil City', 'Nana Yaa', 'nanayaa@oilcity.com', '+233-244-555-125', 'tank03'),
('Petronas Ghana', 'Kofi Asante', 'kofiasante@petronas.com', '+233-244-555-126', 'tank04'),
('Gazprom Ghana', 'Yuri Ivanov', 'yuriivanov@gazprom.com', '+233-244-555-127', 'tank05'),
('Black Star Energy', 'Ama Darko', 'amadarko@blackstarenergy.com', '+233-244-555-128', 'tank06'),
('Zen Petroleum', 'Kwesi Nyantakyi', 'kwesinyantakyi@zenpetroleum.com', '+233-244-555-129', 'tank07'),
('Star Oil', 'Emmanuel Amartey', 'emmanuelamartey@staroil.com', '+233-244-555-130', 'tank08'),
('Total Ghana', 'Grace Owusu', 'graceowusu@total.com', '+233-244-555-131', 'tank09'),
('Kosmos Energy', 'Nii Addy', 'niiaddy@kosmosenergy.com', '+233-244-555-132', 'tank10'),
('Tullow Ghana', 'Akua Boahene', 'akuaboahene@tullow.com', '+233-244-555-133', 'tank11'),
('Goil Company', 'Daniel Agyemang', 'danielagyemang@goil.com', '+233-244-555-134', 'tank12'),
('ExxonMobil Ghana', 'Esi Mensah', 'esimensah@exxonmobil.com', '+233-244-555-135', 'tank13'),
('Springfield Energy', 'Kevin Okyere', 'kevinokyere@springfieldenergy.com', '+233-244-555-136', 'tank14'),
('Cenpower Generation', 'Seth Adu', 'sethadu@cenpower.com', '+233-244-555-137', 'tank15'),
('Aker Energy', 'Elikem B. Kuenyehia', 'elikemkuenyehia@akerenergy.com', '+233-244-555-138', 'tank16'),
('Eni Ghana', 'Alice Asante', 'aliceasante@eni.com', '+233-244-555-139', 'tank17'),
('Vitol Ghana', 'Kwabena Darko', 'kwabenadarko@vitol.com', '+233-244-555-140', 'tank18'),
('Trafigura Ghana', 'Ama Mensah', 'amamensah@trafigura.com', '+233-244-555-141', 'tank19'),
('Glencore Ghana', 'Joseph Mensah', 'josephmensah@glencore.com', '+233-244-567-456','tank20');



CREATE TABLE fuel_inventory (
  fuel_id VARCHAR(20) PRIMARY KEY,
  fuel_Type VARCHAR(50),
  quantity_in_liters NUMERIC(100),
  price_per_liter DECIMAL(10, 2),
  supplier_id INT REFERENCES supplier(supplier_id)
);


CREATE SEQUENCE fuel_id_seq
  START 01
  INCREMENT 1;

CREATE OR REPLACE FUNCTION set_fuel_id()
  RETURNS TRIGGER AS
$$
BEGIN
  NEW.fuel_id := 'fuel' || lpad(nextval('fuel_id_seq')::text, 2, '0');
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER set_fuel_id_trigger
  BEFORE INSERT OR UPDATE ON fuel_inventory
  FOR EACH ROW
  EXECUTE PROCEDURE set_fuel_id();

CREATE TABLE fuel_inventory_audit (
  audit_id SERIAL PRIMARY KEY,
  fuel_id VARCHAR(20),
  fuel_type VARCHAR(50),
  quantity_in_liters NUMERIC(100),
  price_per_liter DECIMAL(10, 2),
  supplier_id VARCHAR(20),
  changed_at TIMESTAMP NOT NULL,
  changed_by VARCHAR(50) NOT NULL,
  operation CHAR(1) NOT NULL
);

CREATE OR REPLACE FUNCTION fuel_inventory_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO fuel_inventory_audit (fuel_id, fuel_type, quantity_in_liters, price_per_liter,supplier_id, changed_at, changed_by, operation)
        VALUES (OLD.fuel_id, OLD.fuel_type, OLD.quantity_in_liters, OLD.price_per_liter, OLD.supplier_id, NOW(), current_user, 'D');
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO fuel_inventory_audit (fuel_id, fuel_type, quantity_in_liters, price_per_liter, supplier_id, changed_at, changed_by, operation)
        VALUES (NEW.fuel_id, NEW.fuel_type, NEW.quantity_in_liters, NEW.price_per_liter, NEW.supplier_id, NOW(), current_user, 'U');
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO fuel_inventory_audit (fuel_id, fuel_type, quantity_in_liters, price_per_liter, supplier_id, changed_at, changed_by, operation)
        VALUES (NEW.fuel_id, NEW.fuel_type, NEW.quantity_in_liters, NEW.price_per_liter, NEW.supplier_id, NOW(), current_user, 'I');
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fuel_inventory_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON fuel_inventory
FOR EACH ROW
EXECUTE PROCEDURE fuel_inventory_audit();

INSERT INTO fuel_inventory (fuel_Type, quantity_in_liters, price_per_liter, supplier_id)
VALUES
  ('Gasoline', 1000, 8.5, 1),
  ('Diesel', 750, 10.8, 1),
  ('Propane', 500, 7.2, 2),
  ('Ethanol', 250, 6.8, 3),
  ('Methanol', 150, 6.1, 4),
  ('Butanol', 190, 9.6, 5),
  ('V power', 200, 12.5, 6),
  ('Hydrogen', 300, 3.5, 7),
  ('Natural Gas', 600, 9.1, 8),
  ('Biofuel', 400, 2.3, 9),
  ('Biodiesel', 350, 5.9, 10),
  ('Jet Fuel', 450, 3.8, 11),
  ('Kerosene', 200, 7.4, 12),
  ('Aviation Gasoline', 300, 15.1, 13),
  ('LPG', 700, 6.8, 14);

-- this function will show an alert message when ever a particular fuel is running low
CREATE OR REPLACE FUNCTION show_inventory_alert()
RETURNS TRIGGER AS $$
DECLARE
    inventory_level NUMERIC;
    current_fuel_type TEXT;
BEGIN
    SELECT quantity_in_liters, fuel_type INTO inventory_level, current_fuel_type FROM fuel_inventory WHERE fuel_id = NEW.fuel_id;
    IF inventory_level < 100 THEN
        RAISE NOTICE 'Fuel inventory is running low for %', current_fuel_type;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER inventory_alert_trigger
AFTER UPDATE ON fuel_inventory
FOR EACH ROW
WHEN (NEW.quantity_in_liters < 100)
EXECUTE PROCEDURE show_inventory_alert();



CREATE TABLE Fuel_pumps (
    pump_id VARCHAR(20) PRIMARY KEY,
    tank_id VARCHAR(20) REFERENCES Fuel_tanks(tank_id)
);


CREATE SEQUENCE fuel_pump_id_seq
  START 01
  INCREMENT 1;

CREATE OR REPLACE FUNCTION set_fuel_pump_id()
  RETURNS TRIGGER AS
$$
BEGIN
  NEW.pump_id := 'pump' || lpad(nextval('fuel_pump_id_seq')::text, 2, '0');
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER set_fuel_pump_id_trigger
  BEFORE INSERT OR UPDATE ON Fuel_pumps
  FOR EACH ROW
  EXECUTE PROCEDURE set_fuel_pump_id();


CREATE TABLE Fuel_pumps_audit (
    audit_id SERIAL PRIMARY KEY,
    pump_id VARCHAR(20),
    tank_id VARCHAR(20),
    action TEXT NOT NULL,
    audit_time TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE OR REPLACE FUNCTION fuel_pumps_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO Fuel_pumps_audit (pump_id, tank_id, action)
        VALUES (OLD.pump_id, OLD.tank_id, 'DELETE');
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO Fuel_pumps_audit (pump_id, tank_id, action)
        VALUES (NEW.pump_id, NEW.tank_id, 'UPDATE');
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO Fuel_pumps_audit (pump_id, tank_id, action)
        VALUES (NEW.pump_id, NEW.tank_id, 'INSERT');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER fuel_pumps_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON Fuel_pumps
FOR EACH ROW
EXECUTE PROCEDURE fuel_pumps_audit();



INSERT INTO Fuel_pumps (tank_id)
VALUES 
('tank01'),
('tank02'),
('tank03'),
('tank04'),
('tank05'),
('tank06'),
('tank07'),
('tank08'),
('tank09'),
('tank10'),
('tank11'),
('tank12'),
('tank13'),
('tank14'),
('tank15'),
('tank16'),
('tank17'),
('tank18'),
('tank19'),
('tank20');



CREATE TABLE employee (
  employee_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  phone VARCHAR(20),
  job_title VARCHAR(50)
);


CREATE TABLE employee_audit (
  audit_id SERIAL PRIMARY KEY,
  employee_id INTEGER,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  phone VARCHAR(20),
  job_title VARCHAR(50),
  audit_action VARCHAR(10) NOT NULL,
  audit_timestamp TIMESTAMP DEFAULT NOW(),
  audit_user VARCHAR(50)
);


CREATE OR REPLACE FUNCTION employee_audit_trigger() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO employee_audit (employee_id, first_name, last_name, email, phone, job_title, audit_action, audit_user)
    VALUES (OLD.employee_id, OLD.first_name, OLD.last_name, OLD.email, OLD.phone, OLD.job_title, 'D', current_user);
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO employee_audit (employee_id, first_name, last_name, email, phone, job_title, audit_action, audit_user)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name, NEW.email, NEW.phone, NEW.job_title, 'U', current_user);
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO employee_audit (employee_id, first_name, last_name, email, phone, job_title, audit_action, audit_user)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name, NEW.email, NEW.phone, NEW.job_title, 'I', current_user);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER employee_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON employee
FOR EACH ROW
EXECUTE PROCEDURE employee_audit_trigger();

-- This function is supposed to allow the database admin to easily add an new employee to the database
CREATE OR REPLACE FUNCTION add_employee(
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  phone VARCHAR(20),
  job_title VARCHAR(50)
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO employee(first_name, last_name, email, phone, job_title)
  VALUES (first_name, last_name, email, phone, job_title);
END;
$$ LANGUAGE plpgsql;


INSERT INTO employee (first_name, last_name, email, phone, job_title)
VALUES
  ('Kwame', 'Agyapong', 'kwame.agyapong@gmail.com', '0241112223', 'Fuel Attendant'),
  ('Akosua', 'Mensah', 'akosua.mensah@yahoo.com', '0203334445', 'Cashier'),
  ('Yaw', 'Asante', 'yaw.asante@hotmail.com', '0265556667', 'Assistant Manager'),
  ('Ama', 'Boateng', 'ama.boateng@gmail.com', '0248889990', 'Fuel Attendant'),
  ('Kofi', 'Owusu', 'kofi.owusu@yahoo.com', '0207778881', 'Cleaner'),
  ('Abena', 'Tetteh', 'abena.tetteh@hotmail.com', '0243334442', 'Cashier'),
  ('Kwesi', 'Addo', 'kwesi.addo@gmail.com', '0264445556', 'Fuel Attendant'),
  ('Adwoa', 'Dankwa', 'adwoa.dankwa@yahoo.com', '0206667773', 'Assistant Manager'),
  ('Yaw', 'Mensah', 'yaw.mensah@hotmail.com', '0244445554', 'Fuel Attendant'),
  ('Akua', 'Kumasi', 'akua.kumasi@gmail.com', '0208889992', 'Cashier'),
  ('Kwabena', 'Adjei', 'kwabena.adjei@yahoo.com', '0261112224', 'Fuel Attendant'),
  ('Afia', 'Agyeman', 'afia.agyeman@hotmail.com', '0242223331', 'Cleaner'),
  ('Kojo', 'Annan', 'kojo.annan@gmail.com', '0205556668', 'Fuel Attendant'),
  ('Ama', 'Danso', 'ama.danso@yahoo.com', '0268889991', 'Assistant Manager'),
  ('Yaw', 'Owusu', 'yaw.owusu@hotmail.com', '0203334443', 'Fuel Attendant'),
  ('Akosua', 'Addo', 'akosua.addo@gmail.com', '0247778880', 'Cashier'),
  ('Kofi', 'Boateng', 'kofi.boateng@yahoo.com', '0263334441', 'Fuel Attendant'),
  ('Abena', 'Annan', 'abena.annan@hotmail.com', '0206667774', 'Cleaner'),
  ('Kwesi', 'Adu', 'kwesi.adu@gmail.com', '0244445553', 'Fuel Attendant'),
  ('Adwoa', 'Kumasi', 'adwoa.kumasi@yahoo.com', '0261112225', 'Assistant Manager');



CREATE TABLE customer (
  customer_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  contact_number VARCHAR(20),
  email VARCHAR(50)
);


CREATE TABLE customer_audit (
    audit_id SERIAL PRIMARY KEY,
    audit_timestamp TIMESTAMP NOT NULL,
    user_name VARCHAR(50) NOT NULL,
    operation CHAR(1) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    contact_number VARCHAR(20),
    email VARCHAR(50)
);

CREATE OR REPLACE FUNCTION customer_audit_function() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO customer_audit (audit_timestamp, user_name, operation, customer_id, first_name, last_name, contact_number, email)
        VALUES (now(), current_user, 'I', NEW.customer_id, NEW.first_name, NEW.last_name, NEW.contact_number, NEW.email);
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO customer_audit (audit_timestamp, user_name, operation, customer_id, first_name, last_name, contact_number, email)
        VALUES (now(), current_user, 'U', NEW.customer_id, NEW.first_name, NEW.last_name, NEW.contact_number, NEW.email);
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO customer_audit (audit_timestamp, user_name, operation, customer_id, first_name, last_name, contact_number, email)
        VALUES (now(), current_user, 'D', OLD.customer_id, OLD.first_name, OLD.last_name, OLD.contact_number, OLD.email);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customer_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON customer
FOR EACH ROW
EXECUTE PROCEDURE customer_audit_function();

-- This function is supposed to allow the database admin to easily add an new customer to the database
CREATE OR REPLACE FUNCTION add_customer(
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  contact_number VARCHAR(20),
  email VARCHAR(50)
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO customer(first_name, last_name, contact_number, email)
  VALUES (first_name, last_name, contact_number, email);
END;
$$ LANGUAGE plpgsql;


INSERT INTO customer (first_name, last_name, contact_number, email) 
VALUES 
  ('Kwame', 'Agyemang', '0245879631', 'kwame.agyemang@example.com'),
  ('Ama', 'Boateng', '0556897412', 'ama.boateng@example.com'),
  ('Yaw', 'Danso', '0274968521', 'yaw.danso@example.com'),
  ('Akosua', 'Kwakye', '0541789624', 'akosua.kwakye@example.com'),
  ('Kwadwo', 'Kusi', '0204698532', 'kwadwo.kusi@example.com'),
  ('Adwoa', 'Mensah', '0265987412', 'adwoa.mensah@example.com'),
  ('Kofi', 'Owusu', '0556874596', 'kofi.owusu@example.com'),
  ('Ama', 'Tetteh', '0241589632', 'ama.tetteh@example.com'),
  ('Yaw', 'Yeboah', '0556798541', 'yaw.yeboah@example.com'),
  ('Akosua', 'Adjei', '0269541238', 'akosua.adjei@example.com'),
  ('Kwame', 'Boadi', '0207419856', 'kwame.boadi@example.com'),
  ('Abena', 'Addo', '0246897451', 'abena.addo@example.com'),
  ('Kwesi', 'Asante', '0504789652', 'kwesi.asante@example.com'),
  ('Esi', 'Dwamena', '0278459613', 'esi.dwamena@example.com'),
  ('Yaw', 'Fosu', '0556987412', 'yaw.fosu@example.com'),
  ('Ama', 'Gyasi', '0241589632', 'ama.gyasi@example.com'),
  ('Kwabena', 'Kwakye', '0269541238', 'kwabena.kwakye@example.com'),
  ('Afia', 'Mensah', '0556798541', 'afia.mensah@example.com'),
  ('Kofi', 'Owusu-Ansah', '0274589632', 'kofi.owusuansah@example.com'),
  ('Ama', 'Sarpong', '0548963217', 'ama.sarpong@example.com');





CREATE TABLE sale_transaction (
  transaction_id SERIAL PRIMARY KEY,
  transaction_date TIMESTAMP,
  fuel_id VARCHAR(20), 
  quantity_in_liters INT,
  price DECIMAL(10, 2),
  customer_id INT REFERENCES customer(customer_id)
);


CREATE TABLE sale_transaction_Audit (
  transaction_id INT,
  changed_by VARCHAR(50),
  changed_at TIMESTAMP,
  operation CHAR(1), 
  transaction_date TIMESTAMP,
  fuel_id VARCHAR(20),
  quantity_in_liters INT,
  price DECIMAL(10, 2),
  customer_id VARCHAR(20)
);


CREATE OR REPLACE FUNCTION sale_transactions_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO sale_transaction_Audit (transaction_id, changed_by, changed_at, operation, transaction_date, fuel_id, quantity_in_liters, price, customer_id)
        VALUES (OLD.transaction_id, USER, NOW(), 'D', OLD.transaction_date, OLD.fuel_id, OLD.quantity_in_liters , OLD.price, OLD.customer_id);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO sale_transaction_Audit (transaction_id, changed_by, changed_at, operation, transaction_date, fuel_id, quantity_in_liters, price, customer_id)
        VALUES (NEW.transaction_id, USER, NOW(), 'U', NEW.transaction_date, NEW.fuel_id, NEW.quantity_in_liters, NEW.price, NEW.customer_id);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO sale_transaction_Audit (transaction_id, changed_by, changed_at, operation, transaction_date, fuel_id, quantity_in_liters , price, customer_id)
        VALUES (NEW.transaction_id, USER, NOW(), 'I', NEW.transaction_date, NEW.fuel_id, NEW.quantity_in_liters, NEW.price, NEW.customer_id);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER sale_transactions_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON sale_transaction
FOR EACH ROW
EXECUTE PROCEDURE sale_transactions_audit();

CREATE OR REPLACE FUNCTION update_sale_transaction_price()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE sale_transaction
    SET price = NEW.quantity_in_liters * (
                SELECT price_per_liter
                FROM fuel_inventory
                WHERE fuel_id = NEW.fuel_id
            )
    WHERE transaction_id = NEW.transaction_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_sale_transaction_price_trigger
AFTER INSERT ON sale_transaction
FOR EACH ROW
EXECUTE PROCEDURE update_sale_transaction_price();


INSERT INTO sale_transaction (transaction_date, fuel_id, quantity_in_liters,customer_id)
VALUES
  ('2022-01-01 10:00:00', 'fuel01', 20, 1),
  ('2022-01-02 11:00:00', 'fuel02', 15,2),
  ('2022-01-02 12:00:00', 'fuel03', 25, 3),
  ('2022-01-03 13:00:00', 'fuel04', 5, 4),
  ('2022-01-03 14:00:00', 'fuel05', 10,5),
  ('2022-01-04 15:00:00', 'fuel06', 30,6),
  ('2022-01-04 16:00:00', 'fuel07', 8,7),
  ('2022-01-05 17:00:00', 'fuel08', 20,8),
  ('2022-01-05 18:00:00', 'fuel09', 12,9),
  ('2022-01-06 19:00:00', 'fuel10', 15,10),
  ('2022-01-06 20:00:00', 'fuel11', 5, 11),
  ('2022-01-07 21:00:00', 'fuel12', 10,12),
  ('2022-01-07 22:00:00', 'fuel13', 7,13),
  ('2022-01-08 23:00:00', 'fuel14', 20,14),
  ('2022-01-08 00:00:00', 'fuel15', 12,15),
  ('2022-01-09 01:00:00', 'fuel16', 8,16),
  ('2022-01-09 02:00:00', 'fuel17', 5,17),
  ('2022-01-10 03:00:00', 'fuel18',6,18),
  ('2022-01-10 04:00:00', 'fuel19',6,19),
  ('2022-01-11 16:00:00', 'fuel07', 8,7),
  ('2022-01-11 17:00:00', 'fuel08', 20,8),
  ('2022-01-12 18:00:00', 'fuel09', 12,9),
  ('2022-01-12 19:00:00', 'fuel10', 15,10),
  ('2022-01-12 20:00:00', 'fuel11', 5,11),
  ('2022-01-13 21:00:00', 'fuel12', 10,12);


--this function automatically updates the fuel inventory table whenever a new transaction is made in the sales transaction table. 

CREATE OR REPLACE FUNCTION update_fuel_inventory()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE fuel_inventory
    SET quantity_in_liters = quantity_in_liters - NEW.quantity_in_liters
    WHERE fuel_id = NEW.fuel_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER update_fuel_inventory_trigger
AFTER INSERT ON sale_transaction
FOR EACH ROW
EXECUTE PROCEDURE update_fuel_inventory();


CREATE TABLE Payment_methods (
    payment_method_id SERIAL PRIMARY KEY,
    payment_method_name VARCHAR(50) NOT NULL
);


CREATE TABLE Payment_methods_audit (
    audit_id SERIAL PRIMARY KEY,
    payment_method_id INTEGER,
    payment_method_name VARCHAR(50),
    action TEXT NOT NULL,
    audit_time TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE OR REPLACE FUNCTION payment_methods_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO Payment_methods_audit (payment_method_id, payment_method_name, action)
        VALUES (OLD.payment_method_id, OLD.payment_method_name, 'DELETE');
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO Payment_methods_audit (payment_method_id, payment_method_name, action)
        VALUES (NEW.payment_method_id, NEW.payment_method_name, 'UPDATE');
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO Payment_methods_audit (payment_method_id, payment_method_name, action)
        VALUES (NEW.payment_method_id, NEW.payment_method_name, 'INSERT');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER payment_methods_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON Payment_methods
FOR EACH ROW EXECUTE PROCEDURE payment_methods_audit();

INSERT INTO Payment_methods (payment_method_name)
VALUES ('Credit Card'), ('Debit Card'), ('Cash'), ('Mobile Money'), ('Bank Transfer');



CREATE TABLE Sales_transactions_Payment_methods (
    sales_transaction_id INT REFERENCES sale_transaction(transaction_id),
    payment_method_id INTEGER REFERENCES Payment_methods(payment_method_id)
);


CREATE TABLE Sales_transactions_Payment_methods_audit (
    audit_id SERIAL PRIMARY KEY,
    sales_transaction_id INT,
    payment_method_id INTEGER,
    action TEXT NOT NULL,
    audit_time TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE OR REPLACE FUNCTION sales_transactions_payment_methods_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO Sales_transactions_Payment_methods_audit (sales_transaction_id, payment_method_id, action)
        VALUES (OLD.sales_transaction_id, OLD.payment_method_id, 'DELETE');
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO Sales_transactions_Payment_methods_audit (sales_transaction_id, payment_method_id, action)
        VALUES (NEW.sales_transaction_id, NEW.payment_method_id, 'UPDATE');
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO Sales_transactions_Payment_methods_audit (sales_transaction_id, payment_method_id, action)
        VALUES (NEW.sales_transaction_id, NEW.payment_method_id, 'INSERT');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER sales_transactions_payment_methods_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON Sales_transactions_Payment_methods
FOR EACH ROW
EXECUTE PROCEDURE sales_transactions_payment_methods_audit();


INSERT INTO Sales_transactions_Payment_methods (sales_transaction_id, payment_method_id)
VALUES 
    (1, 1), 
    (2, 2), 
    (3, 1), 
    (4, 3), 
    (5, 4), 
    (6, 2), 
    (7, 3), 
    (8, 1), 
    (9, 4), 
    (10, 2),
    (11, 1), 
    (12, 4), 
    (13, 3), 
    (14, 2), 
    (15, 1), 
    (16, 4), 
    (17, 2), 
    (18, 3), 
    (19, 1), 
    (20, 4);







