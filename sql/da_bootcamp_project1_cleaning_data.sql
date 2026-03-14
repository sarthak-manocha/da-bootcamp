-- Data Analysis Bootcamp
-- Project 1 - Cleaning Data
use world_layoffs;

select *
from layoffs;

-- Objective of this project:
-- 1. Remove duplicates
-- 2. Standardise the data
-- 3. Null values or blank values
-- 4. Remove any columns or rows

create table layoffs_staging
like layoffs;

-- creating a staging table 
-- to avoid amending the raw data
insert layoffs_staging
select * 
from layoffs;

-- 1. Checking for duplicates
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

with duplicates_cte as 
(
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicates_cte
where row_num > 1;

-- data with duplicate values
select *
from layoffs_staging
where company in ('Casper','Cazoo','Hibob','Wildlife Studios','Yahoo')
order by company asc; 

-- creating another staging table
-- to add row_num and use it to delete duplicates
drop table if exists layoffs_staging2;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert layoffs_staging2
select *, 
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

delete 
from layoffs_staging2
where row_num > 1; -- 5 duplicate rows deleted

select *
from layoffs_staging2
where company in ('Casper','Cazoo','Hibob','Wildlife Studios','Yahoo')
order by company asc;

-- 2. Standardising data

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company); -- 11 rows were amended

select distinct(industry)
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%'; -- 3 rows were amended

select distinct(location)
from layoffs_staging2
order by 1; -- all good

select distinct(country)
from layoffs_staging2
order by 1; 

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%'; -- 4 rows were amended

select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2; 

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y')
; -- 2355 rows were amended

alter table layoffs_staging2
modify column `date` date;

-- 3. Null and blank values
select *
from layoffs_staging2
where industry is null 
or industry = ''; 

select *
from layoffs_staging2
where company in ('Airbnb','Bally\'s Interactive','Carvana','Juul')
order by company;

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2
set industry = null
where industry = ''; -- 3 rows were amended

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null; -- 3 rows were amended

select * 
from layoffs_staging2
where company like 'Bally%'; -- can't be amended as we don't have information

-- 4. Remove columns or rows

-- we can't amend columns - total_laid_off, percentage_laid_off and funds_raised_millions
-- as we don't have that information and can likely be retrieved from internet
-- which is outside the scope of this bootcamp
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null; -- 361 rows deleted

alter table layoffs_staging2
drop column row_num; -- removed the row_num column that was added before

select *
from layoffs_staging2;