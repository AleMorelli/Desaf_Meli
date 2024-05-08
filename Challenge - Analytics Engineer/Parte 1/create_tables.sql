-- Crear la tabla Customer
CREATE TABLE Customer (
    customer_id NUMBER PRIMARY KEY,
    email VARCHAR2(100),
    nombre VARCHAR2(50),
    apellido VARCHAR2(50),
    sexo CHAR(1),
    direccion VARCHAR2(100),
    fecha_nacimiento DATE,
    telefono VARCHAR2(20)
);

-- Crear la tabla Order
CREATE TABLE "Order" (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    order_date DATE,
    monto_total NUMBER,
    estado VARCHAR2(20),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- Crear la tabla Item
CREATE TABLE Item (
    item_id NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    precio NUMBER,
    estado VARCHAR2(20),
    fecha_baja DATE,
    category_id NUMBER,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- Crear la tabla Category
CREATE TABLE Category (
    category_id NUMBER PRIMARY KEY,
    descripcion VARCHAR2(100),
    path VARCHAR2(100)
);
