Drop schema if exists public cascade;
Drop schema if exists private cascade;
-- Drop table if exists row cascade;
-- Drop table if exists num cascade;
-- Drop table if exists seat cascade;
-- Drop table if exists ticket cascade;


create schema private;
create schema public;


create table public.row(
	theRow varchar(2) not null,
	primary key (theRow)
);


insert into row values
	('A'),
	('B'),
	('C'),
	('D'),
	('E'),
	('F'),
	('G'),
	('H'),
	('J'),
	('K'),
	('L'),
	('M'),
	('N'),
	('O'),
	('P'),
	('Q'),
	('R'),
	('AA'),
	('BB'),
	('CC'),
	('DD'),
	('EE'),
	('FF'),
	('GG'),
	('HH');


create table public.num(
	col int not null,
	primary key (col)
);


create function populate_col() returns void LANGUAGE plpgsql as $$
declare r int;
declare c int;
begin
	r := 1;
	c := 101;
	loop
    	insert into public.NUM
    	select r;   	 
    	r = r + 1; exit when r >= 15;   	 
	end loop;
	loop
    	insert into public.NUM
    	select c;   	 
    	c = c + 1; exit when c >= 126;
	end loop;
end $$;
select populate_col();


create table public.seat(
	seat_row varchar(2) not null,
	seat_number int not null,
	section varchar(10) check(section in('Balcony','Main Floor')),
	side varchar(6) check(side in('Left','Middle','Right')),
	pricing_tier varchar(13) check(pricing_tier in ('Upper Balcony', 'Side','Orchestra')),
	wheelchair int check(wheelchair in(1,0)) default 0,
	constraint pk primary key (seat_row, seat_number),
	constraint fk_seatRow foreign key(seat_row) references row(theRow),
	constraint fk2_seatNumber foreign key(seat_number) references num(col)
	);
    
create table public.ticket(
	ticket_number serial not null primary key,
	fname_ticket text,
	lname_ticket text,
	seat_row_ticket varchar(2) not null,
	seat_number_ticket int not null,
   
	constraint fk_ticket foreign key(seat_row_ticket, seat_number_ticket)
	references seat(seat_row, seat_number),
       	 
	constraint unique_ticket unique(seat_row_ticket, seat_number_ticket)    
	);
    
create table public.customer(
	customerID serial not null primary key,
	fname text not null,
	lname text not null,
	ticket_number serial,
    constraint fk_customer foreign key(ticket_number)
	references ticket(ticket_number)  
	  
	);




create table private.customer(
	customerID serial not null primary key,
	ticket_number serial,
	fname text not null,
	lname text not null,
	credit_card decimal(16,0)
    
);


-- inserts for main floor
-- main floor middle
insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Main Floor', 'Middle','Orchestra',0
from row, num where char_length(therow) = 1 and col <=15;


insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Main Floor', 'Right','Orchestra',0
from row,num where char_length(therow) = 1 and (col = 106 or col = 104 or col = 102);


insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Main Floor', 'Left','Orchestra',0
from row,num where char_length(therow)=1 and (col = 105 or col = 103 or col = 101);


insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Main Floor', 'Right','Side',0
from row,num where char_length(therow)=1 and col%2 = 0 and col>=108 and col <=122;


insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Main Floor', 'Left','Side',0
from row,num where char_length(therow)=1 and col%2 != 0 and col>=107 and col<=121;


-- balcony
insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Balcony', 'Right','Side',0
from row,num where (theRow = 'AA' or theRow = 'BB' or theRow = 'CC' or theRow = 'DD')
and col%2 = 0 and col >=102 and col <=126;


insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Balcony', 'Middle','Orchestra',0
from row,num where (theRow = 'AA' or theRow = 'BB' or theRow = 'CC' or theRow = 'DD')
and col >=1 and col <=14;


insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Balcony', 'Left','Side',0
from row,num where (theRow = 'AA' or theRow = 'BB' or theRow = 'CC' or theRow = 'DD')
and col%2 != 0 and col >=101 and col <=125;


insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Balcony', 'Right','Upper Balcony',0
from row,num where (theRow = 'EE' or theRow = 'FF' or theRow = 'GG' or theRow = 'HH')
and col%2 = 0 and col >=102 and col <=122;


insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Balcony', 'Middle','Upper Balcony',0
from row,num where (theRow = 'EE' or theRow = 'FF' or theRow = 'GG' or theRow = 'HH') 
and col >=1 and col <=11;


insert into seat(seat_row, seat_number, section, side, pricing_tier,wheelchair)
select row.theRow, num.col, 'Balcony', 'Left','Upper Balcony',0
from row,num where (theRow = 'EE' or theRow = 'FF' or theRow = 'GG' or theRow = 'HH')
and col%2 != 0 and col >=101 and col <=121;
   
update Seat    
set pricing_tier = 'Side' where char_length(seat_row) = 1
and seat_number >= 108;
    
update Seat    
set wheelchair = 1 where seat_row in ('P', 'Q', 'R')
and seat_number > 108 and side = 'Right';


update Seat    
set wheelchair = 1 where seat_row in ('P', 'Q', 'R')
and seat_number > 107 and side = 'Left';


insert into public.Ticket
(fname_ticket, lname_ticket, seat_row_ticket, seat_number_ticket)
values
('Lamport','Leslie','A',1),
('Goldwasser','Sha?','A',3),
('Micali','Silvio','A',5),
('Pearl','Judea','A',7),
('Valiant','LeslieGabriel','A',113),
('Thacker','CharlesP.','B',2),
('Liskov','Barbara','B',4),
('Clarke','EdmundMelson','B',6),
('Emerson','E.Allen','C',109),
('Sifakis','Joseph','C',107),
('Allen','Frances  Elizabeth','C',105),
('Naur','Peter','E',102),
('Cerf','Vinton  Gray','E',104),
('Kahn','Robert  Elliot','E',106),
('Kay','Alan','F',1),
('Adleman','Leonard  Max','G',2),
('Rivest','Ronald  Linn','H',101),
('Shamir','Adi','J',1),
('Dahl','Ole-Johan','J',3),
('Nygaard','Kristen','J',5),
('Yao','AndrewChi-Chih','J',2),
('Brooks','Frederick','J',4),
('Engelbart','Douglas','K',9),
('Pnueli','Amir','AA',7),
('Blum','Manuel','AA',9),
('Feigenbaum','EdwardA','AA',11),
('Reddy','DabbalaRajagopal','AA',124),
('Hartmanis','Juris','AA',122),
('Stearns','Richard  Edwin','BB',101),
('Lampson','ButlerW','BB',103),
('Milner','ArthurJohn Robin Gorell ','BB',105),
('Corbato','FernandoJ','BB',107),
('Kahan','William  Morton','CC',2),
('Sutherland','Ivan','CC',4),
('Cocke','John','CC',6),
('Hopcroft','JohnE','CC',8),
('Tarjan','Robert  Endre','DD',1),
('Karp','Richard  Manning','DD',3),
('Wirth','NiklausE','DD',5),
('Ritchie','DennisM.','DD',7),
('Thompson','KennethLane','EE',10),
('Cook','StephenArthur','EE',9),
('Codd','EdgarF. ','EE',7),
('Hoare','C.Antony  R.','EE',5),
('Iverson','KennethE. ','EE',3),
('Floyd','Robert  W','FF',101),
('Backus','John','FF',103),
('Rabin','MichaelO.','FF',105),
('Scott','DanaStewart','FF',107),
('Newell','Allen','FF',109),
('Simon','Herbert  Alexander','GG',1),
('Knuth','Donald  Ervin','GG',3),
('Bachman','CharlesWilliam','GG',5),
('Dijkstra','EdsgerWybe','GG',7),
('McCarthy','John','GG',110),
('Wilkinson','JamesHardy ','HH',101),
('Minsky','Marvin','HH',103),
('Hamming','RichardW','HH',105),
('Wilkes','MauriceV.','HH',1),
('Perlis','AlanJ','HH',3);


insert into public.customer(ticket_number,fname,lname)
select ticket_number,fname_ticket, lname_ticket from ticket;


insert into private.customer(ticket_number,fname,lname)
select ticket_number,fname_ticket, lname_ticket from ticket;


select * from public.Ticket where
ticket.seat_row_ticket = 'A' order by seat_row_ticket, seat_number_ticket;


select ticket.seat_number_ticket, seat.seat_row,
seat.seat_number,seat.pricing_tier from ticket
inner join seat on ticket.seat_row_ticket = seat.seat_row
and ticket.seat_number_ticket = seat.seat_number
and seat.pricing_tier = 'Upper Balcony'
order by seat.seat_row, seat.seat_number;


select seat.seat_row, seat.seat_number, seat.pricing_tier
from ticket full outer join seat
on ticket.seat_row_ticket = seat.seat_row
and ticket.seat_number_ticket = seat.seat_number
where ticket.seat_number_ticket is null and seat.seat_row = 'HH'
order by seat.seat_row, seat.seat_number;


select * from seat
order by seat_row, seat_number;
-- select * from ticket;
-- select * from public.customer;
 select * from private.customer;
-- update private.customer set credit_card = 1234123412341234
-- where lname = 'Leslie';






