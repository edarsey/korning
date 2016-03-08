-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS frequencies;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;


CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  customer_name VARCHAR(255),
  account_number VARCHAR(255)
);

CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  employee_name VARCHAR(255),
  email VARCHAR(255)
);

CREATE TABLE frequencies (
  id SERIAL PRIMARY KEY,
  frequency VARCHAR(255)
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  product_name VARCHAR(255)
);

CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  invoice_number VARCHAR(255),
  sale_date DATE,
  sale_amount VARCHAR(255),
  units_sold VARCHAR(255),
  customer_id INTEGER REFERENCES customers (id),
  employee_id INTEGER REFERENCES employees (id),
  frequency_id INTEGER REFERENCES frequencies (id),
  product_id INTEGER REFERENCES products (id)
);
