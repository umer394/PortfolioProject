
select *
from PortfolioProject..CovidDeaths
where continent is not null


--select *
--from PortfolioProject..CovidVaccinations


-- select data that we are going to be using


select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location like '%state%'
order by 1,2


--looking at Total cases vs population
--show what percentage of poplation got covid

select location,date,total_cases,population,(total_cases/population)*100 as percentagepopulation
from PortfolioProject..CovidDeaths
--where location like '%state%'
order by 1,2


--looking at countries with highest infection rate compared to population

select location,population,MAX(total_cases) as highestinfectionCount,MAX((total_cases/population))*100 as percentagepopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%state%'
group by location,population
order by percentagepopulationinfected desc

--showing countries with highest death count per population


select location,MAX(cast(total_deaths as int)) as totaldeathsCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by location
order by  totaldeathsCount desc

-- lets break things by continent

select location,MAX(cast(total_deaths as int)) as totaldeathsCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is  null
group by location
order by  totaldeathsCount desc

--showing conitnents with the higher death count per population

select continent,MAX(cast(total_deaths as int)) as totaldeathsCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by  totaldeathsCount desc

--GLOBAL NUMBERS

select SUM(new_cases) AS TOTALCASES,SUM(CAST(new_deaths AS int)) AS TOTALDEATHS,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%state%'
WHERE continent IS NOT NULL
--GROUP BY date
--OEDER 1,2


--LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT DEA.continent,DEA.date,DEA.location,DEA.population,VAC.new_vaccinations
,SUM(convert(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by dea.location)
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
order by 2,3

-- use cte
WITH PopVsVac (continent,date,location,population,new_vaccinations,rollingpeoplevaccinated)
as
(
SELECT DEA.continent,DEA.date,DEA.location,DEA.population,VAC.new_vaccinations
,SUM(convert(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by dea.location)
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from PopVsVac

--temp table

drop table if exists  #PeoplePopulationVaccinated
create Table #PeoplePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PeoplePopulationVaccinated
SELECT DEA.continent,DEA.date,DEA.location,DEA.population,VAC.new_vaccinations
,SUM(convert(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by dea.location,dea.date)
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
    AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL
--order by 2,3
select *, (rollingpeoplevaccinated/population)*100
from #PeoplePopulationVaccinated

--creating view to store data for later visualization

create view PeoplePopulationVaccinated as
SELECT DEA.continent,DEA.date,DEA.location,DEA.population,VAC.new_vaccinations
,SUM(convert(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by dea.location,dea.date)
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
    AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--order by 2,3

select *
from PeoplePopulationVaccinated
