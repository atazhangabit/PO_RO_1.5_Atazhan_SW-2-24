Atyrau Septic Service Management System

This project is a PostgreSQL database for septic tank cleaning services in Atyrau.

Database: septic_service_db
Schema: septic_service

The database contains 8 tables:

customers, addresses, service_types, vehicles, drivers, service_orders, order_services and payments.
The order_services table creates a many-to-many relationship between service_orders and service_types.
The project includes primary keys, foreign keys, constraints, default values, generated columns, ALTER TABLE, INSERT, UPDATE, DELETE, GRANT and REVOKE.

How to run:
1. Create the septic_service_db database.
2. Open 02_final.sql in DBeaver.
3. Run the whole script.
4. Refresh the septic_service schema.