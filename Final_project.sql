USE master  
GO

-- ��������� ����� �������� ���������
SET NOCOUNT ON
GO

-- �������� �� �������� 
IF DB_ID(N'TAXI_PROJECT') IS NOT NULL
    DROP DATABASE TAXI_PROJECT;
GO
-- �������� ��
CREATE DATABASE TAXI_PROJECT  
ON   
( NAME = Taxi_dat,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\taxiproject.mdf',  
    SIZE = 10,  
    MAXSIZE = 50,  
    FILEGROWTH = 5 )  
LOG ON  
( NAME = Taxi_log,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\taxiprojectlog.ldf',  
    SIZE = 5MB,  
    MAXSIZE = 25MB,  
    FILEGROWTH = 5MB );  
GO

USE TAXI_PROJECT  
GO


--================================================������==================================================

-- �������� �� �������
IF OBJECT_ID(N'Client_table') is NOT NULL
    DROP TABLE Client_table
GO
-- �������� �������
CREATE TABLE Client_table 
(
 id_client int IDENTITY NOT NULL,
 cl_first_name nvarchar(30) DEFAULT 'Vasiliy' NOT NULL,
 cl_last_name nvarchar(30) DEFAULT 'Pupkin' NOT NULL,
 cl_patronymic nvarchar(30) DEFAULT 'Petrovich' NOT NULL,
 CONSTRAINT Uniq_client UNIQUE (cl_first_name, cl_last_name, cl_patronymic),
 CONSTRAINT PK_id_client PRIMARY KEY (id_client) 
)
GO



--================================================������==================================================

-- �������� �� �������
IF OBJECT_ID(N'Sale_table') is NOT NULL
    DROP TABLE Sale_table
GO
-- �������� �������
CREATE TABLE Sale_table 
(
 id_sale uniqueidentifier DEFAULT NEWID(),
 cart_number int DEFAULT 00000 NOT NULL,
 current_sale int DEFAULT 0 NULL,
 CONSTRAINT PK_id_sale PRIMARY KEY (id_sale),
 CONSTRAINT Uniq_sale UNIQUE (cart_number),
 id_name int default 1 NOT NULL,
 FOREIGN KEY (id_name) REFERENCES Client_table (id_client)
   -- ON DELETE NO ACTION
   -- ON DELETE SET DEFAULT 
   -- ON DELETE SET NULL
   ON DELETE CASCADE
   ON UPDATE CASCADE
)
GO

-- ���������� �������� � ������� (CHECK)
ALTER TABLE Sale_table   
   ADD validity date DEFAULT CONVERT(date, '1/1/2025') NOT NULL   
   CONSTRAINT CHK_validity   
   CHECK (validity > CONVERT(date, CURRENT_TIMESTAMP) ); 
GO


--================================================��������==================================================

-- �������� �� �������
IF OBJECT_ID(N'Driver_table') is NOT NULL
    DROP TABLE Driver_table
GO
-- �������� �������
CREATE TABLE Driver_table 
(
 id_driver int PRIMARY KEY NOT NULL,
 first_name nvarchar(30) DEFAULT 'Islam' NOT NULL,
 last_name nvarchar(30) DEFAULT 'Magomed' NOT NULL,
 patronymic nvarchar(30) DEFAULT 'Amirovich' NOT NULL,
 telephone_number char(10) DEFAULT '9993658723' NOT NULL,
 CONSTRAINT Uniq_driver UNIQUE (telephone_number),
 status_drive bit DEFAULT 0 NOT NULL
)
GO

-- ������������ ������������������
CREATE SEQUENCE count_by
 START WITH 1
 INCREMENT BY 1;
GO


--================================================����������==================================================

-- �������� �� �������
IF OBJECT_ID(N'Auto_table') is NOT NULL
    DROP TABLE Auto_table
GO
-- �������� �������
CREATE TABLE Auto_table 
(
 id_auto int IDENTITY NOT NULL,
 state_number nvarchar(10) DEFAULT '�123��77' NOT NULL,
 brand nvarchar(20) DEFAULT 'toyota' NOT NULL,
 color nvarchar(20) DEFAULT 'gray' NOT NULL,
 year_of_issue int DEFAULT 2015 NULL,
 car_class nvarchar(20) DEFAULT 'comfort' NOT NULL,
 CONSTRAINT PK_id_auto PRIMARY KEY (id_auto), 
 CONSTRAINT Uniq_auto UNIQUE (state_number),
 driver_id int default 1 NOT NULL,
 FOREIGN KEY (driver_id) REFERENCES Driver_table (id_driver)
 -- ON DELETE NO ACTION
 -- ON DELETE SET DEFAULT 
 -- ON DELETE SET NULL
	ON DELETE CASCADE
	ON UPDATE CASCADE
)


--================================================�����==================================================

-- �������� �� �������
IF OBJECT_ID(N'Order_table') is NOT NULL
    DROP TABLE Order_table
GO
-- �������� �������
CREATE TABLE Order_table 
(
 id_order int IDENTITY NOT NULL,
 order_time DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
 street nvarchar(30) DEFAULT 'Mira' NOT NULL,
 build int DEFAULT 1 NOT NULL,
 luggage bit NULL,
 cost int DEFAULT 300 NOT NULL,
 comment nvarchar(300) NULL,
 payment_method bit DEFAULT 0 NOT NULL,
 car_class nvarchar(20) NULL,
 CONSTRAINT PK_id_order PRIMARY KEY (id_order), 
 fk_client_id int default 1 NOT NULL,
 FOREIGN KEY (fk_client_id) REFERENCES Client_table (id_client)
 -- ON DELETE NO ACTION
 -- ON DELETE SET DEFAULT 
 -- ON DELETE SET NULL
	ON DELETE CASCADE
	ON UPDATE CASCADE,
 fk_driver_id int default 1 NOT NULL,
 FOREIGN KEY (fk_driver_id) REFERENCES Driver_table (id_driver)
 -- ON DELETE NO ACTION
 -- ON DELETE SET DEFAULT 
 -- ON DELETE SET NULL
	ON DELETE CASCADE
	ON UPDATE CASCADE
)
GO


--================================================�������������==================================================

-- �������� �� �������
IF OBJECT_ID(N'Drive_view') is NOT NULL
    DROP VIEW Drive_view
GO

-- ������������� NEWID (��� �������)
CREATE VIEW get_newID AS SELECT newid() AS new_id
GO

-- ������������� �� ������ ������ �������� � ����������
CREATE VIEW Drive_view AS  
SELECT dl.first_name, dl.last_name, dl.patronymic, dl.telephone_number,
		al.state_number, al.brand, al.color, al.year_of_issue, al.car_class
FROM Driver_table dl INNER JOIN Auto_table al
	ON al.driver_id = dl.id_driver
GO

-- ������������� �� ������ ������ ����� � ��������
CREATE VIEW Order_Driver_view AS  
SELECT dt.first_name, dt.last_name, dt.patronymic, dt.telephone_number,
		ot.order_time, ot.fk_driver_id
FROM Driver_table dt INNER JOIN Order_table ot
	ON ot.fk_driver_id = dt.id_driver
GO

CREATE VIEW Full_order_view AS
SELECT O.order_time as order_time, O.street as street, O.build as build, O.car_class,
	   C.cl_first_name as cl_first_name, C.cl_last_name as cl_last_name, C.cl_patronymic as cl_patronymic,
	   D.first_name as dr_first_name, D.last_name as dr_last_name, D.patronymic as dr_patronymic, 
		D.telephone_number as dr_telephone_number,
	   A.state_number as car_state_number, A.brand as car_brand, A.Color as car_color 
FROM Order_table as O
LEFT JOIN Client_table as C ON O.fk_client_id = C.id_client
LEFT JOIN Driver_table as D ON O.fk_driver_id = D.id_driver
LEFT JOIN Auto_table as A ON D.id_driver = A.driver_id
GO


--================================================���������==================================================

-- �������� �� �������
IF OBJECT_ID(N'suitable_car') is NOT NULL
    DROP PROCEDURE suitable_car
GO
-- ��������� ��� ���������� ������� �������
CREATE PROCEDURE suitable_car 
@order_time DATETIME,
@street nvarchar(30),
@build int,
@luggage bit,
@cost int,
@payment_method bit,
@car_class nvarchar(20),
@fk_client_id int
AS
	declare @suitable_driver int
	-- �������� id ��������� ��������� � ���������� ������� �����������
	SELECT TOP(1) @suitable_driver = dt.id_driver 
		FROM Auto_table au INNER JOIN Driver_table dt
		ON au.driver_id = dt.id_driver
		WHERE dt.status_drive = 0 AND au.car_class = @car_class
		ORDER BY (SELECT new_id FROM get_newID)
	-- �������� id ��������� ��������� � ����� �������
	IF @suitable_driver is NULL
	BEGIN
		SELECT TOP(1) @suitable_driver = dt.id_driver 
			FROM Auto_table au INNER JOIN Driver_table dt
			ON au.driver_id = dt.id_driver
			WHERE dt.status_drive = 0 
			ORDER BY (SELECT new_id FROM get_newID)
	END
		
	-- ��������� ������ ��������
	UPDATE Driver_table
		SET status_drive = 1
		WHERE id_driver = @suitable_driver

	-- ��������� �������
	INSERT INTO Order_table(order_time, street, build, luggage, cost, 
							payment_method, car_class, fk_client_id, fk_driver_id)
	VALUES(@order_time, @street, @build, @luggage, @cost, 
			@payment_method, @car_class, @fk_client_id, @suitable_driver)
GO


--================================================�������==================================================

-- ������� ������, ����������� ��������� ��� ��������
CREATE TRIGGER driver_fio_update_trig ON Driver_table
FOR UPDATE AS
 IF UPDATE (first_name) 
    OR UPDATE (last_name)
    OR UPDATE (patronymic)
  BEGIN
   PRINT '������ �������� �������, ��� � ��������'
   ROLLBACK TRANSACTION
  END
GO
-- ������� ������, ����������� ��������� ��� �������
CREATE TRIGGER client_fio_update_trig ON Client_table
FOR UPDATE AS
 IF UPDATE (cl_first_name) 
    OR UPDATE (cl_last_name)
    OR UPDATE (cl_patronymic)
  BEGIN
   PRINT '������ �������� �������, ��� � ��������'
   ROLLBACK TRANSACTION
  END
GO


-- ������ �� ������� �������� ����� �������������
CREATE TRIGGER insert_drive_view ON Drive_view
INSTEAD OF INSERT
AS BEGIN
	-- ������� ��������� �������
	DECLARE @temp_table TABLE (
					id int DEFAULT NEXT VALUE FOR count_by,
					first_name nvarchar(30),
					last_name nvarchar(30),
					patronymic nvarchar(30),
					telephone_number char(10),
					state_number nvarchar(10),
					brand nvarchar(20),
					color nvarchar(20),
					year_of_issue int,
					car_class nvarchar(20)
			)
	-- ���������� �� ��������� �������
	INSERT INTO @temp_table(first_name, last_name, patronymic, telephone_number,
							state_number, brand, color, year_of_issue, car_class)
	SELECT first_name, last_name, patronymic, telephone_number, i.state_number, 
			i.brand, i.color, i.year_of_issue, i.car_class
	FROM inserted i
	-- ���������� ��������
	INSERT INTO Driver_table(id_driver, first_name, last_name, patronymic, telephone_number)
	SELECT id, first_name, last_name, patronymic, telephone_number
	FROM @temp_table
	-- ���������� ����������
	INSERT INTO Auto_table(driver_id, state_number, brand, color, year_of_issue, car_class)
	SELECT i.id, i.state_number, i.brand, i.color, i.year_of_issue, i.car_class
	FROM @temp_table i, Driver_table dl WHERE i.id = dl.id_driver
 END
GO


-- ������ �� �������� �������� ����� �������������
CREATE TRIGGER delete_view_trig ON Drive_view
INSTEAD OF DELETE
AS BEGIN 
	DELETE FROM Driver_table 
	WHERE telephone_number IN (SELECT telephone_number FROM deleted)
	PRINT '����� ������'
   END
GO

-- ������ �� �������� ������ � ����� ������� ��������
CREATE TRIGGER delete_update_trig ON Order_Driver_view
INSTEAD OF DELETE
AS
  BEGIN 
	DELETE FROM Order_table 
		WHERE fk_driver_id IN (SELECT fk_driver_id FROM deleted)
	UPDATE Driver_table
	SET status_drive = 0
		WHERE id_driver IN (SELECT fk_driver_id FROM deleted)
  END
GO


--================================================����������==================================================

-- ���������� ������� ��������
INSERT INTO Client_table(cl_first_name, cl_last_name, cl_patronymic)
VALUES ('�������', '�������', '��������'),
		('��������', '�����', '����������'),
		('�������', '������', '���������'),
		('���������', '�����', '���������'),
		('�������', '�������', '��������'),
		('���������', '�������', '���������'),
		('�����', '������', '����������'),
		('���������', '������', '���������'),
		('��������', '�����', '����������'),
		('��������', '����������', '���������')

-- ���������� ������� ������
INSERT INTO Sale_table(cart_number, current_sale, id_name, validity)
VALUES (296399, 10, 1, '24/08/2022'),
		(304922, 12, 2, '13/04/2024'),
		(492512, 8, 3, '13/04/2024'),
		(370620, 2, 4, '12/08/2024'),
		(237861, 5, 5, '15/02/2023'),
		(304275, 9, 6, '16/02/2025'),
		(104737, 11, 7, '11/10/2023'),
		(251188, 14, 8, '06/07/2022'),
		(349955, 3, 9, '29/05/2024'),
		(211157, 7, 10, '14/10/2023')

-- ���������� ������ ��������� � �����������
INSERT INTO Drive_view
VALUES('Andrew', 'Tkachenko', 'Alexandrovich', '9147856723', '�674��', 'toyota', 'white', 2016, 'comfort'),
		('Daniil', 'Devyatkin', 'Dmitrievich', '9993097439', '�239��', 'kia', 'green', 2014, 'economy'),
		('Anastasia', 'Piskunova', 'Eduardovna', '9147853402', '�982��', 'volkswagen', 'gray', 2015, 'economy'),
		('Vasily', 'Koreshkov', 'Romanovich', '9641592385', '�712��', 'hyundai', 'yellow', 2015, 'comfort'),
		('Ivan', 'Trenev', 'Sergeevich', '9999567832', '�321��', 'audi', 'black', 2017, 'business'),
		('Nadezhda', 'Chaplinskaya', 'Vasilevna', '9184591402', '�048��', 'skoda', 'black', 2018, 'comfort'),
		('Alexey', 'Komlev', 'Alexeyevich', '9149024567', '�533��', 'renault', 'silver', 2014, 'economy'),
		('Irina', 'Vankina', 'Nikolaevna', '9647245602', '�190��', 'mitsubishi', 'gray', 2013, 'economy')
GO

-- ���������� ������� ������� (����� ���������)
DECLARE @time DATETIME
--(order_time, street, build, luggage, cost, payment_method, car_class, fk_client_id, fk_driver_id)
SET @time = CURRENT_TIMESTAMP
EXEC suitable_car @time, 'Street_1', 1, 1, 500, 1, 'economy', 1
SET @time = CURRENT_TIMESTAMP
EXEC suitable_car @time, 'Street_2', 42, 1, 1600, 0, 'business', 2
SET @time = CURRENT_TIMESTAMP
EXEC suitable_car @time, 'Street_3', 13, 0, 800, 1, 'economy', 3
SET @time = CURRENT_TIMESTAMP
EXEC suitable_car @time, 'Street_4', 29, 1, 1400, 1, 'comfort', 4
SET @time = CURRENT_TIMESTAMP
EXEC suitable_car @time, 'Street_5', 33, 0, 250, 0, 'economy', 5

-- ������� ������� ���, ����, ��� ����
/*
SET @time = CURRENT_TIMESTAMP
EXEC suitable_car @time, 'Street_6', 56, 0, 1000, 0, 'business', 6
*/

--================================================������������==================================================

SELECT * FROM Client_table
SELECT * FROM Sale_table
SELECT * FROM Driver_table
SELECT * FROM Auto_table
SELECT * FROM Order_table
GO


--===============================================������ �������=================================================

-- ������� ���������� ���������� �������� ������� ������
SELECT COUNT(DISTINCT current_sale) AS count_distinct_sale FROM Sale_table
GO

-- ���������� null-������
SET ANSI_NULLS ON
SELECT * FROM Order_table WHERE comment IS NULL
GO

-- ����� ����������� �� ���� �������
SELECT * FROM Auto_table
ORDER BY year_of_issue ASC
GO

-- ����� ������� ��������� ������ ��� ������� ������ ���������� (���� ����� ���� ���������� ������ 1500)
SELECT AVG(cost) as online_money_by_car_class
FROM Order_table
GROUP BY car_class
HAVING SUM(cost) >= 1500
GO


-- ����� ���������� � ������, �������, �������� � ���� (LEFT JOIN)
SELECT * FROM Full_order_view
GO


--=============================================��������, ���������==============================================

-- ���� ��������� ������
DELETE FROM Order_Driver_view WHERE fk_driver_id in (1, 2, 5)
GO

-- ������� ��������
--DELETE FROM Driver_table WHERE telephone_number LIKE '914%'
--GO
-- ������� ����
--DELETE FROM Auto_table WHERE year_of_issue < 2015
--GO

-- ����������� ������ ���, � ���� ������������� ����� ����� 6 �������
UPDATE Sale_table SET current_sale = current_sale + 2 
	WHERE validity BETWEEN CONVERT(date, CURRENT_TIMESTAMP) AND CONVERT(date, DATEADD(month, 6, CURRENT_TIMESTAMP ))
go
--================================================������������==================================================

SELECT * FROM Sale_table
SELECT * FROM Driver_table
SELECT * FROM Auto_table
SELECT * FROM Order_table
GO









--================================================���==================================================


-- �������� ������������� �� ������ ����� �������
/*
CREATE VIEW Order_view AS  
SELECT ot.street, ot.build, ot.luggage, ot.cost, ot.payment_method, ot.car_class,
		ct.cl_first_name, ct.cl_last_name, ct.cl_patronymic,
		dt.first_name, dt.last_name, dt.patronymic, dt.telephone_number
FROM Order_table ot, Client_table ct, Driver_table dt
WHERE dt.id_driver = ot.fk_driver_id AND ct.id_client = ot.fk_client_id
GO


-- �������� ������������� �� ������ ������� ������

CREATE VIEW Client_Sale_view AS
SELECT cl.id_client, cl.cl_first_name, cl.cl_last_name, 
	sl.validity, sl.current_sale
FROM Client_table cl INNER JOIN Sale_table sl
	ON cl.id_client = sl.id_name
GO



-- �������� ������������� �� ������ ������ ������, �����, ��������
CREATE VIEW Order_view AS
	SELECT ct.cl_first_name as cl_first_name, ct.cl_last_name as cl_last_name, 
			ct.cl_patronymic as cl_patronymic,
		   ot.order_time as order_time, ot.street as street, ot.build as build, 
			ot.cost as cost, ot.payment_method as payment_method,
		   dt.first_name as dr_first_name, dt.last_name as dr_last_name, 
			dt.patronymic as dr_patronymic, dt.telephone_number as dr_telephone_number
	FROM Client_table as ct
	INNER JOIN Order_table as ot ON ot.fk_client_id = ct.id_client
	INNER JOIN Driver_table as dt ON dt.id_driver = ot.fk_driver_id
GO

-- ���������� ������� ���������

INSERT Driver_table(id_driver, first_name, last_name, patronymic, telephone_number, status_drive)
VALUES (NEXT VALUE FOR count_by, 'Andrew', 'Tkachenko', 'Alexandrovich', '9147856723', 1),
		(NEXT VALUE FOR count_by, 'Daniil', 'Devyatkin', 'Dmitrievich', '9993097439', 0),
		(NEXT VALUE FOR count_by, 'Anastasia', 'Piskunova', 'Eduardovna', '9147853402', 1),
		(NEXT VALUE FOR count_by, 'Koreshkov', 'Vasily', 'Romanovich', '9641592385', 0)

-- ���������� ������� �����������
INSERT INTO Auto_table(state_number, brand, color, year_of_issue, car_class, driver_id)
VALUES ('�674��', 'toyota', 'white', 2016, 'comfort', 1),
		('�239��', 'kia', 'green', 2014, 'economy', 2),
		('�982��', 'volkswagen', 'gray', 2015, 'economy', 3),
		('�712��', 'audi', 'black', 2017, 'business', 4)
GO

-- ���������� ������� �������
INSERT INTO Order_table(order_time, street, build, luggage, cost, payment_method, car_class, fk_client_id, fk_driver_id)
VALUES(CURRENT_TIMESTAMP, 'Street_1', '1', 1, 500, 1, 'economy', 1, dbo.suitable_car('economy')),
		(CURRENT_TIMESTAMP, 'Street_2', '42', 1, 600, 0, 'economy', 2, dbo.suitable_car('economy')),
		(CURRENT_TIMESTAMP, 'Street_3', '13', 0, 800, 1, 'comfort', 3, dbo.suitable_car('comfort'))
GO


-- �������� �� �������
IF OBJECT_ID(N'dbo.suitable_car') IS NOT NULL
	DROP FUNCTION dbo.suitable_car;
GO

-- �������� ���������������� �������
CREATE FUNCTION dbo.suitable_car(@car_class nvarchar(20))
	RETURNS int
	WITH EXECUTE AS CALLER
	AS BEGIN
		declare @suitable_driver int
		-- �������� id ��������� ��������� � ���������� ������� �����������
		SELECT TOP(1) @suitable_driver = dt.id_driver 
			FROM Auto_table au INNER JOIN Driver_table dt
			ON au.driver_id = dt.id_driver
			WHERE dt.status_drive = 0 AND au.car_class = @car_class
			ORDER BY (SELECT new_id FROM get_newID)
		RETURN @suitable_driver
	END
GO
*/