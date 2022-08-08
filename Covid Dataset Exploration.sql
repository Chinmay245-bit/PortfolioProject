--selecting data that we are going to use

select location,date, total_cases, new_cases, total_deaths, population
from Portfolioproject..coviddeath
order by 1,2;

--Total Cases Vs Total Deaths
--Determining likelihood of dying if you contract covid in a prticular country

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpct
from Portfolioproject..coviddeath
where location like '%ndia%'
and continent is not null
order by 1,2;

--Total Cases Vs Total Population
--Determining likelihood of contracting covid in a country

select location,date, total_cases, population, (total_cases/population)*100 as casepct
from Portfolioproject..coviddeath
where location like '%ndia%'
order by 1,2;

--Determining countries with highes infection rate as compared to population

select location,population, max(total_cases) as highestcasesnumber, max((total_cases/population))*100 as infectionpct
from Portfolioproject..coviddeath
group by location,population
order by infectionpct desc;

--Determining countries with highest death count per population

select location,max(cast(total_deaths as int)) as highestdeathcount
from Portfolioproject..coviddeath
where continent is not null
group by location
order by highestdeathcount desc;

--Continent wise data

select continent,max(cast(total_deaths as int)) as highestdeathcount
from Portfolioproject..coviddeath
where continent is not null
group by continent
order by highestdeathcount desc;

--Global Data

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as deathpct
from Portfolioproject..coviddeath
--where location like '%ndia%'
where continent is not null
group by date
order by 1,2;

--Joining The Two Tables and looking total populations and total vaccinations

With POPVC (Continent,location,date,population,new_vaccinations, Rolling_vaccinated)
as(

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
as Rolling_vaccinated
from 
Portfolioproject..coviddeath dea
join
Portfolioproject..covidvaccine vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3;

)
select *, (Rolling_vaccinated/Population)*100 as vaccinepct
from POPVC;

--TEMP TABLE
drop table if exists #temp1rolling
create table #temp1rolling(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rolling_vaccinated numeric
)

insert into #temp1rolling
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
as Rolling_vaccinated
from 
Portfolioproject..coviddeath dea
join
Portfolioproject..covidvaccine vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3;

select *, (Rolling_vaccinated/Population)*100 as vaccinepct
from #temp1rolling;

create view 
PctPopVaccine as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date)
as Rolling_vaccinated
from 
Portfolioproject..coviddeath dea
join
Portfolioproject..covidvaccine vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3;