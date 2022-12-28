

use database demo_database;


--1. Load the given dataset into snowflake with a primary key to Order Date column.
create or replace table sales(
    order_id varchar(150),	
    order_date date NOT NULL PRIMARY KEY,  --1 .SET PRIMARY KEY.
    ship_date date,
    ship_mode varchar(50),
    customer_name varchar(100),	
    segment	varchar(50),
    state varchar(50),
    country	varchar(50),	
    market varchar(50),
    region varchar(50),
    product_id	varchar(50),
    category varchar(50),	
    sub_category varchar(50),	
    product_name varchar(200),	
    sales number(38),	
    quantity int,	
     discount decimal(38),	 
     profit decimal(38),	
     shipping_cost decimal(38),	
     order_priority varchar(50),
    year int
    );


--check datatypes
describe table sales;

--after loading the data check if data was inserted
select * from sales;


 --2. CHECK THE ORDER DATE AND SHIP DATE TYPE AND THINK IN WHICH DATA TYPE YOU HAVE TO CHANGE
 
 --drop primary key from order date
 alter table sales
drop primary key;

--check structure
describe table sales;
 
 --modify order id to primary key
 alter table sales
add primary key  (order_id);


 --check structure was changed for order id to primary key
 describe table sales;
 
 --3. Check the data type for Order date and Ship date and mention in what data type it should be?
 --Order date and Ship date already set in the create table and the csv file was cleanup to the correct format in Snowflake "yyyy-mm-dd"

--create a copy of the sales data
create OR REPLACE table sales_copy as
      select *
      from sales;

--check that data was copied fom sales data
select * from sales_copy;



--4. Create a new column called order_extract and extract the number after the last ‘–‘from Order ID column.


--create a new column to store the data after the '-'
alter table sales_copy add new_order_id varchar(150);

--check data structure after creation of new col
describe table sales_copy;

--check from data after '-'
select SUBSTRING(order_id,9) from sales_copy;


--check the second occurence of the '-' in the order_id col
select CHARINDEX('-',order_id,4) from sales_copy;


--check data before updating the new_order_id col
select order_id, new_order_id from sales_copy;

--update the new col created- new_order_id after the second occurrence is found then update with string from the 9th postion
UPDATE sales_copy
SET new_order_id = CASE WHEN CHARINDEX('-',order_id,4)=8 then SUBSTRING(order_id,9) else NULL END;

--check data after update
select order_id, new_order_id from sales_copy;

--5. Create a new column called Discount Flag and categorize it based on discount. Use ‘Yes’ if the discount is greater than zero else ‘No’..

--create a new column to store the data for discount
alter table sales_copy add discount_status varchar(5);

--check data structure after creation of new col
describe table sales_copy;

--check the validity of the discount status before
create or replace view sa_discount_status_view as
    select *, 
            case
                when discount>0  then 'YES'
                else 'FALSE'
            end as discount_status_col
    from sales_copy;
    
--check data from the view and check validity 
select * from sa_discount_status_view;

--update discount status 
update sales_copy
    set discount_status=case
        when discount>0  then 'YES'
        else 'NO'
    end;

--check data in discount status col
select discount_status from sales_copy;

--6. Create a new column called process days and calculate how many days it takes for each order id to process from the order to its shipment.


--check the date difference between order date and ship date
SELECT order_date,ship_date,DATEDIFF(day,order_date,ship_date ) from sales_copy;  


--create a new column to store the data for discount
alter table sales_copy add days_processed varchar(10);


--check data structure after creation of new col
describe table sales_copy;

--update days_processed
update sales_copy
set days_processed=DATEDIFF(day,order_date,ship_date );


--check data in days_processed col
select order_date,ship_date, days_processed from sales_copy;
select * from sales_copy;

--7 Create a new column called Rating and then based on the Process dates give rating like given below.
--a. If process days less than or equal to 3days then rating should be 5
--b. If process days are greater than 3 and less than or equal to 6 then rating should be 4
--c. If process days are greater than 6 and less than or equal to 10 then rating should be 3
--d. If process days are greater than 10 then the rating should be 2.

--check case statement for ratings
 select days_processed,
    case
        when days_processed <=3 then '5'
        when days_processed >3 and days_processed <= 6 then '4'
        when days_processed >6 and days_processed <= 10 then '3'
        else '2'
     end as days_processed_rating_test
 from sales_copy;
 
 --create a new column to store the data for days_processed_rating
 alter table sales_copy add days_processed_rating varchar(2);


--check data structure after creation of new col
describe table sales_copy;

--update days_processed_rating
update sales_copy
    set days_processed_rating= case
        when days_processed <=3 then '5'
        when days_processed >3 and days_processed <= 6 then '4'
        when days_processed >6 and days_processed <= 10 then '3'
        else '2'
    end;
     


--check data in days_processed_rating col
select  days_processed,days_processed_rating from sales_copy;







