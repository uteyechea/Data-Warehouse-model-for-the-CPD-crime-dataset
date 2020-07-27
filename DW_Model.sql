create database dwRadar
use dwRadar

/* Dimension No 1: time */
declare @start_dt as date = '1/1/2015';		-- Date from which the calendar table will be created.
declare @end_dt as date = '1/1/2021';		-- Calendar table will be created up to this date (not including).

create table dim_time(
 pk_time_id int primary key identity(1,1),
 date_year smallint,
 date_month tinyint,
 date_day tinyint,
 quarter_id tinyint
)
while @start_dt < @end_dt
begin
	insert into dim_time(date_year, date_month, date_day, quarter_id)	
	values( year(@start_dt), month(@start_dt), day(@start_dt), datepart(quarter, @start_dt) )
	set @start_dt = dateadd(day, 1, @start_dt)
end

--Was the insertion successful?
select * from dim_time order by pk_time_id --SC 2192


--Dimension No.2 : location
create table dim_location(
pk_location_id int primary key identity(1,1),
block varchar(50)
)
insert into dim_location(block)
select distinct block from dbRadar.dbo.chicago_crime_data
--Was the insertion successful?
select * from dim_location order by block desc --SC 31543

--Dimension No. 3: crime primary type
create table dim_crime(
pk_primaryType_id int primary key identity(1,1),
primaryType varchar(50)
)
insert into dim_crime(primaryType)
select distinct Primary_Type from dbRadar.dbo.chicago_crime_data
--Was the insertion successful?
select * from dim_crime order by pk_primaryType_id desc --34


--Dimension No. 4: crime subTypeCrime or crime description
create table dim_crimeDescription(
pk_crimeDescription_id int primary key identity(1,1),
description varchar(100)
)
insert into dim_crimeDescription(description)
select distinct Description from dbRadar.dbo.chicago_crime_data
--Was the insertion successful?
select * from dim_crimeDescription order by pk_crimeDescription_id desc --SC 365


--Dimension No. 5: did the crime happend in a domestic environment?
create table dim_domestic(
pk_domestic_id int primary key identity(1,1),
domestic bit
)
insert into dim_domestic(domestic) values
('true'),
('false')
--Was the insertion successful?
select * from dim_domestic order by pk_domestic_id desc --SC 2



--Dimension No. 6: was the criminal arrested? 
create table dim_arrest(
pk_arrest_id int primary key identity(1,1),
arrest bit
)
insert into dim_arrest(arrest) values
('true'),
('false')
--Was the insertion successful?
select * from dim_arrest order by pk_arrest_id desc --SC 2

--Dimension No. 7: location description. SC = 170
create table dim_locationDescription(
pk_locationDescription_id int primary key identity(1,1),
locationDescription varchar(100)
)
insert into dim_locationDescription 
select distinct  Location_Description from dbRadar.dbo.chicago_crime_data
--Was the insertion successful?
select * from dim_locationDescription order by pk_locationDescription_id desc --SC 170

--Measure No. 1
create table measure_crimeCount(
crimeCount int
)
insert into measure_crimeCount values
(1)


create table fact_chicagoCrime(
fk_time_id int foreign key(fk_time_id) references dim_time(pk_time_id),
fk_location_id int foreign key(fk_time_id) references dim_location(pk_location_id),
fk_locationDescription_id int foreign key(fk_locationDescription_id) references dim_locationDescription(pk_locationDescription_id),
fk_domestic_id int foreign key(fk_domestic_id) references dim_domestic(pk_domestic_id),
fk_crimeDescription_id int foreign key(fk_crimeDescription_id) references dim_crimeDescription(pk_crimeDescription_id),
fk_primaryType_id int foreign key(fk_primaryType_id) references dim_crime(pk_primaryType_id),
fk_arrest_id int foreign key(fk_arrest_id) references dim_arrest(pk_arrest_id),
crimeCount int,
constraint pk_chicagoCrime_id primary key clustered
(fk_time_id,fk_location_id,fk_locationDescription_id,fk_domestic_id,fk_crimeDescription_id,fk_primaryType_id,fk_arrest_id,crimeCount)
)
insert into fact_chicagoCrime
select 
pk_time_id,
pk_location_id,
pk_locationDescription_id,
pk_domestic_id,
pk_crimeDescription_id,
pk_primaryType_id,
pk_arrest_id,
count(crimeCount)

from 
dim_time,
dim_location,
dim_locationDescription,
dim_domestic,
dim_crimeDescription,
dim_crime,
dim_arrest,
measure_crimeCount,
dbRadar.dbo.chicago_crime_data as db

where 
year(db.Date) = dim_time.date_year and month(db.Date)=dim_time.date_month and day(db.Date)=dim_time.date_day and
db.Block=dim_location.block and
db.Location_Description = dim_locationDescription.locationDescription and
db.Domestic = dim_domestic.domestic and
db.Description = dim_crimeDescription.description and
db.Primary_Type = dim_crime.primaryType and
db.Arrest = dim_arrest.arrest

group by 
pk_time_id,
pk_location_id,
pk_locationDescription_id,
pk_domestic_id,
pk_crimeDescription_id,
pk_primaryType_id,
pk_arrest_id



select * from fact_chicagoCrime order by fk_location_id desc --SC 1 038 672
select * from dbRadar.dbo.chicago_crime_data -- SC 1 048 575


/*There is a tiny reduction in the SC from the DB to the DW
If I were not to choose for example dim_locationDescription or dim_location
then the SC of the DW would be substantially reduced as can be proven below
the DW SC would be 212 098.
*/

select 
pk_time_id,
pk_domestic_id,
pk_crimeDescription_id,
pk_primaryType_id,
pk_arrest_id,
count(crimeCount)

from 
dim_time,
dim_domestic,
dim_crimeDescription,
dim_crime,
dim_arrest,
measure_crimeCount,
dbRadar.dbo.chicago_crime_data as db

where 
year(db.Date) = dim_time.date_year and month(db.Date)=dim_time.date_month and day(db.Date)=dim_time.date_day and
db.Domestic = dim_domestic.domestic and
db.Description = dim_crimeDescription.description and
db.Primary_Type = dim_crime.primaryType and
db.Arrest = dim_arrest.arrest

group by 
pk_time_id,
pk_domestic_id,
pk_crimeDescription_id,
pk_primaryType_id,
pk_arrest_id

