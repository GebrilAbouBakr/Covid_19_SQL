Select *
FROM ProtfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--FROM ProtfolioProject..CovidVaccination
--order by 3,4

 --select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from ProtfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Loking at total cases vs total Deaths
--Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from ProtfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2

--Looking at Total Cases vs population
--Shows what of percentage population got covid

select Location, date, population, total_cases,  (total_cases/population)*100 as Percentpopulationinfected
from ProtfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2


 --Looking at Countries with Highest infection Rate compered to Population

 select Location, population, max(total_cases) as highestinfectionCount,  MAX((total_cases/population))*100 as Percentpopulationinfected
from ProtfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by Percentpopulationinfected desc


--Showing Countries with highest Death count per population

Select Location, MAX(cast(Total_Deaths as int)) AS TotalDeathsCount
from ProtfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathsCount desc


--Lit's Breake down BY continent


Select continent, MAX(cast(Total_Deaths as int)) AS TotalDeathsCount
from ProtfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathsCount desc

--Lit's Breake down BY continent

--Showing continents with highest Death count per population

Select continent, MAX(cast(Total_Deaths as int)) AS TotalDeathsCount
from ProtfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathsCount desc



--Global Numbers

select   SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM
 (new_cases)*100  as DeathsPercentage
from ProtfolioProject..CovidDeaths
--Where location like '%states%' 
where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinatios

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location)
From ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac




-- TIMP TABLE 

Drop Table if exists #Percentpopulationinfected
Create Table #Percentpopulationinfected
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #Percentpopulationinfected
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
  dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100   
from #Percentpopulationinfected


 --Creating View to store data for later visualizations
 Create View Percentpopulationinfected as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location order by dea.location,
  dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from Percentpopulationinfected