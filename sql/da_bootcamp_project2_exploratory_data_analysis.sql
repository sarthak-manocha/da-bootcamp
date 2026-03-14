-- Data Analysis Bootcamp
-- Project 2 - Exploratory Data Analysis
use world_layoffs;

-- data overview
select max(total_laid_off), min(total_laid_off), 
max(percentage_laid_off), min(percentage_laid_off),
max(`date`), min(`date`),
max(funds_raised_millions), min(funds_raised_millions)
from layoffs_staging2; 

-- companies which laid off 100% of the staff
-- order by most laid offs
select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc; 

-- total layoffs by companies
-- ordered by highest layoffs
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- checking the layoff periods
select max(`date`), min(`date`)
from layoffs_staging2;

-- total layoffs by industry
-- ordered by highest layoffs
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- total layoffs by country
-- ordered by highest layoffs
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- total layoffs by stage
-- ordered by highest layoffs
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

-- total layoffs timeseries
-- by year
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 2 desc;

-- by month-year
select substring(`date`, 1,7) as `year_month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by `year_month`
order by 1 asc;

-- rolling sum of total layoffs each month
with cte_rolling_total as
(
select substring(`date`, 1,7) as `year_month`, sum(total_laid_off) as sum_total_laid_off
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by `year_month`
order by 1 asc
)
select `year_month`, sum_total_laid_off,
sum(sum_total_laid_off) over (order by `year_month`) as rolling_total
from cte_rolling_total;

-- ranking companies (top 5)
-- with highest layoffs each year
with cte_company_year (company, years, sum_total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
),
company_ranking as
(
select *,
dense_rank() over (partition by years order by sum_total_laid_off desc) as ranking
from cte_company_year
where years is not null
)
select *
from company_ranking
where ranking <= 5;