--futuresfund.database.windows.net

-- create login student with password = 'futuresfund123!'
-- create login importprocess with password = 'futuresfund123!'
create user importprocess for login importprocess
alter role db_owner add member importprocess

CREATE user student for login  student
DENY select, insert, update, delete on raw to student
DENY select, insert, update, delete on rawimport to student
GRANT select, insert, update, delete on artist to student
GRANT select, insert, update, delete on chart to student
GRANT select, insert, update, delete on track to student
grant view definition to student 

--avg streams/week over the past month
create view dbo.raw 
as
select rank= dense_rank() over (ORDER BY streams desc ), track, artist, url, streams 
from (select track = [track name], artist, streams = avg(streams), url = max(url) from rawimport group by [track name], artist) x;
go

drop  view dbo.flat
go
create view dbo.flatdata
as
select track, artist, streams 
from (select track = [track name], artist, streams = avg(streams), url = max(url) from rawimport group by [track name], artist) x;
go

create table dbo.artist
( ID int not null identity(1,1) constraint pk_artist primary key
, [name]  varchar(1000) not null)
go
create table dbo.track 
( ID int not null identity(1,1) constraint pk_track primary key
, [name] varchar(1000) not null 
, [url] varchar(1000) null 
, artistID int not null constraint fk_track_artist FOREIGN KEY REFERENCES dbo.artist (ID)
)
GO
create table dbo.chart
( ID int not null identity(1,1) constraint pk_chart primary key
, rank int not null
, streams bigint not null 
, artistID int not null constraint fk_chart_artist FOREIGN KEY REFERENCES dbo.artist (ID)
, trackID int not null constraint fk_chart_track FOREIGN KEY REFERENCES dbo.track (ID)
)
go
/*
truncate dbo.artist
truncate dbo.track
truncate dbo.chart

insert into dbo.artist ([name])
select [artist] from dbo.raw group by [artist];
go
insert into dbo.track  ([name], url, artistid)
select [track], url, artistID = artist.id
from dbo.raw 
inner join dbo.artist on raw.artist = artist.name 
order by track
GO
insert into dbo.chart (rank, streams, artistid, trackid)
select raw.rank, raw.streams, artistid = artist.id, trackid = track.id 
from dbo.raw 
inner join dbo.artist on raw.artist = artist.name 
inner join dbo.track on raw.track = track.name 
GO
*/
INSERT INTO artist (name) 
SELECT 'Metallica'

SELECT * FROM ARTIST where name = 'Metallica'

INSERT INTO track (name, url, artistid)
SELECT 'Enter Sandman', NULL, 121

INSER INTO chart (rank, streams, artistid, trackid)

select max(id) from track


select t.name, a.name, c.streams 
from chart AS c
inner join track AS t on c.trackid = t.id 
inner join artist AS a on t.artistID = a.ID
Where c.rank = 1


select r.artist, Track, x.artist
from flatdata r 
inner join (select artist = '%'+artist+'%' from rawimport) x
on r.Track like x.artist 
group by r.artist, Track, x.Artist
order by Track, x.Artist
