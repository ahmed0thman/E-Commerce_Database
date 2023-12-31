USE [master]
GO
/****** Object:  Database [store]    Script Date: 10/4/2023 9:37:14 AM ******/
CREATE DATABASE [store]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'store', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\store.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'store_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\store_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [store] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [store].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [store] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [store] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [store] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [store] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [store] SET ARITHABORT OFF 
GO
ALTER DATABASE [store] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [store] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [store] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [store] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [store] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [store] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [store] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [store] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [store] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [store] SET  ENABLE_BROKER 
GO
ALTER DATABASE [store] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [store] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [store] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [store] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [store] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [store] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [store] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [store] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [store] SET  MULTI_USER 
GO
ALTER DATABASE [store] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [store] SET DB_CHAINING OFF 
GO
ALTER DATABASE [store] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [store] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [store] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [store] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [store] SET QUERY_STORE = ON
GO
ALTER DATABASE [store] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [store]
GO
/****** Object:  UserDefinedFunction [dbo].[authorized_seller_id]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[authorized_seller_id](@seller_id int, @product_id int)
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
GO
/****** Object:  UserDefinedFunction [dbo].[split_string]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[split_string](@string varchar(max), @delimiter varchar(5))
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
GO
/****** Object:  UserDefinedFunction [dbo].[vaild_seller_id]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[vaild_seller_id](@seller_id int)
returns bit
as
begin
	declare @res int;
	set @res = (select count(seller_id) from sellers where seller_id = @seller_id);
	return @res
end;
GO
/****** Object:  Table [dbo].[cart]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cart](
	[cart_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id_] [int] NOT NULL,
	[price] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[cart_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cart_item]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cart_item](
	[cart_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[total_amount] [smallint] NOT NULL,
	[price] [decimal](10, 2) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[category]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[category](
	[category_id] [int] IDENTITY(1,1) NOT NULL,
	[category] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[credit_card]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[credit_card](
	[card_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id_] [int] NOT NULL,
	[card_num] [varbinary](max) NOT NULL,
	[cvc_num] [varbinary](max) NOT NULL,
	[balance] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[card_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[delivery]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[delivery](
	[delivery_id] [int] IDENTITY(1,1) NOT NULL,
	[payment_id] [int] NOT NULL,
	[user_id_] [int] NOT NULL,
	[delivery_date] [date] NOT NULL,
	[user_address] [text] NOT NULL,
	[status_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[delivery_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[delivey_status]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[delivey_status](
	[status_id] [int] IDENTITY(1,1) NOT NULL,
	[deli_status] [varchar](25) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[status_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[order_details]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[order_details](
	[order_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[total_amount] [smallint] NOT NULL,
	[price] [decimal](10, 2) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[orders]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[orders](
	[order_id] [int] IDENTITY(1,1) NOT NULL,
	[price] [decimal](10, 2) NOT NULL,
	[date_] [date] NOT NULL,
	[time_] [time](7) NOT NULL,
	[user_id_] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[payment]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payment](
	[payment_id] [int] IDENTITY(1,1) NOT NULL,
	[payment_amount] [decimal](10, 2) NOT NULL,
	[user_id_] [int] NOT NULL,
	[order_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[payment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[products]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[products](
	[product_id] [int] IDENTITY(1,1) NOT NULL,
	[seller_id] [int] NOT NULL,
	[category_id] [int] NOT NULL,
	[product_name] [varchar](225) NOT NULL,
	[description_] [text] NULL,
	[price] [decimal](10, 2) NOT NULL,
	[quantity] [smallint] NOT NULL,
	[is_archived] [bit] NOT NULL,
	[solds_count] [smallint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sellers]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sellers](
	[seller_id] [int] IDENTITY(1,1) NOT NULL,
	[about] [text] NULL,
	[is_active] [bit] NOT NULL,
	[user_name_] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[seller_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_seller_username] UNIQUE NONCLUSTERED 
(
	[user_name_] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[user_acount]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_acount](
	[user_name_] [varchar](50) NOT NULL,
	[password_] [varbinary](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[user_name_] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[users]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[user_id_] [int] IDENTITY(1,1) NOT NULL,
	[user_name_] [varchar](50) NOT NULL,
	[first_name] [varchar](50) NOT NULL,
	[last_name] [varchar](50) NOT NULL,
	[full_name]  AS (([first_name]+' ')+[last_name]),
	[phone] [varchar](25) NULL,
	[email_address] [varchar](50) NOT NULL,
	[user_address] [varchar](100) NULL,
	[is_seller] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id_] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_username] UNIQUE NONCLUSTERED 
(
	[user_name_] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[email_address] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [category_id_index]    Script Date: 10/4/2023 9:37:15 AM ******/
CREATE NONCLUSTERED INDEX [category_id_index] ON [dbo].[products]
(
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [product_name_index]    Script Date: 10/4/2023 9:37:15 AM ******/
CREATE NONCLUSTERED INDEX [product_name_index] ON [dbo].[products]
(
	[product_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [seller_id_index]    Script Date: 10/4/2023 9:37:15 AM ******/
CREATE NONCLUSTERED INDEX [seller_id_index] ON [dbo].[products]
(
	[seller_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cart]  WITH CHECK ADD  CONSTRAINT [fk_cart_user_id] FOREIGN KEY([user_id_])
REFERENCES [dbo].[users] ([user_id_])
GO
ALTER TABLE [dbo].[cart] CHECK CONSTRAINT [fk_cart_user_id]
GO
ALTER TABLE [dbo].[cart_item]  WITH CHECK ADD  CONSTRAINT [fk_cart_id] FOREIGN KEY([cart_id])
REFERENCES [dbo].[cart] ([cart_id])
GO
ALTER TABLE [dbo].[cart_item] CHECK CONSTRAINT [fk_cart_id]
GO
ALTER TABLE [dbo].[cart_item]  WITH CHECK ADD  CONSTRAINT [fk_cart_product_id] FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([product_id])
GO
ALTER TABLE [dbo].[cart_item] CHECK CONSTRAINT [fk_cart_product_id]
GO
ALTER TABLE [dbo].[credit_card]  WITH CHECK ADD  CONSTRAINT [FK_user_id_to_card] FOREIGN KEY([user_id_])
REFERENCES [dbo].[users] ([user_id_])
GO
ALTER TABLE [dbo].[credit_card] CHECK CONSTRAINT [FK_user_id_to_card]
GO
ALTER TABLE [dbo].[delivery]  WITH CHECK ADD  CONSTRAINT [fk_delivey_status] FOREIGN KEY([status_id])
REFERENCES [dbo].[delivey_status] ([status_id])
GO
ALTER TABLE [dbo].[delivery] CHECK CONSTRAINT [fk_delivey_status]
GO
ALTER TABLE [dbo].[delivery]  WITH CHECK ADD  CONSTRAINT [fk_payment_id_to_delivery] FOREIGN KEY([payment_id])
REFERENCES [dbo].[payment] ([payment_id])
GO
ALTER TABLE [dbo].[delivery] CHECK CONSTRAINT [fk_payment_id_to_delivery]
GO
ALTER TABLE [dbo].[delivery]  WITH CHECK ADD  CONSTRAINT [fk_user_id_to_delivey] FOREIGN KEY([user_id_])
REFERENCES [dbo].[users] ([user_id_])
GO
ALTER TABLE [dbo].[delivery] CHECK CONSTRAINT [fk_user_id_to_delivey]
GO
ALTER TABLE [dbo].[order_details]  WITH CHECK ADD  CONSTRAINT [fk_order_id] FOREIGN KEY([order_id])
REFERENCES [dbo].[orders] ([order_id])
GO
ALTER TABLE [dbo].[order_details] CHECK CONSTRAINT [fk_order_id]
GO
ALTER TABLE [dbo].[order_details]  WITH CHECK ADD  CONSTRAINT [fk_product_order_id] FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([product_id])
GO
ALTER TABLE [dbo].[order_details] CHECK CONSTRAINT [fk_product_order_id]
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD  CONSTRAINT [fk_user_id_to_order] FOREIGN KEY([user_id_])
REFERENCES [dbo].[users] ([user_id_])
GO
ALTER TABLE [dbo].[orders] CHECK CONSTRAINT [fk_user_id_to_order]
GO
ALTER TABLE [dbo].[payment]  WITH CHECK ADD  CONSTRAINT [fk_order_id_payment] FOREIGN KEY([order_id])
REFERENCES [dbo].[orders] ([order_id])
GO
ALTER TABLE [dbo].[payment] CHECK CONSTRAINT [fk_order_id_payment]
GO
ALTER TABLE [dbo].[payment]  WITH CHECK ADD  CONSTRAINT [fk_user_id_to_payment] FOREIGN KEY([user_id_])
REFERENCES [dbo].[users] ([user_id_])
GO
ALTER TABLE [dbo].[payment] CHECK CONSTRAINT [fk_user_id_to_payment]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD  CONSTRAINT [fk_category_id] FOREIGN KEY([category_id])
REFERENCES [dbo].[category] ([category_id])
GO
ALTER TABLE [dbo].[products] CHECK CONSTRAINT [fk_category_id]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD  CONSTRAINT [fk_seller_id] FOREIGN KEY([seller_id])
REFERENCES [dbo].[sellers] ([seller_id])
GO
ALTER TABLE [dbo].[products] CHECK CONSTRAINT [fk_seller_id]
GO
ALTER TABLE [dbo].[sellers]  WITH CHECK ADD  CONSTRAINT [FK_user_name_to_sellers] FOREIGN KEY([user_name_])
REFERENCES [dbo].[users] ([user_name_])
GO
ALTER TABLE [dbo].[sellers] CHECK CONSTRAINT [FK_user_name_to_sellers]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [FK_user_name] FOREIGN KEY([user_name_])
REFERENCES [dbo].[user_acount] ([user_name_])
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [FK_user_name]
GO
ALTER TABLE [dbo].[cart]  WITH CHECK ADD CHECK  (([price]>(0)))
GO
ALTER TABLE [dbo].[cart_item]  WITH CHECK ADD CHECK  (([price]>(0)))
GO
ALTER TABLE [dbo].[cart_item]  WITH CHECK ADD CHECK  (([total_amount]>(0)))
GO
ALTER TABLE [dbo].[credit_card]  WITH CHECK ADD CHECK  (([balance]>=(0)))
GO
ALTER TABLE [dbo].[order_details]  WITH CHECK ADD CHECK  (([price]>(0)))
GO
ALTER TABLE [dbo].[order_details]  WITH CHECK ADD CHECK  (([total_amount]>(0)))
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD CHECK  (([price]>(0)))
GO
ALTER TABLE [dbo].[payment]  WITH CHECK ADD  CONSTRAINT [check_amount] CHECK  (([payment_amount]>(0)))
GO
ALTER TABLE [dbo].[payment] CHECK CONSTRAINT [check_amount]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD CHECK  (([price]>(0)))
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD CHECK  (([quantity]>=(0)))
GO
/****** Object:  StoredProcedure [dbo].[add_cart_item]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[add_cart_item](@cart_id int, @product_id int, @amount smallint)
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
GO
/****** Object:  StoredProcedure [dbo].[add_credit_card]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[add_credit_card](@user_id int, @card_num char(16), @cvc char(3), @balance decimal(10,2))
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
GO
/****** Object:  StoredProcedure [dbo].[add_delivery]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[add_delivery](@payment_id int, @user_id int)
as
begin
	declare @user_address varchar(100) = (select user_address from users where user_id_=@user_id);
	insert into delivery(payment_id,user_id_,delivery_date,user_address,status_id)
	values (@payment_id,@user_id, dateadd(day, 3,convert(date,GETDATE())),@user_address,1);
end;
GO
/****** Object:  StoredProcedure [dbo].[add_order]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[add_order](@cart_id int, @user_id int, @card_id int)
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
GO
/****** Object:  StoredProcedure [dbo].[add_seller_info]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[add_seller_info](@username varchar(50), @about text, @isactive bit)
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
GO
/****** Object:  StoredProcedure [dbo].[add_update_product]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[add_update_product]
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
GO
/****** Object:  StoredProcedure [dbo].[add_user]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[add_user]
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
GO
/****** Object:  StoredProcedure [dbo].[add_user_account]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[add_user_account]
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
GO
/****** Object:  StoredProcedure [dbo].[delete_products]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[delete_products](@product_ids varchar(max), @seller_id int)
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

GO
/****** Object:  StoredProcedure [dbo].[get_product_info]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[get_product_info](@seller_id int,
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
		print 'by name';
		set @sqlstring = CONCAT(@sqlstring, @name_filter);
	end;
	if @category_id != 0
	begin
		print 'by category';
		set @sqlstring = CONCAT(@sqlstring, @category_filter);
	end;
	if (@min != -1 ) and (@max != -1)
	begin
		print 'by price range';
		set @sqlstring = CONCAT(@sqlstring, @price_filter);
	end;
	print @sqlstring
	exec(@sqlstring);
end;
GO
/****** Object:  StoredProcedure [dbo].[handle_products_quantities]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[handle_products_quantities](@order_id int)
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
GO
/****** Object:  StoredProcedure [dbo].[init_cart]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[init_cart](@user_id int, @product_id int, @amount smallint)
as
begin
	begin try
		begin transaction
		if exists (select 1 from cart where user_id_ = @user_id)
		begin
			print 'user already has a cart, use add_cart_item proc instead'
			rollback transaction
			return;
		end;
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
GO
/****** Object:  StoredProcedure [dbo].[update_cart_price]    Script Date: 10/4/2023 9:37:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[update_cart_price](@cart_id int)
as
begin

	declare @totalprice decimal(10,2) = (select sum(price) from cart_item
										where cart_id=@cart_id);
	update cart set price = @totalprice where cart_id=@cart_id;
end;
GO
USE [master]
GO
ALTER DATABASE [store] SET  READ_WRITE 
GO
