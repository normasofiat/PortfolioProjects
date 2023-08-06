
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%colombia%'
order by 1,2

-- Looking at Total Cases vs Population
Select location, date, total_cases,population, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%colombia%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%colombia%'
Group by location, population
order by PercentPopulationInfected desc


--Showing countries with Highest Death Count per Population

Select location, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%colombia%'
Group by location, population
order by TotalDeathCount desc

--Let's break things down by continent

Select location, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%colombia%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Global numbers

Select date, SUM((CONVERT(float,new_cases))) as total_cases, SUM((CONVERT(float,new_deaths))) as total_deaths --, SUM((CONVERT(float, new_deaths)) / SUM(CONVERT(float, new_cases)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%colombia%'
where continent is not null
group by date
order by 1,2

--Select date, SUM((CONVERT(float,new_cases))) as total_cases, SUM((CONVERT(float,new_deaths))) as total_deaths, SUM(CONVERT(float,(new_deaths))) / SUM(CONVERT(float,(new_cases)))* 100 as Deathpercentage
--from PortfolioProject..CovidDeaths
----where location like '%colombia%'
--where continent is not null
--group by date
--order by 1,2

Select *
From [PortfolioProject].[dbo].[CovidVaccinations] 

Select* 
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) over (partition by dea.location)
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.Date)
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVAc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.Date)
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *
From PopvsVac


--Temp Table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3







