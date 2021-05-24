
-------------------------------------------------------------------------------------------------------------------------------
------------------ Exercise 1: Report the daily total amount of direct_deposit per user for the past 30 days ------------------
---- Key Assumption 1: The timestamp is in UTC (no need to convert to a different timezone)                  ------------------
---- Key Assumption 2: Users don't transaction on each day, so we need to have a calendar table to produce a daily view that
----                   include all calendar dates over the past 30 days                                      ------------------
---- Key Assumption 3: The funding_type is a string field
-------------------------------------------------------------------------------------------------------------------------------

-- Step One: potentially create a calendar_table with if there is not a system calendar table

-- Step Two: Summarize the daily "direct_deposit" total over calendar days over the past 30 days

-- create a global reference table to easily adjust the tracking window
with global_time_reference as (
select dateadd(day, -30, getdate())::date as starting_date,
),

-- join the calendar table to create a per calendar day view
cte_calendar_daily_summary as (
select c.calendar_date::date,
       dr.user_id,
       sum(case when dr.funding_type = 'direct_deposit' then dr.amount else null end) as daily_amount
  from funding_transactions dr
  left join calendar_table c
  on c.calendar_date :: date >= (select starting_date from global_time_reference)
  where dr.timestamp :: date >= (select starting_date from global_time_reference)
  group by 1,2)

select * from cte_calendar_daily_summary

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-------Exercise 2: Identify the id, timestamp, and amount of the first ever cash_deposit for all users, null if never had a cash_deposit ------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------

with cte_first_cash_deposit as (
select id,
       timestamp,
       amount,
       row_number () over (partition by id order by timestamp asc) as rnk_ord
  from funding_transactions
  where funding_type = 'cash_deposit'
)

select * from cte_first_cash_deposit where rnk_ord = 1







