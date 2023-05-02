###### Question 1: Create table structures for members, bookings, and facilities in the club data database as specified

```sql
create table members(
    memid int not null,
    surname varchar(200),
    firstname varchar(200),
    address varchar(300),
    zipcode int,
    telephone varchar(20),
    recommendedby int,
    joindate timestamp,
    primary key (memid),
    foreign key (recommendedby) references memid
    );

create table bookings(
    bookid int not null,
    facid int not null,
    memid int not null,
    starttime timestamp not null,
    slots int not null,
    primary key (bookid),
    foreign key (memid) references members(memid),
    foreign key (facid) references facilities(facid)
    );

create table facilities(
    facid int not null,
    name varchar(100),
    membercost decimal(65,2),
    guestcost decimal(65,2),
    initialoutlay decimal(65,2),
    monthlymaintenance decimal(65,2),
    primary key (facid)
    );
```

###### Question 2: Insert new entry for Spa facility into the facilities table

```sql
insert into cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
values (9, 'Spa', 20, 30, 100000, 800);
```

###### Question 3: Make correction to initial outlay value for Tennis Court 2 in the facilities table

```sql
update cd.facilities
set initialoutlay=10000
where name='Tennis Court 2';
```

###### Question 4: Delete all bookings from the bookings table

```sql
delete from cd.bookings;
```

###### Question 5: Delete the entry for member number 37

```sql
delete from cd.members where memid=37;
```

###### Question 6: Add new facility into facilities table with the facility ID being the next number sequentially after the highest id number currently

```sql
insert into cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
values ((select max(facid)+1 from cd.facilities), 'Spa', 20, 30, 100000, 800);
```

###### Question 7: Set member and guest costs in the Tennis Court 2 facility to be 10% more than the corresponding costs for the Tennis Court 1 facility

```sql
update cd.facilities
set membercost=(select membercost*1.1 from cd.facilities where name='Tennis Court 1'),
guestcost=(select guestcost*1.1 from cd.facilities where name='Tennis Court 1')
where name='Tennis Court 2';
```

###### Question 8: Categorize facilities based on maintenance cost ('expensive' if it is more than $100, 'cheap' otherwise)

```sql
select name,
case
	when monthlymaintenance>100 then 'expensive'
	else 'cheap'
end as cost
from cd.facilities;
```

###### Question 9: Create a table that with a comprehensive list of member surnames and facility names, for fun

```sql
select surname from cd.members
union
select name from cd.facilities;
```

###### Question 10: Select all booking start times for a member named David Farrell (by combining the bookings table with the members table)

```sql
select starttime
from cd.members as m inner join cd.bookings as b on m.memid=b.memid
where m.surname='Farrell' and m.firstname='David';
```

###### Question 11: Find all bookings on September 21st, 2012 for tennis court facilities, in chronological order (earliest to latest)

```sql
select starttime as start, name
from cd.bookings as b join cd.facilities as f on b.facid=f.facid
where (select extract(year from starttime))=2012
and (select extract(month from starttime))=09
and (select extract(day from starttime))=21
and name like 'Tennis Court%'
order by start;
```

###### Question 12: Retrieve a table of each member and any corresponding member that recommended them (or NULL if there wasn't one), ordered by each member's last name then first name

```sql
select mem.firstname as memfname, mem.surname as memsname, rec.firstname as recfname, rec.surname as recsname
from cd.members mem left outer join cd.members rec on mem.recommendedby=rec.memid
order by memsname, memfname;
```

###### Question 13: Retrieve a table listing the names of all members who have recommended another member, ordered by surname and then first name

```sql
select recs.firstname, recs.surname
from (select firstname, surname, memid
	  from cd.members
	  where memid in (select distinct recommendedby from cd.members)) as recs
order by recs.surname, recs.firstname;
```

###### Question 14: Same as question 12, but without joins, and with one column containing the members full name rather than two separate ones for first name and surname

```sql
select distinct concat(firstname, ' ', surname) as member,
(select concat(rec.firstname, ' ', rec.surname) from cd.members rec where rec.memid=cd.members.recommendedby) as recommender
from cd.members;
```

###### Question 15: Select the member ID of each member and the number of other existing members they recommended, in order of ascending member ID

```sql
select recommendedby, count(recommendedby) as count
from cd.members
group by recommendedby
having recommendedby is not null
order by recommendedby;
```

###### Question 16: Find the total number of slots booked by each facility in order of ascending facility ID

```sql
select facid, sum(slots) as "Total Slots"
from cd.bookings
group by facid
order by facid;
```

###### Question 17: Find the total number of slots booked by each facility in September 2012, ordered from fewest to most

```sql
select facid, sum(slots) as "Total Slots"
from cd.bookings b
where (select extract(month from b.starttime))=9 and (select extract(year from b.starttime))=2012
group by facid
order by "Total Slots";
```

###### Question 18: Find the total number of slots booked for each facility by month, sorted by facility ID then by month

```sql
select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
from cd.bookings
where extract(year from starttime)=2012
group by facid, month
order by facid, month;
```

###### Question 19: Find out how many total members have made at least one booking

```sql
select count(distinct memid) as count
from cd.bookings;
```

###### Question 20: List each member's first booking starting from September 1, 2012 in order of increasing member ID

```sql
select surname, firstname, memid, starttime
from cd.members m join (select memid as id, min(starttime) as starttime
			from (select * from cd.bookings where starttime>='2012-09-01') sept
			group by id) b on m.memid=b.id
order by memid;
```

###### Question 21: Produce a table containing the total number of members in each row alongside each members first and last name

```sql
select (select count(distinct memid) from cd.members), firstname, surname
from cd.members;
```

###### Question 22: Produce a table with a row number alongside the first name and surname of each member, in chronolocial order of join date

```sql
select row_number() over (order by joindate), firstname, surname
from cd.members;
```

###### Question 23: Output the facility (or facilities) with the highest number of bookings and their corresponding number of bookings

```sql
with s(facid, total) as (select facid, sum(slots) as total
						 from cd.bookings
						 group by facid)
select facid, total
from s
where total=(select max(total) from s);
```

###### Question 24: Output the names of all members, formatted as 'Surname, Firstname'

```sql
select concat(surname, ', ', firstname)
from cd.members;
```

###### Question 25: Find all info pertaining to facilities whose name starts with 'tennis' (not case sensitive)

```sql
select * from cd.facilities
where lower(name) like 'tennis%';
```

###### Question 26: Return a table of member ID numbers and the corresponding member's phone number where the phone number is formatted with parentheses like (123) 456-7890

```sql
select memid, telephone
from cd.members
where telephone like '(%)%';
```

###### Question 27: Find the number of members whose surname starts with each letter of the alphabet (excluding the letters that no member's surname starts with)

```sql
select substring(surname from 1 for 1) as letter, count(*)
from cd.members
group by letter
order by letter;
```
