 
--Looking At Total Cases Vs Total Deaths
--likelihood of getting dead by covid in your country(in percentage)
Select location, date, total_cases,new_cases, total_deaths,(CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100 Death_percentage
FROM Covid_deaths$
WHERE location like '%nepal%'
order by 1,2


--Looking At Total Cases Vs Total Population
--likelihood of getting infected by covid in your country(in percentage)
Select location, date, total_cases,new_cases, population,(CONVERT(float,total_cases)/CONVERT(float,population))*100 percentpopulationInfected
FROM Covid_deaths$
WHERE location like '%nepal%'
order by 1,2

--Countries with Highest Infected Rate Compared to Population
Select location,population,MAX(total_cases) maximumcase,MAX((CONVERT(float,total_cases)/CONVERT(float,population)))*100 percentpopulationInfected
FROM Covid_deaths$
GROUP BY location,population
order by 4 DESC

-- Showing Countries with highest Death Counts Per Population
SELECT location ,MAX (CAST(total_deaths as int)) TotalDeathCount
FROM Covid_deaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Let's Break down by continent
--Showing Contients with highest Death Counts Per Population

SELECT location ,MAX (CAST(total_deaths as int)) TotalDeathCount
FROM Covid_deaths$
WHERE continent IS  NULL AND location NOT IN ('Low income', 'Lower middle income', 'Upper middle income', 'High income')
GROUP BY location
ORDER BY TotalDeathCount DESC
 

 -- Global numbers

	SELECT
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS Death_Percentage
FROM
    Covid_deaths$
	WHERE
    continent IS NOT NULL 


-- Looking at Total Population Vs Vaccination

WITH PopvsVacc (continent,location,date,population,new_vaccinations,Total_vaccinat)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) Total_vaccinat
FROM Covid_deaths$ dea
JOIN Covid_Vaccination$ vac
ON dea.location=vac.location AND 
dea.date=vac.date
WHERE 
dea.continent IS NOT NULL
)

---USE CTE
SELECT *, (Total_vaccinat)/population*100
FROM PopvsVacc


-- Using Temp Tables

-- CREATE TABLE

--DROP TABLE if exists #percentagePopulationVaccinated
CREATE TABLE #percentagePopulationVaccinated
(
continent nVARCHAR(255),
location nVARCHAR(255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_vaccinat numeric
)

--- INSERT VALUES 
INSERT INTO  #percentagePopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) Total_vaccinat
FROM Covid_deaths$ dea
JOIN Covid_Vaccination$ vac
ON dea.location=vac.location AND 
dea.date=vac.date
WHERE 
dea.continent IS NOT NULL

-- CALLING TEMP TABLE
SELECT *,Total_vaccinat/population*100 Percentage_Vaccinated
FROM  #percentagePopulationVaccinated