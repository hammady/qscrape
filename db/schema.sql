drop table if exists vehicles;
create table vehicles (
  id int primary key,
  title text,
  url text,
  brand_id int,
  model int,
  mileage text,
  price text,
  contact_number text,
  vtype text,
  description text,
  submit_date text,
  submit_time text,
  others text,
  notified_at datetime
);

drop table if exists brands;
create table brands (
  id int primary key,
  name text
);
