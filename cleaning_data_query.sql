-- DATA CLEANING PROJECT

SELECT * 
FROM layoffs; 


-- 1. Count Of Rows
-- 2. Remove Duplicates
-- 3. Standardize the Data
-- 4. Null Values or Blank Values
-- 5. Remove any Column if Needed


-- Creating A Table To import all Raw and original data Into It
-- So We Dont Hamper The original Data Set

CREATE TABLE layoff_new
LIKE layoffs;

INSERT INTO layoff_new
SELECT *
FROM layoffs;

-- 1. Count of Rows

SELECT COUNT(*)
FROM layoff_new;

-- 2. Remove Duplicates

WITH SEE_DUP AS
(
SELECT *,
ROW_NUMBER() OVER
(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) ROW_NUM
FROM layoff_new
)
SELECT * 
FROM SEE_DUP
WHERE ROW_NUM>1;

/* We found Out the Duplicates But Since CTE CANNOT be USED with DELETE command 
So we are Creating an another table by simply coyping the format by copy to clipboard command
*/

CREATE TABLE `layoff_new2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT  -- Adding an another Column 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_new2 
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) ROW_NUM
FROM layoff_new;

DELETE 
FROM layoff_new2
WHERE row_num>1;

SELECT * 
FROM layoff_new2;  -- DUPLICATES REMOVED


-- 3. Standardizing Data

UPDATE  layoff_new2
SET company = TRIM(company);  -- Removing Spaces

SELECT DISTINCT industry   -- Checking If there is any similar Industry with different names
FROM layoff_new2
order by industry;

UPDATE layoff_new2  -- Changing Similar industry Into one name
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

UPDATE layoff_new2  -- Triming 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


UPDATE layoff_new2  -- Changing Format
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoff_new2
RENAME column `date` TO `Date(YY-MM-DD)`;

ALTER TABLE layoff_new2
MODIFY COlUMN `Date(YY-MM-DD)` DATE;  -- Changing Data type from TEXT to DATE

UPDATE layoff_new2
SET industry = NULL
where industry='';


-- 4. Removing Null

UPDATE layoff_new2 t1   -- Setting industry name and removing Null Using self Join
JOIN layoff_new2 t2
ON t1.company=t2.company   -- Populating data if similar is there
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT * FROM
layoff_new2
WHERE total_laid_off IS NULL  -- Since layoff is not Happened SO its not needed
AND percentage_laid_off IS NULL;

-- Removing Blank


DELETE FROM layoff_new2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- 5. Dropping Column

ALTER TABLE layoff_new2
DROP COLUMN row_num;


-- FINAL CLEANED DATA 


SELECT * FROM
layoff_new2;
















