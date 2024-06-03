---- AVG ----
-- 1. Obtener el promedio de precios por cada categoría de producto. La cláusula
-- OVER(PARTITION BY CategoryID) específica que se debe calcular el promedio de
-- precios por cada valor único de CategoryID en la tabla.

select
	c.category_name ,
	p.product_name ,
	avg(p.unit_price) over (partition by p.category_id) avg_prices
from
	products p
inner join categories c 
on
	p.category_id = c.category_id;


-- 2. Obtener el promedio de venta de cada cliente

select
	c.customer_id ,
	c. company_name ,
	avg(od.unit_price * od.quantity) over (partition by o.customer_id) as avgsales
from
	customers c ,
	order_details od
inner join orders o on
	o.order_id = od.order_id
where
	c.customer_id = o.customer_id;

-- 3. Obtener el promedio de cantidad de productos vendidos por categoría (product_name,
-- quantity_per_unit, unit_price, quantity, avgquantity) y ordenarlo por nombre de la
-- categoría y nombre del producto

select
	p.product_name ,
	c.category_name ,
	p.quantity_per_unit ,
	od.unit_price ,
	od.quantity ,
	avg(od.quantity) over (partition by c.category_id) as avgqty
from
	categories c ,
	order_details od
inner join products p on
	od.product_id = p.product_id
where
	c.category_id = p.category_id
order by
	c.category_name ,
	p.product_name;

---- MIN ---- 
-- 4. Selecciona el ID del cliente, la fecha de la orden y la fecha más antigua de la
-- orden para cada cliente de la tabla 'Orders'. 

select
	o.customer_id ,
	o.order_date ,
	min(o.order_date) over (partition by o.customer_id)
from
	orders o;

---- MAX ---- 
-- 5. Seleccione el id de producto, el nombre de producto, el precio unitario, el id de
-- categoría y el precio unitario máximo para cada categoría de la tabla Products

select
	p.product_id ,
	p.product_name ,
	p.unit_price ,
	p.category_id ,
	max(p.unit_price) over (partition by p.category_id)
from
	products p;

---- Row_number ---- 

-- 6. Obtener el ranking de los productos más vendidos. 
-- Forma 1 
-- select  p.product_name, sq.qty_sum, 
-- row_number() over (order by sq.qty_sum desc) as ranking
-- from (select od.product_id  , sum(od.quantity) qty_sum
-- 	    from order_details od 
--      group by od.product_id) as sq,
--      products p 
--where sq.product_id = p.product_id 
-- Forma 2

-- 6. Obtener el ranking de los productos más vendidos. 

select
	od.product_id ,
	p.product_name ,
	sum(od.quantity) qty_sum ,
	row_number() over (
	order by sum(od.quantity)desc) as ranking
from
	order_details od
join products p 
on
	od.product_id = p.product_id
group by
	od.product_id ,
	p.product_name;

-- 7. Asignar numeros de fila para cada cliente, ordenados por customer_id

select
	row_number () over (
	order by c.customer_id),
	c.*
from
	customers c;
	
-- 8. Obtener el ranking de los empleados más jóvenes () ranking, nombre y apellido del
-- empleado, fecha de nacimiento)

select
	row_number () over (
	order by e.birth_date desc) ,
	concat(e.first_name ,
	' ' ,
	e.last_name) employees ,
	e.birth_date
from
	employees e;
	
---- SUM
-- 9. Obtener la suma de venta de cada cliente

select 
	sum(od.unit_price * od.quantity) over (partition by o.customer_id),
	od.order_id , 
	c.customer_id , 
	c.company_name ,
	o.*
from
	customers c ,
	order_details od
inner join orders o 
on
	o.order_id = od.order_id
where
	c.customer_id = o.customer_id;

-- 10. Obtener la suma total de ventas por categoría de producto

select
	c.category_name ,
	sum(od.unit_price * od.quantity) over (partition by p.category_id),
	p.product_name ,
	od.unit_price ,
	od.quantity
from
	categories c ,
	order_details od
inner join products p  
on
	od.product_id = p.product_id
where
	c.category_id = p.category_id;

-- 11. Calcular la suma total de gastos de envío por país de destino, 
-- luego ordenarlo por país y por orden de manera ascendente
-- freight es flete, costo economico del transporte. 

select
	o.ship_country,
	o.order_id ,
	sum(o.freight) over (partition by o.ship_country)
from
	orders o
order by
	ship_country ,
	o.order_id;

---- RANK ----
-- 12. Ranking de ventas por cliente

select
	o.customer_id,
	sum(od.quantity * od.unit_price) sales ,
	rank() over (
	order by sum(od.quantity * od.unit_price) desc)
from
	order_details od
inner join orders o
on
	o.order_id = od.order_id
group by
	o.customer_id;

-- 13. Ranking de empleados por fecha de contratacion

select
	rank() over (
	order by e.hire_date) hire_date_rank,
	e.*
from
	employees e;

-- 14. Ranking de productos por precio unitario

select
	p.product_name ,
	p.product_id ,
	p.unit_price ,
	rank() over (
	order by unit_price desc) as rank
from
	products p;

---- LAG ---- 
-- 15. Mostrar por cada producto de una orden, la cantidad vendida y la cantidad
-- vendida del producto previo.

select
	od.order_id ,
	od.product_id ,
	od.quantity ,
	lag(od.quantity) over (
	order by od.order_id asc) as previous_qty
from
	order_details od;

-- 16. Obtener un listado de ordenes mostrando el id de la orden, fecha de orden, id del cliente
-- y última fecha de orden.

select
	o.order_id ,
	o.order_date ,
	o.customer_id ,
	lag(o.order_date) over (
	order by o.customer_id ,
	o.order_date  asc)
from
	orders o;

-- 17. Obtener un listado de productos que contengan: id de producto, nombre del producto,
-- precio unitario, precio del producto anterior, diferencia entre el precio del producto y
-- precio del producto anterior.

select
	p.product_name ,
	p.product_id ,
	p.unit_price ,
	lag(p.unit_price) over (
	order by p.product_id) previous_price,
	(p.unit_price - lag(p.unit_price) over (
	order by p.product_id) ) diff_prices
from
	products p

---- LEAD ---- 
-- 18 Obtener un listado que muestra el precio de un producto junto con el precio del producto
-- siguiente:

select
	p.product_name ,
	p.unit_price ,
	lead (p.unit_price) over (
	order by p.product_id asc)
from
	products p

-- 19. Obtener un listado que muestra el total de ventas por categoría de producto junto con el
-- total de ventas de la categoría siguiente

select
	sq2.*,
	lead(sq2.sum_category) over (
	order by sq2.category_name)
from
	(
	select
		distinct on
		(c.category_name) c.category_name,
		sum(sq.sum_product_id) over (partition by c.category_name
	order by
		category_name) as sum_category
	from
		(
		select
			distinct on
			(od.product_id) od.product_id,
			sum(od.unit_price * od.quantity) over (partition by od.product_id) sum_product_id
		from
			order_details od ) sq,
		categories c,
		products p
	where
		sq.product_id = p.product_id
		and p.category_id = c.category_id
) sq2



