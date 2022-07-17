use Covid19;

select * from Covid19.dbo.CovidDeaths;
select * from Covid19.dbo.CovidVaccinations;


--select the data that we are going to be using

select Location, date, total_cases,new_cases, total_deaths, population
from Covid19.dbo.CovidDeaths
order by 1,2;


--Looking at Total Cases vs Total deaths
--this tells us the chances of dying 

select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_percent
from covid19.dbo.CovidDeaths
where location='India'
order by 1,2 desc;


--Looking at the total cases vs population
--what percent of people got covid and the countries having the highest infection rate 

select Location, population, max(total_cases) high_infection_rate, max((total_cases/population)*100) population_affected
from covid19.dbo.CovidDeaths
--where location='India'
group by Location, population
order by population_affected desc;


--showing the countries with the highest death count per population

select Location, max(cast(total_deaths as int)) total_death_count
from covid19.dbo.CovidDeaths
where continent<>'null'
--or where continent is not null
group by Location
order by total_death_count desc;


--narrowing this down by continent
--continents where death rate is high

select location, max(cast(total_deaths as int)) total_death_count
from covid19.dbo.CovidDeaths
where continent is null
group by location
order by total_death_count desc;

--OR

select Location, max(cast(total_deaths as int)) total_death_count
from covid19.dbo.CovidDeaths
where continent is null
group by continent, location
order by total_death_count desc;


--Total new cases and deaths globally as per dates

select Date, sum(new_cases) New_cases, sum(cast(new_deaths as int)) New_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercentage
from covid19.dbo.CovidDeaths
where continent is not null
group by Date
order by 1 desc;


--Total new cases along with death percentage

select sum(new_cases) New_cases, sum(cast(new_deaths as int)) New_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercentage
from covid19.dbo.CovidDeaths
where continent is not null;


--JOINING THE TWO TABLES

select * 
from Covid19.dbo.CovidDeaths cd
join
Covid19.dbo.CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date;


--How many people are vaccinated among the total population?

--creating CTE
With popandvac (Continent, Location, Date, Population, new_vaccinations, total_new_vaccinations)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location,
cd.date) as total_new_vaccinations
from Covid19.dbo.CovidDeaths cd
join Covid19.dbo.CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
--order by 2,3
)
select *, (total_new_vaccinations/Population)*100 vacc_pop_percent
from popandvac
order by 6 desc;



--Using Temp Table

Drop table if exists #percentpopvacc
create table #percentpopvacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_new_vaccinations numeric
);

insert into #percentpopvacc
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cast(cv.new_vaccinations as float)) over (partition by cd.location order by cd.location,
cd.date) as total_new_vaccinations
from Covid19.dbo.CovidDeaths cd
join Covid19.dbo.CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3

select *, (total_new_vaccinations/Population)*100 vacc_pop_percent
from #percentpopvacc
order by 6 desc;





--Creating VIEW to store DAta for Later Visualisation

Create View 
totalcasesvspopulation 
as
select Location, population, max(total_cases) high_infection_rate, max((total_cases/population)*100) population_affected
from covid19.dbo.CovidDeaths
where location='India'
group by Location, population
