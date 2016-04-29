create table books (
	id_book number primary key,
	title varchar2(100) not null,
	author varchar2(50),
	isbn varchar2(20)
);

create table customers (
	id_cust number primary key,
	fullname varchar2(50) not null,
	born date
);

create sequence loans_seq increment by 1 start with 1 nocache nocycle;

create table loans (
	id_loan number primary key,
	id_cust constraint fk_id_cust references customers(id_cust) not null,
	id_book constraint fk_id_book references books(id_book) not null,
	--t_start date not null
	t_start date default sysdate
);

create or replace trigger loans_set_id before insert on loans for each row
	begin
		select loans_seq.nextval into :new.id_loan from dual;
	end;
	/
	
/*
create or replace trigger loans_set_date before insert or update on loans for each row
	begin
		:new.t_start := sysdate;
	end;
	/
*/

-------------------------------------------

insert into books values(1, 'Eating People Is Wrong', 'Malcolm Bradbury', '9780436065040');
insert into books values(2, 'How To Make Money In Your Spare Time', 'J. M. R. Rice', '9780883650646');
insert into books values(7, 'How To Avoid Huge Ships', 'Captain John W. Trimmer', '9780870334337');
insert into books values(99, 'Why Cats Paint', 'Heather Busch', '9780898156232');
insert into books values(10, 'Everything I Know About Women I Learned From My Tractor', 'Roger Welsch', '9780760311493');
insert into books values(3, 'Everything I Want To Do Is Illegal', 'Joel Salatin', '9780963810953');
insert into books values(87, 'Mommy Drinks Because You Are Bad', 'Lyranda Martin-Evans', '9780385349291');
insert into books values(98, 'Are Women Human?', 'Catherine A. MacKinnon', '9780674021877');
insert into books values(39, 'Old Tractors And The Men Who Love Then', 'Roger Welsch', '9780760301296');
insert into books values(38, 'The Practical Pyromaniac', 'William Gurstelle', '9781569768877');
insert into books values(64, 'How To Raise Your IQ By Eating', 'Lewis Burke Frumkes', '9781475920529');
insert into books values(65, 'Anybody Can Be Cool But Awesome Takes Practise', 'Lorraine Peterson', '9781556610400');
insert into books values(56, 'Everyone Poops', 'Taro Gomi', '9782841661503');
insert into books values(11, 'Hitler: Neither Vegetarian Nor Animal Lover', 'Rynn Berry', '9780962616969');
insert into books values(4, 'Who Cares About Elderly People?', 'Pam Adams', '9780859533522');
--select id_book, substr(title, 1, 15), substr(author, 1, 20), isbn from books;

insert into customers values(1, 'Pepa Skocdopole', date '1999-05-03');
insert into customers values(2, 'Boris Chlebnik', date '2008-12-31');
insert into customers values(19, 'Prokop Dvere', date '1946-04-16');
insert into customers values(65, 'Jaro Vitamvas', date '1956-03-25');
insert into customers values(91, 'Fakulta Informatiky', date '1993-09-23');
insert into customers values(100, 'Fantomas BylJsemTu', date '1981-01-01');
--select * from customers;

/*
insert into loans (id_cust, id_book, t_start) values (1, 87, date '2016-04-23');
insert into loans (id_cust, id_book, t_start) values (1, 39, date'2016-03-17');
insert into loans (id_cust, id_book, t_start) values (65, 39, date '2016-04-05');
insert into loans (id_cust, id_book, t_start) values (65, 38, date '2016-04-13');
insert into loans (id_cust, id_book, t_start) values (65, 98, date '2016-04-20');
insert into loans (id_cust, id_book, t_start) values (91, 64, date '2013-12-05');
insert into loans (id_cust, id_book, t_start) values (100, 4, date '1989-11-17');
*/

insert into loans (id_cust, id_book) values (1, 87);
insert into loans (id_cust, id_book) values (1, 39);
insert into loans (id_cust, id_book) values (65, 39);
insert into loans (id_cust, id_book) values (65, 38);
insert into loans (id_cust, id_book) values (65, 98);
insert into loans (id_cust, id_book) values (91, 64);
insert into loans (id_cust, id_book) values (100, 4);

--select * from loans;

-------------------------------------------

-- number of books with no loan
select count(id_book) as num_book_no_loan from books where id_book not in (select id_book from loans);

--takes customers and number of loans in descending order
select customers.fullname, count(loans.id_cust) as num_loans from customers left join loans on loans.id_cust = customers.id_cust group by fullname order by num_loans desc;

--name and number of loans where more then one loan
select customers.fullname, count(loans.id_cust) as num_loans from loans inner join customers on loans.id_cust = customers.id_cust group by fullname having count(loans.id_loan) > 1;

-------------------------------------------

select id_cust, id_loan, t_start from loans where (t_start + interval '1' month) < sysdate;

--takes loans which are older then 1 month
declare
	cursor expired is 
		select id_cust, id_book, t_start from loans where (t_start + interval '1' month) < sysdate;
	begin
		for loan in expired loop
			dbms_output.put_line(loan.id_cust || ', ' || loan.id_book);
		end loop;
	end;
/

-------------------------------------------

drop sequence loans_seq;
drop table loans cascade constraints;
drop table customers cascade constraints;
drop table books cascade constraints;
