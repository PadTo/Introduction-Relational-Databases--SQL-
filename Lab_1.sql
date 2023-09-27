-- Create Sequence
CREATE SEQUENCE my_seq 
START WITH 1 
MINVALUE 1 
MAXVALUE 99999
INCREMENT BY 1 
CACHE 20;

-- Create Product Group Table
CREATE TABLE PROD_GROUP 
(
    group_id   VARCHAR2(15) CONSTRAINT PK_Group_ID PRIMARY KEY,
    group_name VARCHAR2(50) NOT NULL
);

-- Create Customer Table
CREATE TABLE CUSTOMER 
(
    cust_id     VARCHAR2(15) CONSTRAINT PK_Customer_ID PRIMARY KEY,
    username    VARCHAR2(30) NOT NULL CONSTRAINT UQ_Username UNIQUE,
    passwd      VARCHAR2(30) NOT NULL,
    first_name  VARCHAR2(50) NOT NULL,
    last_name   VARCHAR2(50) NOT NULL,
    credit_type VARCHAR2(15) NOT NULL CHECK(credit_type IN ('high','average','low')),
    phone       VARCHAR2(15)
);

-- Create Product Table
CREATE TABLE PRODUCT 
(
    prod_id   VARCHAR2(15)  CONSTRAINT PK_Product_ID PRIMARY KEY,
    group_id  VARCHAR2(15)  CONSTRAINT FK_Group_ID REFERENCES PROD_GROUP(group_id),
    prod_name VARCHAR2(100) NOT NULL,
    price NUMBER(10, 2)     NOT NULL
);

-- Create Product Picture Table
CREATE TABLE PROD_PICT 
(
    pict_id   VARCHAR2(15)  CONSTRAINT PK_Picture_ID PRIMARY KEY,
    prod_id   VARCHAR2(15)  CONSTRAINT FK_Picture_Product_ID REFERENCES PRODUCT(prod_id),
    file_type VARCHAR2(15)  NOT NULL CHECK (file_type IN ('gif', 'jpg')),
    width     NUMBER(5)     NOT NULL,
    height    NUMBER(5)     NOT NULL,
    path      VARCHAR2(255) NOT NULL
);

-- Create Customer Order Table
CREATE TABLE CUST_ORDER
(
    ord_id      VARCHAR2(30) CONSTRAINT PK_Order_ID PRIMARY KEY, 
    cust_id     VARCHAR2(30) NOT NULL CONSTRAINT FK_Customer_ID REFERENCES CUSTOMER(cust_id),
    order_date  DATE
);

ALTER TABLE CUST_ORDER
    MODIFY ord_id DEFAULT 'ORD' || LPAD(my_seq.NEXTVAL,5,'0');
ALTER TABLE CUST_ORDER
    MODIFY order_date DEFAULT SYSDATE;

-- Create Cart Table
CREATE TABLE CART 
(
    row_id   VARCHAR2(30) CONSTRAINT PK_Row_ID PRIMARY KEY,
    ord_id   VARCHAR2(30) NOT NULL CONSTRAINT FK_Cart_Order_ID REFERENCES CUST_ORDER(ord_id),
    prod_id  VARCHAR2(30) NOT NULL CONSTRAINT FK_Product_ID REFERENCES PRODUCT(prod_id),
    quantity NUMBER(16) NOT NULL
);

ALTER TABLE CART
    MODIFY row_id DEFAULT 'ROW' || LPAD(my_seq.NEXTVAL,5,'0');



-- Inserting 3 DATA Rows Into CUSTOMER Tables --
INSERT INTO CUSTOMER (cust_id, username, passwd, first_name, last_name, credit_type, phone)
VALUES ('CUST1', 'user1', 'password1', 'John', 'Doe', 'high', '555-123-4567');

INSERT INTO CUSTOMER (cust_id, username, passwd, first_name, last_name, credit_type, phone)
VALUES ('CUST2', 'user2', 'password2', 'Jane', 'Smith', 'average', '555-987-6543');

INSERT INTO CUSTOMER (cust_id, username, passwd, first_name, last_name, credit_type, phone)
VALUES ('CUST3', 'user3', 'password3', 'Bob', 'Johnson', 'low', '555-789-1234');


-- Inserting 2 DATA Rows Into PROD_GROUP Table --
INSERT INTO PROD_GROUP (group_id,group_name)
VALUES ('groupID1','group1');

INSERT INTO PROD_GROUP (group_id,group_name)
VALUES ('groupID2','group2');


--Inserting Two DATA Rows Into PRODUCT Able --
INSERT INTO PRODUCT (prod_id,group_id,prod_name,price)
VALUES ('prod1','groupID1','Product 1',19.99);

--Inserting Two DATA Rows Into PRODUCT Able --
INSERT INTO PRODUCT (prod_id,group_id,prod_name,price)
VALUES ('prod2','groupID2','Product 2',1.99);



--Performing a Sale--
DECLARE
    v_ord_id VARCHAR2(30);
BEGIN
    -- Generate the order ID using the sequence
    SELECT 'ORD' || LPAD(my_seq.NEXTVAL, 5, '0') INTO v_ord_id FROM DUAL;

    -- Insert the order with the generated order ID
    INSERT INTO CUST_ORDER(ord_id, cust_id, order_date)
    VALUES (v_ord_id, 'CUST1', SYSDATE);
    
    -- Insert items into the cart with the same order ID
    INSERT INTO CART(row_id, ord_id, prod_id, quantity)
    VALUES ('ROW' || LPAD(my_seq.NEXTVAL, 5, '0'), v_ord_id, 'prod1', 2);

    INSERT INTO CART(row_id, ord_id, prod_id, quantity)
    VALUES ('ROW' || LPAD(my_seq.NEXTVAL, 5, '0'), v_ord_id, 'prod2', 1);
    
    -- Commit the transaction
    COMMIT;
END;