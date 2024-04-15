---- AVG ----

-- 1. Obtener el promedio de precios por cada categoría de producto. La cláusula
-- OVER(PARTITION BY CategoryID) específica que se debe calcular el promedio de
-- precios por cada valor único de CategoryID en la tabla.

select c.category_name , p.product_name ,  
avg(p.unit_price) over (partition by p.category_id)
from products p
inner join categories c ON p.category_id = c.category_id 

-- 2. Obtener el promedio de venta de cada cliente

select c.customer_id , c. company_name ,
avg(od.unit_price * od.quantity) over (partition by o.customer_id) as avgsales
from customers c , order_details od 
inner join orders o on o.order_id = od.order_id 
where c.customer_id = o.customer_id 

-- 3. Obtener el promedio de cantidad de productos vendidos por categoría (product_name,
-- quantity_per_unit, unit_price, quantity, avgquantity) y ordenarlo por nombre de la
-- categoría y nombre del producto

select p.product_name  ,c.category_name , p.quantity_per_unit , od.unit_price , od.quantity , 
avg(od.quantity) over (partition by c.category_id) as avgqty
from categories c , order_details od 
inner join products p on od.product_id = p.product_id 
where c.category_id = p.category_id 
order by c.category_name , p.product_name 

---- MIN ---- 

-- 4. Selecciona el ID del cliente, la fecha de la orden y la fecha más antigua de la
-- orden para cada cliente de la tabla 'Orders'. 

select o.customer_id , o.order_date , 
min(order_date) over (partition by o.customer_id)
from orders o 

---- MAX ---- 

-- 5. Seleccione el id de producto, el nombre de producto, el precio unitario, el id de
-- categoría y el precio unitario máximo para cada categoría de la tabla Products

select p.product_id , p.product_name , p.unit_price , p.category_id , 
max(p.unit_price) over (partition by p.category_id)
from products p 

---- Row_number ---- 

-- 6. Obtener el ranking de los productos más vendidos. 

select  p.product_name, sq.qty_sum, 
row_number() over (order by sq.qty_sum desc) as ranking
from (select od.product_id  , sum(od.quantity) qty_sum
	  from order_details od 
      group by od.product_id) as sq,
      products p 
where sq.product_id = p.product_id 

-- 7. Asignar numeros de fila para cada cliente, ordenados por customer_id

select 
row_number () over (order by c.customer_id),
c.*
from customers c 

-- 8. Obtener el ranking de los empleados más jóvenes () ranking, nombre y apellido del
-- empleado, fecha de nacimiento)

select 
row_number () over (order by e.birth_date desc) ,
concat(e.first_name , ' ' , e.last_name) employees , e.birth_date 
from employees e 
