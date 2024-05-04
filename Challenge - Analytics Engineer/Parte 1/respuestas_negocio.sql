--Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500.

CREATE TABLE Respuesta_1 AS SELECT
	a.customer_id, a.nombre, a.apellido, a.fecha_nacimiento
	FROM Customer a INNER JOIN "Order" b ON (a.customer_id = b.customer_id)
	WHERE TO_CHAR(a.fecha_nacimiento, 'MM-DD') = TO_CHAR(SYSDATE, 'MM-DD')
	AND EXTRACT(MONTH FROM b.order_date) = 1
	AND EXTRACT(YEAR FROM b.order_date) = 2020
	GROUP BY a.customer_id, a.nombre, a.apellido, a.fecha_nacimiento
	HAVING COUNT(b.order_id) > 1500;
	

--Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. 
--Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, 
--cantidad de productos vendidos y el monto total transaccionado.

CREATE TABLE Ventas_Usuario AS SELECT
		EXTRACT(MONTH FROM a.order_date) AS mes,
        EXTRACT(YEAR FROM a.order_date) AS anio,
        b.nombre,
        b.apellido,
    COUNT(a.order_id) AS cantidad_ventas,
    SUM(c.precio) AS monto_total,
    ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM a.order_date), a.customer_id ORDER BY SUM(c.precio) DESC) AS rank
    FROM "Order" a INNER JOIN Customer b on (a.customer_id = b.customer_id)
    	 		     INNER JOIN Item c on (a.item_id = c.item_id)
    	 		     INNER JOIN Category d on (c.category_id = d.category_id)
    WHERE EXTRACT(YEAR FROM a.order_date) = 2020
    AND d.descripcion = 'Celulares'
    GROUP BY EXTRACT(MONTH FROM a.order_date),
        	 EXTRACT(YEAR FROM a.order_date),
        	 a.customer_id,
        	 b.nombre,
        	 b.apellido;

CREATE TABLE Respuesta_2 AS SELECT
	mes, anio, nombre, apellido, cantidad_ventas, monto_total 
	FROM Ventas_Usuario
	WHERE rank <= 5;


--Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día. Tener en cuenta que debe ser reprocesable. 
--Vale resaltar que en la tabla Item, vamos a tener únicamente el último estado informado por la PK definida. 
--(Se puede resolver a través de StoredProcedure) 

--Crear la nueva tabla
CREATE TABLE Items_Estado_Diario ( 
    item_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    fecha_baja DATE,
    precio NUMBER,
    estado VARCHAR2(20)
);

--Creación del SP
CREATE OR REPLACE PROCEDURE Poblar_Item_St (
    p_table_name IN VARCHAR2,
    p_date IN DATE
) AS
BEGIN
    -- Eliminar registros existentes en la tabla de destino
    EXECUTE INMEDIATE 'DELETE FROM ' || p_table_name;

    -- Insertar los datos más recientes de la tabla de ítems
    EXECUTE INMEDIATE '
    INSERT INTO' || p_table_name || '(item_id, nombre, fecha_baja, precio, estado)
         SELECT item_id, nombre, fecha_baja, precio, estado
         FROM Item
         WHERE (item_id, fecha_baja) IN
               (SELECT item_id,
                       MAX(fecha_baja)
                FROM Item
                WHERE fecha_baja <= TRUNC(:p_date) + INTERVAL '1' DAY
                GROUP BY item_id)
                ' USING p_date;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END Poblar_Item_St;
/

--Ejecución del SP

BEGIN
     Poblar_Item_St('Items_Estado_Diario', SYSDATE);
END;
/