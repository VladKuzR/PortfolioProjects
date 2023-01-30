use Portfolio_project;

select * from CovidDeaths
where continent is not null
order by 3, 4;

select Location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths 
where continent is not null
order by 1, 2;


select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage 
from CovidDeaths 
where location like '%united states%' and continent is not null
order by 1, 2;

--Looking at Total Cases vs Population

select Location, date,population, total_cases,  (total_cases/population)*100 as percentOfPopultionIndected 
from CovidDeaths 
where continent is not null
where location like '%united states%'
order by 1, 2;

--Countries with Higest Infection Rate Compared to Population

select Location,population, max(total_cases) as highest_infection_count,  max((total_cases/population)*100) as maxPercentOfPopultionIndected  
from CovidDeaths 
where continent is not null
group by Location, population
order by maxPercentOfPopultionIndected desc;

--Countries with Higest Death Count Compared to Population

select Location, Max(cast(total_deaths as int)) as totalDeathCount
from CovidDeaths 
where continent is not null
group by Location
order by totalDeathCount desc;




-- Shoing the Continent with the Higest Death Count
select continent, Max(cast(total_deaths as int)) as totalDeathCount
from CovidDeaths 
where continent is not null
group by continent
order by totalDeathCount desc;


--Global Numbers
select  date, Sum(new_cases) as totalDailyInfected, sum(cast(new_deaths as int)) as totalNewDeaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathsPercentage
from CovidDeaths 
where continent is not null
group by date
order by 1,2;


--Use CTE

with PopvcVac(continent, location, date, population,new_vaccinations,  RollingPeopleVaccinated)
as
(
--Total Population VS Vaccination
select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea join CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100  from PopvcVac;

-- Temp Table

drop table if exists #PercentPopulationVaccinated ;
Create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric); 

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea join CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3;

select *,(RollingPeopleVaccinated/population)*100  from #PercentPopulationVaccinated;


-- Creating View to store data for later visualisation
Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea join CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

