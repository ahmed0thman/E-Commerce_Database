create database store
use store;

----------------------------------------
--- define tables
create table category
(
	category_id int not null primary key identity(1,1),
	category varchar(50) not null
);

create table user_acount
(
	user_name_ varchar(50) primary key,
	password_ varbinary(255) not null
);

create table users
(
	user_id_ int primary key identity(1,1),
	user_name_ varchar(50) not null unique,
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	full_name as (first_name + ' ' + last_name),
	phone varchar(25),
	email_address varchar(50) not null unique,
	user_address varchar(100),
	is_seller bit not null,
	constraint FK_user_name foreign key(user_name_)
	references [dbo].[user_acount](user_name_)

);


create table sellers
(
	seller_id int primary key identity(1,1),
	user_name_ varchar(50) not null unique,
	about text,
	is_active bit not null,
	constraint FK_user_name_to_sellers foreign key(user_name_)
	references [dbo].[users](user_name_)

);


create table credit_card
(
	card_id int primary key identity(1,1),
	user_id_ int not null,
	card_num varbinary(max) not null, 
	cvc_num varbinary(max) not null,
	balance decimal(10,2) not null check(balance >= 0),
	constraint FK_user_id_to_card foreign key(user_id_)
	references [dbo].[users](user_id_)
);


create table products
(
	product_id int primary key identity(1,1),
	seller_id int not null,
	category_id int not null,
	product_name varchar(225) not null,
	description_ text,
	price decimal(10,2) not null check(price > 0),
	quantity smallint not null check(quantity >= 0),
	is_archived bit not null,
	solds_count smallint not null
	constraint fk_category_id foreign key(category_id)
	references [dbo].[category]([category_id]),
	constraint fk_seller_id foreign key(seller_id)
	references [dbo].sellers(seller_id)
);


create table cart
(
	cart_id int primary key identity(1,1),
	user_id_ int not null,
	price decimal(10,2) not null check(price > 0),
	constraint fk_cart_user_id foreign key(user_id_)
	references [dbo].users(user_id_)
);

create table cart_item
(
	cart_id int not null,
	product_id int not null,
	total_amount smallint not null check(total_amount > 0),
	price decimal(10,2) not null check(price > 0),
	constraint fk_cart_id foreign key(cart_id)
	references [dbo].cart(cart_id),
	constraint fk_cart_product_id foreign key(product_id)
	references [dbo].products(product_id),
);

create table orders
(
	order_id int primary key identity(1,1),
	price decimal(10,2) not null check(price > 0),
	date_ date not null,
	time_ time not null,
	user_id_ int not null,
	constraint fk_user_id_to_order foreign key(user_id_)
	references [dbo].users(user_id_)
);


create table order_details
(
	order_id int not null,
	product_id int not null,
	total_amount smallint not null check(total_amount > 0),
	price decimal(10,2) not null check(price > 0),
	constraint fk_order_id foreign key(order_id)
	references [dbo].orders(order_id),
	constraint fk_product_order_id foreign key(product_id)
	references [dbo].products(product_id)
);


create table payment
(
	payment_id int primary key identity(1,1),
	payment_amount decimal(10,2) not null check(payment_amount > 0),
	user_id_ int not null,
	order_id int not null,
	constraint fk_user_id_to_payment foreign key(user_id_)
	references [dbo].users(user_id_),
	constraint fk_order_id_payment foreign key(order_id)
	references [dbo].orders(order_id)
);


--- use this table as ENUM for delivery status in delivery table
create table delivey_status
(
	status_id int primary key identity(1,1),
	deli_status varchar(25) not null
);


create table delivery
(
	delivery_id int primary key identity(1,1),
	payment_id int not null,
	user_id_ int not null,
	delivery_date date not null,
	user_address text not null,
	status_id int not null,
	constraint fk_payment_id_to_delivery foreign key(payment_id)
	references [dbo].payment(payment_id),
	constraint fk_user_id_to_delivey foreign key(user_id_)
	references [dbo].users(user_id_),
	constraint fk_delivey_status foreign key(status_id)
	references [dbo].delivey_status(status_id)
);
go
--------------------------------------------
--- defines indexes

--- table products
create index product_name_index on products(product_name);
create index category_id_index on products(category_id);
create index seller_id_index on products(seller_id);

--------------------------------------------
--- define procedures and functions
go

create procedure add_user_account
(@username varchar(50), @password varchar(50))
as
begin
	declare @key_str varchar(100) = 'secret_key';
	declare @ecrypted_pass varbinary(max);
	set @ecrypted_pass = ENCRYPTBYPASSPHRASE(@key_str, @password);
	begin try
		begin transaction
		insert into user_acount values(@username, @ecrypted_pass);
		commit transaction
	end try
	begin catch
	print 'an error occured: ' + error_message();
	rollback transaction
	end catch;
end;

go

create procedure add_user
(@username varchar(50), @fname varchar(50), @lname varchar(50), @email varchar(50), @is_seller bit)
as
begin
	begin try
		begin transaction
		insert into users([user_name_],[first_name],[last_name],[email_address],[is_seller])  
		values(@username, @fname, @lname, @email, @is_seller);
		commit transaction
	end try
	begin catch
	print 'an error occured: ' + error_message();
	rollback transaction
	end catch;
end;

go

create proc add_seller_info(@username varchar(50), @about text, @isactive bit)
as
begin
	begin try
		begin transaction
		insert into sellers (about, is_active, user_name_) values
		(@about, @isactive, @username)
		commit transaction
	end try
	begin catch
		print 'an error occured: ' + error_message();
		rollback transaction
	end catch;
end;

go

create function vaild_seller_id(@seller_id int)
returns bit
as
begin
	declare @res int;
	set @res = (select count(seller_id) from sellers where seller_id = @seller_id);
	return @res
end;


go

create function authorized_seller_id(@seller_id int, @product_id int)
returns bit
as
begin
	declare @res int;
	set @res =
	(
		select count(seller_id) from products
		where seller_id = @seller_id and product_id=@product_id
	);
	return @res
end;


go



create procedure add_update_product
(@seller_id int, @category_id int,
	@name varchar(225), @description text,
	@price decimal(10,2), @quantity int = 0, @product_id int = 0)
as 
begin
	begin try
		begin transaction
		if @product_id = 0
		begin
			print 'inserting'
			insert into products(seller_id,category_id,product_name,
			description_,price,quantity,is_archived,solds_count)
			values(@seller_id,@category_id,@name,@description,@price,@quantity,0,0)
			commit transaction
		end
		else
		begin
			print 'updating'
			if [dbo].[vaild_seller_id](@seller_id) = 0
			begin
				print 'the seller id is not valid'
				rollback transaction
			end
			else if [dbo].[authorized_seller_id](@seller_id,@product_id) = 0
			begin
				print 'this seller is not autorized to update this product';
				rollback transaction
			end
			else
			begin
				update products set category_id=@category_id,product_name=@name,
				description_=@description, price=@price, quantity=@quantity
				where product_id=@product_id and seller_id=@seller_id
				commit transaction
			end
		end;
	end try
	begin catch
		print 'an error occured: ' + error_message();
		rollback transaction
	end catch;
end;


go


create function split_string(@string varchar(max), @delimiter varchar(5))
returns @res table(value varchar(50))
as
begin
	declare @index smallint;
	declare @value varchar(50);
	set @string = @string + @delimiter;
	set @index = CHARINDEX(@delimiter, @string, 1);
	while @index > 0
	begin
		set @value = SUBSTRING(@string, 1, @index - 1);
		insert into @res values(@value);
		set @string = SUBSTRING(@string, @index + 1, len(@string) - @index);
		set @index = CHARINDEX(@delimiter, @string, 1);
	end
	return;
end;
go

create procedure delete_products(@product_ids varchar(max), @seller_id int)
as
begin
	begin try
		begin transaction
		if [dbo].[vaild_seller_id](@seller_id) = 0
		begin
			print 'the seller id is not valid'
			rollback transaction
		end
		else
		begin
			update products set is_archived = 1, quantity = 0
			where product_id in (select * from [dbo].[split_string](@product_ids, ','))
			and seller_id = @seller_id
			commit transaction
		end
	end try
	begin catch
		print 'an error occured: ' + error_message();
		rollback transaction
	end catch;
end;

go;

create proc update_cart_price(@cart_id int)
as
begin

	declare @totalprice decimal(10,2) = (select sum(price) from cart_item
										where cart_id=@cart_id);
	update cart set price = @totalprice where cart_id=@cart_id;
	
end;

go;

create proc add_cart_item(@cart_id int, @product_id int, @amount smallint)
as
begin

	declare @totalprice decimal(10,2) = (select price from products where product_id=@product_id) * @amount;
	if exists(select 1 from cart_item where cart_id=@cart_id and product_id=@product_id)
	begin
		update cart_item set price = price + @totalprice where cart_id=@cart_id and product_id=@product_id;
	end
	else
	begin
		insert into cart_item values(@cart_id,@product_id,@amount,@totalprice )
	end;
	exec update_cart_price @cart_id;
end;

go;



create proc init_cart(@user_id int, @product_id int, @amount smallint)
as
begin
	begin try
		begin transaction
		insert into cart(user_id_,price) values(@user_id, 1)
		declare @cart_id int = (select max(cart_id) from cart where user_id_=@user_id);
		exec add_cart_item @cart_id, @product_id, @amount; -- add first item in cart
		
		commit transaction
		
	end try
	begin catch
		print 'an error occured: ' + error_message();
		rollback transaction
	end catch;
end;

go;

create proc handle_products_quantities(@order_id int)
as
begin
	declare @product_id int;
	declare @amount smallint;
	declare cur cursor for
	select product_id, total_amount from order_details where order_id=@order_id;
	open cur;
	fetch next from cur into @product_id, @amount;
	WHILE @@FETCH_STATUS = 0
	begin
		update products set quantity = quantity - @amount, solds_count = solds_count + @amount
		where product_id=@product_id;
		fetch next from cur into @product_id, @amount;
	end;
	close cur;
	deallocate cur;

end;

go;


create proc add_delivery(@payment_id int, @user_id int)
as
begin
	declare @user_address varchar(100) = (select user_address from users where user_id_=@user_id);
	insert into delivery(payment_id,user_id_,delivery_date,user_address,status_id)
	values (@payment_id,@user_id, dateadd(day, 3,convert(date,GETDATE())),@user_address,1);
end;

go;

create proc add_order(@cart_id int, @user_id int, @card_id int)
as
begin
set nocount on
	begin try
		begin transaction
		if not exists(select 1 from cart where cart_id=@cart_id)
		begin
			print 'not vaild cart id'
			rollback transaction
			return
		end;
		--- submit cart to orders
		insert into orders(price,date_,time_,user_id_)
		select price, CONVERT(DATE, GETDATE()), CONVERT(TIME, GETDATE()), user_id_ from cart
		where cart_id=@cart_id;

		declare @order_id int = (select max(order_id) from orders where user_id_=@user_id);

		--- add order details from cart items
		insert into order_details(order_id,product_id,total_amount,price)
		select @order_id, product_id, total_amount, price from cart_item
		where cart_id=@cart_id;

		--- handle payment
		---   add new payment
		declare @total_payment_price decimal (10,2) = (select price from orders where order_id=@order_id);
		insert into payment(payment_amount,user_id_,order_id)
		values(@total_payment_price,@user_id,@order_id)
		---   debit balance in card
		update credit_card set balance = balance - @total_payment_price where card_id=@card_id;

		--- handle products quantities
		exec handle_products_quantities @order_id;

		--- clear user cart
		delete from cart_item where cart_id=@cart_id;
		delete from cart where user_id_=@user_id;

		--- add delivery
		declare @payment_id int = (select max(payment_id) from payment where user_id_=@user_id)
		exec add_delivery @payment_id, @user_id;
		print 'order added'
		commit transaction
	end try
	begin catch
		print 'an error occured: ' + error_message();
		rollback transaction
	end catch;
end;


go;



create proc add_credit_card(@user_id int, @card_num char(16), @cvc char(3), @balance decimal(10,2))
as
begin
	declare @str_key varchar(100) = 'secret_key';
	declare @encrypted_cardnum varbinary(max);
	declare @encrypted_cvc varbinary(max);
	set @encrypted_cardnum = ENCRYPTBYPASSPHRASE(@str_key, @card_num);
	set @encrypted_cvc = ENCRYPTBYPASSPHRASE(@str_key, @cvc);
	insert into credit_card(user_id_, card_num, cvc_num, balance) 
	values(@user_id, @encrypted_cardnum, @encrypted_cvc, @balance);
end;


go;


create proc get_product_info(@seller_id int,
							@name varchar(100) = '', @category_id int = 0,
							@min decimal(10,2) = -1, @max decimal(10,2) = -1)
as
begin
	declare @sqlstring varchar(2000) ='
	select p.product_id, p.product_name, c.category, p.price, p.quantity, p.solds_count from products p
	inner join category c on p.category_id = c.category_id
	where is_archived = 0'
	declare @name_filter varchar(50) = concat(' and product_name like ', '''%', @name, '%''' );
	declare @category_filter varchar(50) = concat(' and p.category_id=',@category_id);
	declare @price_filter varchar(50) = concat(' and p.price between ', @min, ' and ', @max);
	if @name != ''
	begin
		set @sqlstring = CONCAT(@sqlstring, @name_filter);
	end;
	if @category_id != 0
	begin
		set @sqlstring = CONCAT(@sqlstring, @category_filter);
	end;
	if (@min != -1 ) and (@max != -1)
	begin
		set @sqlstring = CONCAT(@sqlstring, @price_filter);
	end;
	print @sqlstring
	exec(@sqlstring);
end;

go;

-----------------------------------------------

--- insert values into delivery_status table
insert into delivey_status(deli_status) values
('Pending'), 
('Shipped'), 
('Out for Delivey'), 
('Delivered'), 
('Refunded'),
('Failed');