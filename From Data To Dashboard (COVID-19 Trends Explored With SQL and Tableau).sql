
-- Data Source and Related Information:
-- Journal Name - Our World In Data 
-- Title - Cornonavirus Pandemic (COVID-19)
-- Authors - Edouard Mathieu, Hannah Ritchie, Lucas Rodés-Guirao, Cameron Appel, 
-- Charlie Giattino, Joe Hasell, Bobbie Macdonald, Saloni Dattani, Diana Beltekian, Esteban Ortiz-Ospina, and Max Roser.
-- Publication Year - 2020
-- Link to Dataset - https://ourworldindata.org/coronavirus

-- Defining Primary Objectives/Queries for The Project
-- Query 1: For each continent, the total number of deaths is what percentage of the total number of cases? 
--			Which continent witnessed the highest mortality rate?
-- Query 2: For each continent, the total number of deaths were what percentage of the total population? 
--			Which continent witnessed the highest mortality rate relative to its population size?
-- Query 3: For each country, the total number of cases recorded were what percentage of the total population?
--			Which country witnessed the highest number of covid cases relative to its population size?
-- Query 4: Which country had the highest absolute Death Count?
-- Query 5: What was the death percentage across all continents? 
-- Query 6: What is the cumulative percentage of the population infected in each country to date?
-- Query 7: What is the total number of vaccines administered by each country as of that specific date?
-- Query 8: What portion of each country's population was vaccinated daily?

-- PRELIMINARY TASK 1: Data Extraction. 
-- 1. Downloading the data as an excel file. 
-- 2. Creating two sets of data called "CovidDeaths" and "CovidVaccinations" respectively. 
-- 3. Creating a new database in SQL called "Potrfolio". 
-- 4. Importing "CovidDeaths" and "CovidVaccinations" into "Portfolio" through "SQL Server 2022 Import and Exportt Data". 

-- PRELIMINARY TASK 2: Visualizing the top 5 rows of "CovidDeaths$" and "CovidVaccinations$".

Select TOP 5*
From Portfolio..CovidDeaths$

Select TOP 5 *
From Portfolio..CovidVaccinations$

-- QUERY 1: For each continent, the total number of deaths is what percentage of the total number of cases? 
-- Which continent witnessed the highest mortality rate? 

Select continent, MAX(total_cases) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths,
MAX(cast(total_deaths as int))/MAX(total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths$
Where continent is not NULL 
and location is not NULL
and location not in ('World','European Union','International')
group by continent
order by DeathPercentage desc

-- Results: The highest and the lowest percentage of deaths were recorded in Africa and Asia respectively. 

-- QUERY 2: For each continent, the total number of deaths were what percentage of the total population? 
-- Which continent witnessed the highest mortality rate relative to its population size?

Select continent, SUM(population) as TotalPopulation, MAX(cast(total_deaths as int)) as TotalDeaths,
MAX(cast(total_deaths as int))*100/SUM(population) PercentPopulationDeath
From Portfolio..CovidDeaths$
Where continent is not NULL 
and location is not NULL
and location not in ('World','European Union','International')
group by continent

-- Results: Africa and North America recorded the highest and lowest percentage of mortality 
-- relative to their population size, respectively.

-- QUERY 3: For each country, the total number of cases recorded were what percentage of the total population?
-- Which country witnessed the highest number of covid cases relative to its population size?

Select location, population, SUM(cast(new_cases as int)) as HighestInfectionCount,
SUM(cast(new_cases as int)/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths$
Where continent is not NULL
and location not in ('World','European Union','International')
Group by location, population
Order by PercentPopulationInfected desc

-- Results: Andorra in Europe recorded the highest mortality rate relative to its population size.

-- QUERY 4: Which country had the highest absolute Death Count? 

Select location,  MAX(cast(total_deaths as int)) as DeathCount
From Portfolio..CovidDeaths$
Where continent is not NULL 
and location is not NULL
and location not in ('World','European Union','International')
group by location 
order by DeathCount desc

-- Results: United States recorded the highest absolute death count. 

-- QUERY 5: What was the death percentage across all continents? 

Select SUM(new_cases) as GlobalCases, SUM(cast(new_deaths as int)) as GlobalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From Portfolio..CovidDeaths$
Where continent is not NULL

-- Results: The global death percentage from covid-19 is approximately 2%. 

-- QUERY 6: What is the cumulative percentage of the population infected in each country to date?

Select location, population, date, MAX(total_Cases) as HighestInfectionCount, 
MAX((total_Cases)/Population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths$
Where continent is not NULL
and location not in ('World','European Union','International')
group by location, population, date
Order by PercentPopulationInfected desc

-- Joining the datasets "CovidDeaths" and "CovidVaccinations" for further inquiry. 

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (partition by death.location)
From Portfolio..CovidDeaths$ death
Join Portfolio..CovidVaccinations$ vaccine
	On death.date=vaccine.date
	and death.location=vaccine.location
where death.continent is not NULL
Order by 1,2,3 

-- QUERY 7: What is the total number of vaccines administered by each country as of that specific date?

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (partition by death.location Order by death.date) as TotalPeopleVaccinated
From Portfolio..CovidDeaths$ death
Join Portfolio..CovidVaccinations$ vaccine
	On death.date=vaccine.date
	and death.location=vaccine.location
where death.continent is not NULL
Order by 1,2,3 

-- Note: NULL values indicate that no vaccines were administered on that specific date in that specific country.

-- QUERY 8: What portion of each country's population was vaccinated daily? 

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(cast(vaccine.new_vaccinations as int)) OVER (partition by death.location Order by death.date) as
RollingPeopleVaccinated, SUM(cast(vaccine.new_vaccinations as int)) OVER (partition by death.location Order by death.date)/
death.population as PercentagePopulationVaccinated
From Portfolio..CovidDeaths$ death
Join Portfolio..CovidVaccinations$ Vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date 
Where death.continent is not NULL
order by 1,2,3

-- Note: NULL values indicate that 0% of the population was vaccinated on that specific date in that specific country.

-- Creating a temp table to visualise queries 5 and 6 together

Create Table #table
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
OverallPeopleVaccinated numeric
)

Insert into #table
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as OverallPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (OverallPeopleVaccinated/Population)*100 as OverallPercentageVaccinated
From #table

-- Note: NULL values in "new_vaccinations" indicates that no new vaccines were administered on that specific date in that specific country.
-- Note: NULL values in "OverallPeopleVaccinated" indicates that no vaccines were administered on that specific date in that specific country.
-- Note: NULL values in "OverallPercentageVaccinated" indicates that 0% of the population was vaccinated on that specific date in that specific country.

--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Highlighting Essential Queries for Tableau Visualization

-- Query 5: What was the death percentage across all continents? 
-- Query 4: Which country had the highest absolute Death Count?
-- Query 3: For each country, the total number of cases recorded were what percentage of the total population?
-- Query 6: What is the cumulative percentage of the population infected in each country to date?

-- The Queries highlighted above will be Visualized through Tableau

--------------------------------------------------------------------------------------------------------------------------------------------------------------
