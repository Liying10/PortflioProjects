SELECT *
FROM PorfolioProject..CovidDeaths

--SELECT *
--FROM PorfolioProject..CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths
--where continent is not null
order by 1,2

--How likely someone could die from covid
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as DeathPercentage
FROM PorfolioProject..CovidDeaths
where location like '%costa%'
order by 1,2

--Total cases vs population
--percentage of population that got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as percentPopulationInfected
FROM PorfolioProject..CovidDeaths
--where location like '%costa%'
order by 1,2

--Countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as highestInfectionCount, max((total_cases/population)*100) as percentPopulationInfected
FROM PorfolioProject..CovidDeaths
--where location like '%costa%'
Group by location, population
order by percentPopulationInfected desc


--Countries with highest death count per population
SELECT location, max (cast (total_deaths as int)) as TotalDeathCount
FROM PorfolioProject..CovidDeaths
--where location like '%costa%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Break down to continents 
SELECT location, max (cast (total_deaths as int)) as TotalDeathCount
FROM PorfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc


--Globar numbers
SELECT date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as DeathPercentage
FROM PorfolioProject..CovidDeaths
--where location like '%costa%'
where continent is not null
Group by date 
order by 1,2




--Total population vs vaccinations
--Use of CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER  (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER  (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later viz

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER  (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * 
From PercentPopulationVaccinated