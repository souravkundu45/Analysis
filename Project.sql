
select * from project..Data1;

select * from project..Data2;

-- total columns

select count(*) from project..Data1;

select count(*) from project..Data2;

-- dataset for jharkhand nd bihar
select * from project..Data1;
select * from project..Data1 
where State in ('Jharkhand', 'Bihar');

-- calculate population of india
select * from project..Data2;
select sum(population) as total_population from project..Data2;

-- average growth of india
select avg(growth) as Avg_growth from project..Data1;
select avg(growth)*100 as Avg_growth_percentage from project..Data1;

-- average growth of state

select state,avg(growth)*100 as Avg_growth_percentage from project..Data1 group by state;

-- average sex ratio

select avg(sex_ratio)  from project..Data1;
select state,round(avg(sex_ratio),0) as Avg_sex_ratio from project..Data1 group by state order by Avg_sex_ratio desc;

-- average literacy rate

select state,ROUND(avg(Literacy),0) as Avg_Literacy from project..Data1 group by state 
having ROUND(avg(Literacy),0) > 90 order by Avg_Literacy desc;

-- top 3 states have highest growth ratio

select  top 3 state,avg(growth)*100 as Avg_growth_percentage from project..Data1 group by state order by Avg_growth_percentage desc;

-- top 3 states highest sex ratio
select  top 3 state,round(avg(sex_ratio),0) as Avg_sex_ratio from project..Data1 group by state order by Avg_sex_ratio desc;


-- bottom 3 states showing lowest sex ratio


select  top 3 state,round(avg(sex_ratio),0) as Avg_sex_ratio from project..Data1 group by state order by Avg_sex_ratio asc;


-- top and bottom 3 states literacy rate
drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;


drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;


-- union operator 

select * from(
select top 3 * from #topstates order by #topstates.topstate desc) a
union
select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;


-- states starting with letter a and end with letter d

select * from project..Data1 where lower(state) like 'a%';
select distinct state from project..Data1 where lower(state) like 'a%';

select distinct state from project..Data1 where lower(state) like 'a%' or lower(state) like '%d';

-- joining the table

select a.state, a.district, a.sex_ratio, b.population from project..Data1 a
inner join project..Data2 b 
on a.district = b.district;

-- calculate the number of male and female

select c.state,c.district,round(c.population/(sex_ratio + 1),0) as male, round(c.population - (population/(sex_ratio + 1)),0) as female from
(select a.state, a.district, a.sex_ratio/1000 as sex_ratio, b.population from project..Data1 a
inner join project..Data2 b 
on a.district = b.district)c;

select top 3 c.state,c.district,round(c.population/(sex_ratio + 1),0) as male, round(c.population - (population/(sex_ratio + 1)),0) as female from
(select a.state, a.district, a.sex_ratio/1000 as sex_ratio, b.population from project..Data1 a
inner join project..Data2 b 
on a.district = b.district)c order by female desc;

--  total male ,female in state 
select s.state, sum(s.male) as total_male, sum(s.female) as total_female from
(select c.state,c.district,round(c.population/(sex_ratio + 1),0) as male, round(c.population - (population/(sex_ratio + 1)),0) as female from
(select a.state, a.district, a.sex_ratio/1000 as sex_ratio, b.population from project..Data1 a
inner join project..Data2 b 
on a.district = b.district)c)s 
group by s.state;

-- total literacy rate
select d.state, sum(d.literate_people) as total_literate_people, sum(d.illiterate_people) as total_illiterate_people from
(select l.state, l.district, round(l.literacy_ratio*l.population, 0) as literate_people, round((1-l.literacy_ratio)*l.population, 0) as illiterate_people from
(select a.state, a.district, a.literacy/100 as literacy_ratio, b.population from project..Data1 a
inner join project..Data2 b on a.district = b.district)l)d
group by d.state;

select top 5 d.state, sum(d.literate_people) as total_literate_people, sum(d.illiterate_people) as total_illiterate_people from
(select l.state, l.district, round(l.literacy_ratio*l.population, 0) as literate_people, round((1-l.literacy_ratio)*l.population, 0) as illiterate_people from
(select a.state, a.district, a.literacy/100 as literacy_ratio, b.population from project..Data1 a
inner join project..Data2 b on a.district = b.district)l)d
group by d.state order by total_illiterate_people desc;


select top 5 d.state, sum(d.literate_people) as total_literate_people, sum(d.illiterate_people) as total_illiterate_people from
(select l.state, l.district, round(l.literacy_ratio*l.population, 0) as literate_people, round((1-l.literacy_ratio)*l.population, 0) as illiterate_people from
(select a.state, a.district, a.literacy/100 as literacy_ratio, b.population from project..Data1 a
inner join project..Data2 b on a.district = b.district)l)d
group by d.state order by total_literate_people desc;


-- population in previous census

select e.state, sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population from
(select g.state, g.district, round(g.population/(1 + g.growth),0) as previous_census_population, round(g.population,0) as current_census_population from
(select a.state, a.district, a.growth as growth, b.population from project..Data1 a
inner join project..Data2 b 
on a.district = b.district)g)e
group by e.state;


select sum(t.previous_census_population) as total_previous_census_population, sum(t.current_census_population) as total_current_census_population from
(select e.state, sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population from
(select g.state, g.district, round(g.population/(1 + g.growth),0) as previous_census_population, round(g.population,0) as current_census_population from
(select a.state, a.district, a.growth as growth, b.population from project..Data1 a
inner join project..Data2 b 
on a.district = b.district)g)e
group by e.state)t;


select (sum(t.current_census_population) - sum(t.previous_census_population)) as Increased_population from
(select e.state, sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population from
(select g.state, g.district, round(g.population/(1 + g.growth),0) as previous_census_population, round(g.population,0) as current_census_population from
(select a.state, a.district, a.growth as growth, b.population from project..Data1 a
inner join project..Data2 b 
on a.district = b.district)g)e
group by e.state)t;


-- population per km2

select o.total_area/o.total_previous_census_population as Population_per_area_previous, o.total_area/o.total_current_census_population as Population_per_area_current from(
select q.*, r.total_area from
(
select '1' as keyy, k.* from(
select sum(t.previous_census_population) as total_previous_census_population, sum(t.current_census_population) as total_current_census_population from
(select e.state, sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population from
(select g.state, g.district, round(g.population/(1 + g.growth),0) as previous_census_population, round(g.population,0) as current_census_population from
(select a.state, a.district, a.growth as growth, b.population from project..Data1 a
inner join project..Data2 b 
on a.district = b.district)g)e
group by e.state)t)k)q inner join(

select '1' as keyy, m.* from(
select sum(Area_km2)  as total_area from project..Data2)m)r
 on q.keyy = r.keyy)o;


 -- top 3 district from each state with highest literacy rate using window function

 select y.* from
 (select district, state, literacy, rank() over(partition by state order by literacy desc) as rnk from project..Data1)y
 where rnk in (1, 2, 3) order by state;

 -- top 3 districts, states with lowest literacy rate

 select y.* from
 (select district, state, literacy, rank() over(partition by state order by literacy asc) as rnk from project..Data1)y
 where rnk in (1, 2, 3) order by state desc;

