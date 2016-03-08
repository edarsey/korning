# Use this file to import the sales information into the
# the database.
require "csv"
require "pg"
require "pry"


def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

@data = []
CSV.foreach('sales.csv', headers: true, header_converters: :symbol ) do |row|
  @data << row.to_h
end

@customers = {}
@data.each do |datum|
  customer = datum[:customer_and_account_no].split("(")
  cust_name = customer[0].strip
  acc_num = customer[1].gsub(/[()]/, "").strip
  @customers[cust_name] = acc_num
end

@employees = {}
@data.each do |datum|
  employee = datum[:employee].split("(")
  e_name = employee[0].strip
  e_email = employee[1].gsub(/[()]/, "").strip
  @employees[e_name] = e_email
end

@frequencies = {}
counter = 0
@data.each do |datum|
  if !@frequencies.has_value?(datum[:invoice_frequency])
    @frequencies[counter += 1] = datum[:invoice_frequency].strip
  end
end

@products = {}
counter = 0
@data.each do |datum|
  if !@products.has_value?(datum[:product_name])
    @products[counter += 1] = datum[:product_name].strip
  end
end

@sales = []



db_connection do |conn|
  @customers.each do |key, value|
    conn.exec("INSERT INTO customers (customer_name, account_number) VALUES ('#{key}', '#{value}');")
  end
  @employees.each do |key, value|
    conn.exec("INSERT INTO employees (employee_name, email) VALUES ('#{key}', '#{value}');")
  end
  @frequencies.each do |key, value|
    conn.exec("INSERT INTO frequencies (frequency) VALUES ('#{value}');")
  end
  @products.each do |key, value|
    conn.exec("INSERT INTO products (product_name) VALUES ('#{value}');")
  end
  @data.each do |each_sale|
    conn.exec("INSERT INTO sales
    (invoice_number, sale_date, sale_amount, units_sold, customer_id, employee_id, frequency_id, product_id)
    VALUES ('#{each_sale[:invoice_no]}',
    '#{each_sale[:sale_date]}',
    '#{each_sale[:sale_amount]}',
    '#{each_sale[:units_sold]}',
    (SELECT customers.id FROM customers WHERE customer_name LIKE '#{each_sale[:customer_and_account_no].split[0]}%'),
    (SELECT employees.id FROM employees WHERE employee_name LIKE '#{each_sale[:employee].split[0]}%'),
    (SELECT frequencies.id FROM frequencies WHERE frequency = '#{each_sale[:invoice_frequency]}'),
    (SELECT products.id FROM products WHERE product_name = '#{each_sale[:product_name]}'))
    ;")
  end
end

#       (SELECT customers.id FROM customers WHERE customer_name LIKE '#{each_sale[:customer_and_account_no].split[0]}%'),
#       (SELECT employees.id FROM employees WHERE employee_name LIKE '#{each_sale[:employee].split[0]}%'));")

#
#
#
# # end
# # # @data.each do |each_sale|
# # #   conn.exec("INSERT INTO sales
# #   (invoice_number, sale_date, sale_amount, units_sold, frequency_id, product_id)
# #   VALUES ('#{each_sale[:invoice_no]}',
# #   '#{each_sale[:sale_date]}',
# #   '#{each_sale[:sale_amount]}',
# #   '#{each_sale[:units_sold]}',
# #   (SELECT frequencies.id FROM frequencies WHERE frequency = '#{each_sale[:invoice_frequency]}'),
# #   (SELECT products.id FROM products WHERE product_name = '#{each_sale[:product_name]}'))
# #   ;")
# # end
# @data.each do |each_sale|
#   # binding.pry
#   conn.exec("INSERT INTO sales (customer_id, employee_id)
#   VALUES (
#     (SELECT customers.id FROM customers WHERE customer_name LIKE '#{each_sale[:customer_and_account_no].split[0]}%'),
#     (SELECT employees.id FROM employees WHERE employee_name LIKE '#{each_sale[:employee].split[0]}%'));")
# end
