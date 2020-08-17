-- Assignment - Stock Market Analysis

-- Create Schema  
create schema Assignment;

-- Use the Schema 
use Assignment;

-- Get number of records for each of the 6 stocks 
select count(*) from bajaj;
select count(*) from tcs;
select count(*) from tvs;
select count(*) from infosys;
select count(*) from eicher;
select count(*) from hero;

-- Check imported table's structure, i.e, no of columns, name and type 
desc bajaj;
desc tcs;
desc tvs;
desc infosys;
desc eicher;
desc hero;

-- Part 1. Create a new table named 'bajaj1' containing the date, close price, 20 Day MA and 50 Day MA. 
-- (This has to be done for all 6 stocks)

	-- Creating 20 Day and 50 Day moving average of Close price for all the 6 stocks 
	-- Using Common Table Expressions (CTE)

-- Table 1. MA for BAJAJ AUTO
create table bajaj1
	with bajaj_cte as 
    (
		select str_to_date(Date, '%d-%M-%Y') as Date,
			   `Close Price`
        from bajaj       
    ) select *,
		if(row_number() over w > 19, avg(`Close Price`) over (order by Date rows 19 preceding),
			null) as '20 Day MA',
        if(row_number() over w > 49, avg(`Close Price`) over (order by Date rows 49 preceding),
			null) as '50 Day MA'
	  from bajaj_cte
	  window w as (order by Date);
      
-- Table 2. MA for TCS 
create table tcs1
	with tcs_cte as 
    (
		select str_to_date(Date, '%d-%M-%Y') as Date,
			   `Close Price`
        from tcs       
    ) select *,
		if(row_number() over w > 19, avg(`Close Price`) over (order by Date rows 19 preceding),
			null) as '20 Day MA',
        if(row_number() over w > 49, avg(`Close Price`) over (order by Date rows 49 preceding),
			null) as '50 Day MA'
	  from tcs_cte
	  window w as (order by Date); 
      
-- Table 3. MA for TVS Motors
create table tvs1
	with tvs_cte as 
    (
		select str_to_date(Date, '%d-%M-%Y') as Date,
			   `Close Price`
        from tvs       
    ) select *,
		if(row_number() over w > 19, avg(`Close Price`) over (order by Date rows 19 preceding),
			null) as '20 Day MA',
        if(row_number() over w > 49, avg(`Close Price`) over (order by Date rows 49 preceding),
			null) as '50 Day MA'
	  from tvs_cte
	  window w as (order by Date);
      
-- Table 4. MA for Infosys 
create table infosys1
	with infosys_cte as 
    (
		select str_to_date(Date, '%d-%M-%Y') as Date,
			   `Close Price`
        from infosys       
    ) select *,
		if(row_number() over w > 19, avg(`Close Price`) over (order by Date rows 19 preceding),
			null) as '20 Day MA',
        if(row_number() over w > 49, avg(`Close Price`) over (order by Date rows 49 preceding),
			null) as '50 Day MA'
	  from infosys_cte
	  window w as (order by Date);
      
-- Table 5. MA for Eicher Motors 
create table eicher1
	with eicher_cte as 
    (
		select str_to_date(Date, '%d-%M-%Y') as Date,
			   `Close Price`
        from eicher      
    ) select *,
		if(row_number() over w > 19, avg(`Close Price`) over (order by Date rows 19 preceding),
			null) as '20 Day MA',
        if(row_number() over w > 49, avg(`Close Price`) over (order by Date rows 49 preceding),
			null) as '50 Day MA'
	  from eicher_cte
	  window w as (order by Date);
      
-- Table 6. MA for Hero Motocorp 
create table hero1
	with hero_cte as 
    (
		select str_to_date(Date, '%d-%M-%Y') as Date,
			   `Close Price`
        from hero       
    ) select *,
		if(row_number() over w > 19, avg(`Close Price`) over (order by Date rows 19 preceding),
			null) as '20 Day MA',
        if(row_number() over w > 49, avg(`Close Price`) over (order by Date rows 49 preceding),
			null) as '50 Day MA'
	  from hero_cte
	  window w as (order by Date);      
      
-- Check structure of the derived tables with Moving Averages
desc bajaj1;
desc tcs1;
desc tvs1;
desc infosys1;
desc eicher1;
desc hero1;
      
-- Check the data in the newly created table       
Select * from bajaj1 limit 100;
Select * from tcs1 limit 100;
Select * from tvs1 limit 100;
Select * from infosys1 limit 100;
Select * from eicher1 limit 100;
Select * from hero1 limit 100;
 
-- Part 2. Create a master table containing the date and close price of all the six stocks. 
-- (Column header for the price is the name of the stock) 

	-- Creating master table containing Close Price and Dates of all 6 stocks
create table stock_master
(
	SELECT 
		b.Date AS Date,
		b.`Close Price` AS Bajaj,
		tc.`Close Price` AS TCS,
		tv.`Close Price` AS TVS,
		i.`Close Price` AS Infosys,
		e.`Close Price` AS Eicher,
		h.`Close Price` AS Hero
	FROM bajaj1 b 
		INNER JOIN	tcs1 tc USING (Date)
		INNER JOIN tvs1 tv USING (Date)
		INNER JOIN infosys1 i USING (Date)
		INNER JOIN eicher1 e USING (Date)
		INNER JOIN hero1 h USING (Date)    
);

-- Check structure of the master table
desc stock_master;

-- Check number of records
select count(*) from stock_master;

-- Check data in master table
select * from stock_master limit 100;

-- Part 3. Use the table created in Part(1) to generate buy and sell signal. 
-- Store this in another table named 'bajaj2'. 
-- Perform this operation for all stocks.

	-- Creating tables to store the signal for all the 6 stocks
    -- Using CTE and lag method to generate signals
    -- Logic to genrate signals: 
			-- When 20 DAY MA crosses above the 50 Day MA, then 'BUY'
            -- When 20 DAY MA crosses below the 50 Day MA, then 'SELL'
            -- 'HOLD' for other cases.
            -- create lags for 20 DAY MA and 50 DAY 50
            -- compare current values of 20 with 50 MA, and previous 20 with 50 MA

-- Table 1: BAJAJ with Signals
create table bajaj2
(    
	with bajaj1_cte as 
	(
		select *,
			lag(`20 Day MA`, 1) over w as '20 Day MA Prev',
			lag(`50 Day MA`, 1) over w as '50 Day MA Prev'
			from bajaj1
			window w as (order by Date)
	) select 
		  Date, `Close Price`,
		  (case
			when `20 Day MA` > `50 Day MA` and `20 Day MA Prev` < `50 Day MA Prev` then 'BUY'
			when `20 Day MA` < `50 Day MA` and `20 Day MA Prev` > `50 Day MA Prev` then 'SELL'
			else 'HOLD'
		  end) as 'Signal'
	  from bajaj1_cte
  );
  
-- Table 2: TCS with Signals
create table tcs2
(    
	with tcs1_cte as 
	(
		select *,
			lag(`20 Day MA`, 1) over w as '20 Day MA Prev',
			lag(`50 Day MA`, 1) over w as '50 Day MA Prev'
			from tcs1
			window w as (order by Date)
	) select 
		  Date, `Close Price`,
		  (case
			when `20 Day MA` > `50 Day MA` and `20 Day MA Prev` < `50 Day MA Prev` then 'BUY'
			when `20 Day MA` < `50 Day MA` and `20 Day MA Prev` > `50 Day MA Prev` then 'SELL'
			else 'HOLD'
		  end) as 'Signal'
	  from tcs1_cte
  ); 
  
-- Table 3: TVS MOTORS with Signals
create table tvs2
(    
	with tvs1_cte as 
	(
		select *,
			lag(`20 Day MA`, 1) over w as '20 Day MA Prev',
			lag(`50 Day MA`, 1) over w as '50 Day MA Prev'
			from tvs1
			window w as (order by Date)
	) select 
		  Date, `Close Price`,
		  (case
			when `20 Day MA` > `50 Day MA` and `20 Day MA Prev` < `50 Day MA Prev` then 'BUY'
			when `20 Day MA` < `50 Day MA` and `20 Day MA Prev` > `50 Day MA Prev` then 'SELL'
			else 'HOLD'
		  end) as 'Signal'
	  from tvs1_cte
  );  
  
-- Table 4: INFOSYS with Signals
create table infosys2
(    
	with infosys1_cte as 
	(
		select *,
			lag(`20 Day MA`, 1) over w as '20 Day MA Prev',
			lag(`50 Day MA`, 1) over w as '50 Day MA Prev'
			from infosys1
			window w as (order by Date)
	) select 
		  Date, `Close Price`,
		  (case
			when `20 Day MA` > `50 Day MA` and `20 Day MA Prev` < `50 Day MA Prev` then 'BUY'
			when `20 Day MA` < `50 Day MA` and `20 Day MA Prev` > `50 Day MA Prev` then 'SELL'
			else 'HOLD'
		  end) as 'Signal'
	  from infosys1_cte
  );
  
-- Table 5: EICHER MOTORS with Signals
create table eicher2
(    
	with eicher1_cte as 
	(
		select *,
			lag(`20 Day MA`, 1) over w as '20 Day MA Prev',
			lag(`50 Day MA`, 1) over w as '50 Day MA Prev'
			from eicher1
			window w as (order by Date)
	) select 
		  Date, `Close Price`,
		  (case
			when `20 Day MA` > `50 Day MA` and `20 Day MA Prev` < `50 Day MA Prev` then 'BUY'
			when `20 Day MA` < `50 Day MA` and `20 Day MA Prev` > `50 Day MA Prev` then 'SELL'
			else 'HOLD'
		  end) as 'Signal'
	  from eicher1_cte
  );
  
-- Table 6: HERO MOTOCORP with Signals
create table hero2
(    
	with hero1_cte as 
	(
		select *,
			lag(`20 Day MA`, 1) over w as '20 Day MA Prev',
			lag(`50 Day MA`, 1) over w as '50 Day MA Prev'
			from hero1
			window w as (order by Date)
	) select 
		  Date, `Close Price`,
		  (case
			when `20 Day MA` > `50 Day MA` and `20 Day MA Prev` < `50 Day MA Prev` then 'BUY'
			when `20 Day MA` < `50 Day MA` and `20 Day MA Prev` > `50 Day MA Prev` then 'SELL'
			else 'HOLD'
		  end) as 'Signal'
	  from hero1_cte
  );
  
  
-- Check structure of the signal tables
desc bajaj2;
desc tcs2;
desc tvs2;
desc infosys2;
desc eicher2;
desc hero2;
      
-- Check the data in the newly created table       
Select * from bajaj2 limit 400;
Select * from tcs2 limit 400;
Select * from tvs2 limit 400;
Select * from infosys2 limit 400;
Select * from eicher2 limit 400;
Select * from hero2 limit 400;

-- Part 4: Create a User defined function, that takes the date as input and 
-- returns the signal for that particular day (Buy/Sell/Hold) for the Bajaj stock.

delimiter $$

create function getSignal(input_date varchar(25))
returns varchar(4) deterministic

begin
	declare signal_result varchar(4);
    select `Signal` from bajaj2
    where Date = str_to_date(input_date, '%d-%M-%Y') into signal_result;
    return signal_result;
end $$

delimiter ;

-- Call user defined function
select getSignal('24-August-2015') as `Signal`; -- SELL
select getSignal('24-Aug-2015') as `Signal`; -- SELL
select getSignal('01-Jan-2015') as `Signal`; -- HOLD
select getSignal('18-May-2015') as `Signal`; -- BUY

-- 5. Write a brief summary of the results obtained and what inferences you can draw from the analysis performed. 
-- (Less than 250 words to be submitted in a pdf file)

-- Min and Max close Price for all the stocks along with their dates
create table Min_Max_Stock
(
select Date, 
	bajaj, rank() over (order by bajaj) as bajaj_rank,
	tcs, rank() over (order by tcs) as tcs_rank,
    tvs, rank() over (order by tvs) as tvs_rank,
    infosys, rank() over (order by infosys) as infosys_rank,
    eicher, rank() over (order by eicher) as eicher_rank,
    hero, rank() over (order by hero) as hero_rank
	from stock_master
); 

-- Select Min and Max of Bajaj Stock
select Date, Bajaj, bajaj_rank 
from Min_Max_Stock
where bajaj_rank = 1 or bajaj_rank = (select count(*) from Min_Max_Stock)
order by bajaj_rank;

-- Select Min and Max of TCS Stock
select Date, Tcs, tcs_rank 
from Min_Max_Stock
where tcs_rank = 1 or tcs_rank = (select count(*) from Min_Max_Stock)
order by tcs_rank;

-- Select Min and Max of TVS Stock
select Date, Tvs, tvs_rank 
from Min_Max_Stock
where tvs_rank = 1 or tvs_rank = (select count(*) from Min_Max_Stock)
order by tvs_rank;

-- Select Min and Max of Infosys Stock
select Date, Infosys, infosys_rank 
from Min_Max_Stock
where infosys_rank = 1 or infosys_rank = (select count(*) from Min_Max_Stock)
order by infosys_rank;

-- Select Min and Max of Eicher Stock
select Date, Eicher, eicher_rank 
from Min_Max_Stock
where eicher_rank = 1 or eicher_rank = (select count(*) from Min_Max_Stock)
order by eicher_rank;

-- Select Min and Max of Hero Stock
select Date, Hero, hero_rank 
from Min_Max_Stock
where hero_rank = 1 or hero_rank = (select count(*) from Min_Max_Stock)
order by hero_rank;

-- Select least and the greatest value of Close price amongst all the 6 stocks
select least(min(Bajaj), min(tcs), min(tvs), min(infosys), min(eicher), min(hero)) as least_close_price
from stock_master;

select greatest(max(Bajaj), max(tcs), max(tvs), max(infosys), max(eicher), max(hero)) as least_close_price
from stock_master;

-- Count number of HOLD, BUY and SELL for all the 6 stocks
create view bajaj_signal as
(
	(select `Signal`,count(*) as Bajaj_Count
	 from bajaj2 where `Signal` = 'HOLD')
	 union
	(select `Signal`, count(*) as Bajaj_Count
	 from bajaj2 where `Signal` = 'BUY')
     union
	(select `Signal`, count(*) as Bajaj_Count
	 from bajaj2 where `Signal` = 'SELL')
);
create view tcs_signal as
(
	(select `Signal`,count(*) as Tcs_Count
	 from tcs2 where `Signal` = 'HOLD')
     union
	(select `Signal`, count(*) as Tcs_Count
	 from tcs2 where `Signal` = 'BUY')
	 union
	(select `Signal`, count(*) as Tcs_Count
	 from tcs2 where `Signal` = 'SELL')
);
create view tvs_signal as
(
	(select `Signal`,count(*) as Tvs_Count
	 from tvs2 where `Signal` = 'HOLD')
     union
	(select `Signal`, count(*) as Tvs_Count
	 from tvs2 where `Signal` = 'BUY')
	 union
	(select `Signal`, count(*) as Tvs_Count
	 from tvs2 where `Signal` = 'SELL')
);
create view infosys_signal as
(
	(select `Signal`,count(*) as infosys_Count
	 from infosys2 where `Signal` = 'HOLD')
     union
	(select `Signal`, count(*) as infosys_Count
	 from infosys2 where `Signal` = 'BUY')
	 union
	(select `Signal`, count(*) as infosys_Count
	 from infosys2 where `Signal` = 'SELL')
);
create view eicher_signal as
(
	(select `Signal`,count(*) as eicher_Count
	 from eicher2 where `Signal` = 'HOLD')
     union
	(select `Signal`, count(*) as eicher_Count
	 from eicher2 where `Signal` = 'BUY')
	 union
	(select `Signal`, count(*) as eicher_Count
	 from eicher2 where `Signal` = 'SELL')
);
create view hero_signal as
(
	(select `Signal`,count(*) as hero_Count
	 from hero2 where `Signal` = 'HOLD')
     union
	(select `Signal`, count(*) as hero_Count
	 from hero2 where `Signal` = 'BUY')
	 union
	(select `Signal`, count(*) as hero_Count
	 from hero2 where `Signal` = 'SELL')
);

create view signal_master as
(
	SELECT 
		b.`Signal`, bajaj_count, tcs_count, tvs_count, infosys_count, eicher_count, hero_count
	FROM
		bajaj_signal b INNER JOIN 
		tcs_signal tc USING (`Signal`) inner join
		tvs_signal tv USING (`Signal`) inner join
		infosys_signal i USING (`Signal`) inner join
		eicher_signal e USING (`Signal`) inner join
		hero_signal h USING (`Signal`)
);   

select * from signal_master; 
    
-- Select total number of each signal amongst all the 6 stocks
select sum(bajaj_count + tcs_count + tvs_count + infosys_count + eicher_count + hero_count) as Total_Hold
from signal_master where `Signal` = 'HOLD';

select sum(bajaj_count + tcs_count + tvs_count + infosys_count + eicher_count + hero_count) as Total_Buy
from signal_master where `Signal` = 'BUY';

select sum(bajaj_count + tcs_count + tvs_count + infosys_count + eicher_count + hero_count) as Total_Sell
from signal_master where `Signal` = 'SELL';

-- TCS stocks were bought and sold the most
-- Year, month and day in which most number of Stocks were bought and sold for TCS

select year(Date) as signal_year, `Signal`,count(*) as tcs_Count
from tcs2 where `Signal` = 'BUY'
group by signal_year
order by tcs_count desc;

select month(Date) as signal_month, `Signal`,count(*) as tcs_Count
from tcs2 where `Signal` = 'BUY'
group by signal_month
order by tcs_count desc;

select day(Date) as signal_day, `Signal`,count(*) as tcs_Count
from tcs2 where `Signal` = 'BUY'
group by signal_day
order by tcs_count desc;

select year(Date) as signal_year, `Signal`,count(*) as tcs_Count
from tcs2 where `Signal` = 'SELL'
group by signal_year
order by tcs_count desc;

select month(Date) as signal_month, `Signal`,count(*) as tcs_Count
from tcs2 where `Signal` = 'SELL'
group by signal_month
order by tcs_count desc;

select day(Date) as signal_day, `Signal`,count(*) as tcs_Count
from tcs2 where `Signal` = 'SELL'
group by signal_day
order by tcs_count desc;


        
        
     







