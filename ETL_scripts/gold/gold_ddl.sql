/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/ 

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

CREATE VIEW gold.dim_customers AS 
SELECT * FROM silver.customers_cleaned;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

CREATE VIEW gold.dim_products AS 
SELECT * FROM silver.products_cleaned;

-- =============================================================================
-- Create Dimension: gold.dim_return
-- =============================================================================

CREATE VIEW gold.dim_return AS 
SELECT * FROM silver.return_cleaned;

-- =============================================================================
-- Create Fact Table: gold.fact_orders
-- =============================================================================

CREATE VIEW gold.fact_orders AS 
SELECT * FROM silver.orders_cleaned;