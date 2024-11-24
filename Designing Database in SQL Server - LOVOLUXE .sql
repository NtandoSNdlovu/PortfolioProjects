-- step 1: tables with no foreign key dep
create table race
( 
  id int identity (1,1) primary key, 
  race varchar(30) not null 
);

create table primarycolour
( 
  primarycolourid int identity (1,1) primary key, 
  colour varchar(30) not null 
);

create table secondarycolour
( 
  secondarycolourid int identity (1,1) primary key, 
  colour varchar(30) not null 
);

create table logocolour
( 
  logocolourid int identity (1,1) primary key, 
  colour varchar(30) not null 
);

create table productstatus
( 
  id int primary key identity (1,1), 
  productstatus varchar(30) not null 
);

create table size
( 
  id int identity (1,1) primary key, 
  generalsize nvarchar(10) not null, 
  trousersize nvarchar(10) null,
  waistsize_cm nvarchar(10) null,
  bustsize_cm nvarchar(10) null,
  hipssize_cm nvarchar(10) null
);

-- step 2: tables with foreign key dep but referencing the tables already created
create table director
( 
  id int identity (1,1) primary key, 
  name varchar(30) not null, 
  middlename varchar(30) null, 
  surname varchar(30) not null, 
  age float null, 
  gender varchar(10) not null, 
  raceid int foreign key references race(id), 
  startdate date not null, 
  enddate date null, 
  addressline1 varchar(60) not null, 
  addressline2 varchar(60) null, 
  city varchar(30) not null, 
  province varchar(30) not null, 
  zipcode varchar(10) not null, 
  country varchar(30) not null, 
  email varchar(60) not null, 
  contactnumber1 varchar(30) not null, 
  contactnumber2 varchar(30) null, 
  createddate datetime default getdate() 
);

create table salesperson
( 
  id int identity (1,1) primary key, 
  name varchar(30) not null, 
  middlename varchar(30) null, 
  surname varchar(30) not null, 
  age float null, 
  gender varchar(10) not null, 
  raceid int foreign key references race(id),
  startdate date not null, 
  addressline1 varchar(60) not null, 
  addressline2 varchar(60) null, 
  city varchar(30) not null, 
  province varchar(30) not null, 
  zipcode varchar(10) not null, 
  country varchar(30) not null, 
  email varchar(60) not null, 
  contactnumber1 varchar(30) null, 
  contactnumber2 varchar(30) null, 
  createddate datetime default getdate() 
);

create table supplier
( 
  id int primary key, 
  name varchar(30) not null, 
  contactname varchar(30) null, 
  contactnumber varchar(30) null, 
  url_address nvarchar(250) null, 
  addressline1 varchar(60) null, 
  addressline2 varchar(60) null, 
  city varchar(30) null, 
  province varchar(30) null, 
  zipcode varchar(10) null, 
  country varchar(30) not null, 
  contactpersonname varchar(30) null, 
  contactpersonnumber varchar(30) null, 
  email varchar(60) null, 
  createddate datetime default getdate() 
);

create table customer
( 
  id int identity (1,1) primary key, 
  name varchar(30) not null, 
  middlename varchar(30) null, 
  surname varchar(30) null, 
  addressline1 varchar(60) not null, 
  addressline2 varchar(60) null, 
  city varchar(30) not null, 
  province varchar(30) not null, 
  zipcode varchar(10) not null, 
  country varchar(30) not null, 
  email varchar(60) null, 
  contactnumber varchar(30) null, 
  createddate datetime default getdate() 
);

-- step 3: tables with foreign key references to the above tables
create table product
( 
  id int identity (1,1) primary key, 
  lovoproductname varchar(255) not null, 
  supplierproductname varchar(255) not null, 
  productcode varchar(60) null, 
  supplierid int foreign key references supplier(id), 
  sizeid int foreign key references size(id), 
  primarycolourid int foreign key references primarycolour(primarycolourid) not null, 
  secondarycolourid int foreign key references secondarycolour(secondarycolourid), 
  logocolourid int foreign key references logocolour(logocolourid), 
  logosize_positiondescription varchar(255) null, 
  productdescription varchar(255) null, 
  productcost float not null, 
  shippingcost float null, 
  customisationcost float not null, 
  packagingcost float not null, 
  customs float null, 
  totalunitcost float not null, 
  listingprice float not null, 
  expectedmarkup float not null, 
  inventoryonhand int null, 
  productstatusid int foreign key references productstatus(id), 
  createddate datetime default getdate() 
);

create table salesorderheader
( 
  salesorderid int identity (1001,1) primary key, 
  orderdate date not null, 
  shipdate date not null, 
  carriertrackingnumber varchar(60), 
  customerid int foreign key references customer(id), 
  addressline1 varchar(60) not null, 
  addressline2 varchar(60) null, 
  city varchar(30) not null, 
  province varchar(30) not null, 
  zipcode varchar(10) not null, 
  country varchar(30) not null, 
  subtotal float, 
  shippingcost float, 
  orderdiscount float, 
  totaldue float, 
  createddate datetime default getdate() 
);

create table salesorderdetail
( 
  salesorderdetailid int identity (0001,1) primary key, 
  salesorderid int foreign key references salesorderheader(salesorderid), 
  quantity int not null, 
  productid int foreign key references product(id), 
  unitprice float not null, 
  unitpricediscount float not null, 
  linetotal float not null, 
  createddate datetime default getdate() 
);
