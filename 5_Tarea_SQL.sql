------------- Ejercicios SQL Bootcamp -------------

---- SELECT DISTINTC ----

-- 1. Obtener una lista de todas las categorias distintas

select distinct c.category_name 
from categories c;

-- 2. Obtener una lista de todas las regiones distintas de los clientes. 

select distinct c.region 
from customers c;
--where region notnull 

-- 3. Obtener una lista de todos los títulos de contacto distintos. 

select distinct c.contact_title 
from customers c;

---- ORDER BY ---- 

-- 4. Obtener una lista de todos los clientes, ordenados por país:

select * 
from customers c 
order by c.country;

-- 5. Obtener una lista de todos los pedidos, ordenados por id del empleado 
-- y fecha del pedido:

select * 
from orders o  
order by o.employee_id, o.order_date;

---- INSERT INTO ---- 

-- 6. Insertar un nuevo cliente en la tabla Customers:

insert into customers (customer_id, company_name, contact_name, contact_title, address)
values ('MATVZ', 'Escuela de Datos Vivos', 'Matias Vazques', 'Accounting Manager', 'Av Siempre Viva 123');

select * 
from customers c 
where customer_id = 'MATVZ';

-- 7. insertar una nueva región en la tabla Región:

--DELETE FROM public.region
--WHERE region_id=5;

insert into public.region (region_id, region_description)
values (5, 'Central');

select * from region r 

---- NULL - COALESCE ---- 

-- 8. Obtener todos los clientes de la tabla Customers donde el campo Región es NULl.

select * 
from customers c 
where c.region isnull;

-- 9. Obtener Product_Name y Unit_Price de la tabla Products, y si Unit_Price es NULL, 
-- use el precio estándar de $10 en su lugar:

select p.product_name , coalesce (p.unit_price, '10')
from products p;

---- INNER JOIN ----- 

-- 10. Obtener el nombre de la empresa, el nombre del contacto y la fecha del pedido
-- de todos los pedidos:

select c.company_name, c.contact_name, o.order_date 
from orders o inner join customers c 
on o.customer_id = c.customer_id;

-- 11. Obtener la identificación del pedido, el nombre del producto y el descuento 
-- de todos los detalles del pedido y productos:

select od.order_id , p.product_name , od.discount  
from order_details od inner join products p
on od.product_id  = p.product_id;

---- LEFT JOIN ---- 

-- 12. Obtener el identificador del cliente, el nombre de la compañía, el 
-- identificador y la fecha de la orden de todas las órdenes y aquellos clientes 
-- que hagan match.

select c.customer_id , c.company_name , o.order_id , o.order_date 
from orders o left join customers c 
on o.customer_id  = c.customer_id;

-- 13. Obtener el identificador del empleados, apellido, identificador de territorio 
-- y descripción del territorio de todos los empleados y aquellos que hagan match 
-- en territorios:

select sq.employee_id , e.last_name , sq.territory_id , sq.territory_description
from employees e left join (select et.employee_id , t.territory_id , t.territory_description 
							from employee_territories et left join territories t 
							on et.territory_id = t.territory_id ) sq
on e.employee_id = sq.employee_id;

-- Otra que se me ocurrio para evitar la subquery

select et.employee_id , t.territory_id , t.territory_description , e.last_name 
from employees e  , employee_territories et left join territories t 
on et.territory_id = t.territory_id 
where e.employee_id = et.employee_id;


-- 14. Obtener el identificador de la orden y el nombre de la empresa de todos las 
-- órdenes y aquellos clientes que hagan match:

select o.order_id , c.company_name 
from orders o left join customers c 
on o.customer_id = c.customer_id;

-- 15. Obtener el identificador de la orden, y el nombre de la compañía de todas las 
-- órdenes y aquellos clientes que hagan match:

select o.order_id , c.company_name 
from orders o right join customers c 
on o.customer_id = c.customer_id;

-- 16. Obtener el nombre de la compañía, y la fecha de la orden de todas las órdenes y
-- aquellos transportistas que hagan match. Solamente para aquellas ordenes del año
-- 1996:

select s.company_name , sq.order_date
from shippers s right join (select o.order_date , o.ship_via shippers
							from customers c right join orders o 
							on c.customer_id = o.customer_id) sq
on s.shipper_id = sq.shippers
where sq.order_date between '1996-01-01' and '1996-12-31';

-- Una que se me ocurriṕo par aevitar la subquery 

select s.company_name , o.order_date
from shippers s , customers c 
right join orders o on c.customer_id = o.customer_id
where s.shipper_id = o.ship_via 
and o.order_date between '1996-01-01' and '1996-12-31';

----- FULL OUTER JOIN ----

-- 17. Obtener nombre y apellido del empleados y el identificador de territorio, de todos los
-- empleados y aquellos que hagan match o no de employee_territories:

select e.first_name , e.last_name , et.territory_id 
from employees e full outer join employee_territories et 
on e.employee_id = et.employee_id;

-- 18. Obtener el identificador de la orden, precio unitario, cantidad y total de todas las
-- órdenes y aquellas órdenes detalles que hagan match o no:

select o.order_id , od.unit_price , od.quantity , (od.unit_price * od.quantity) total 
from orders o full outer join order_details od 
on o.order_id = od.order_id;

-- El siguiente es el script que suma de las cantidades para un order_id, me confundi con el
-- enunciado, el resultado correcto es el anterior. 

select o.order_id , od.unit_price , od.quantity , 
sum(od.quantity) over (partition by o.order_id) as total
from orders o full outer join order_details od 
on o.order_id = od.order_id;

---- UNION ----
-- 19. Obtener la lista de todos los nombres de los clientes y los nombres de los proveedores:

select c.company_name Nombre
from customers c 
union 
select s.company_name Nombre
from suppliers s;

-- 20. Obtener la lista de los nombres de todos los empleados y los nombres de los gerentes
-- de departamento.

select e.first_name
from employees e 
where e.employee_id in (select e2.reports_to
						from employees e2)
union 
select e3.first_name
from employees e3;


---- SUBQUERIES ---- 

-- 21. Obtener los productos del stock que han sido vendidos:

select p.product_name, p.product_id  
from products p 
where p.units_in_stock > 0
and product_id in (select od.product_id
				   from order_details od); 
				  
-- 22. Obtener los clientes que han realizado un pedido con destino a Argentina:
				  
select c.company_name 
from customers c 
where c.customer_id in (select o.customer_id
						from orders o
						where o.ship_country like 'Argentina');			

-- 23. Obtener el nombre de los productos que nunca han sido pedidos por clientes 
-- de Francia. 
						
--select p.product_name 
--from products p 
--where p.product_id in (select od.product_id
--					   from order_details od 
--					   where od.order_id in (select o.order_id
--					   					     from orders o 
--					   					     where o.ship_country not like 'France'
--						   					)
--					  );
					 
SELECT p.product_name 
FROM products p 
WHERE p.product_id NOT IN (
    SELECT od.product_id
    FROM order_details od 
    INNER JOIN orders o ON od.order_id = o.order_id
    WHERE o.ship_country = 'France'
);
				  
---- GROUP BY ---- 

-- 24. Obtener la cantidad de productos vendidos por identificador de orden:
					  
select od.order_id , sum (od.quantity)
from order_details od 
group by od.order_id 

-- 25. Obtener el promedio de productos en stock por producto

select p.product_name  , avg(p.units_in_stock) 
from products p 
group by p.product_name 

---- HAVING ---- 

-- 26. Cantidad de productos en stock por producto, donde haya más de 100 
-- productos en stock

select p.product_name , avg (p.units_in_stock)
from products p 
group by p.product_name, p.units_in_stock 
having p.units_in_stock  > 100

-- 27. Obtener el promedio de pedidos por cada compañía y solo mostrar aquellas con un
-- promedio de pedidos superior a 10:

select sq.company_name , avg(sq.order_id) 
from (select c.company_name , o.order_id
	  from orders o 
	  inner join customers c on o.customer_id = c.customer_id) sq
group by sq.company_name 
having avg(sq.order_id) > 10;

---- CASE ----

-- 28. Obtener el nombre del producto y su categoría, pero muestre "Discontinued" en lugar
-- del nombre de la categoría si el producto ha sido descontinuado.

select p.product_name ,
case 
when discontinued = 0 then c.category_name 
else 'Discontinued' 
end as category 
from products p inner join categories c 
on p.category_id = c.category_id;

-- 29. Obtener el nombre del empleado y su título, pero muestre "Gerente de Ventas" en lugar
-- del título si el empleado es un gerente de ventas (Sales Manager):

select e.first_name , e.last_name ,
case 
	when e.title like 'Sales Manager' then 'Gerente de Ventas'
	else e.title 
	end as job_title
from employees e;
