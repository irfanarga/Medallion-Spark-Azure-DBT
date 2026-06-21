{{
  config(
    materialized = "table",
    file_format = "delta",
    location_root = "abfss://gold@medallionsanew.dfs.core.windows.net/",
    target_catalog = 'medallion_spark_databricks',
    invalidate_hard_deletes = True
  )
}}

with address_snapshot as (
  select
    AddressID,
    AddressLine1,
    AddressLine2,
    City,
    StateProvince,
    CountryRegion,
    PostalCode
  from {{ ref('address') }}
  where dbt_valid_to is null
)

, customer_snapshot as (
  select
    CustomerID,
    concat(ifnull(FirstName, ''), ' ', ifnull(MiddleName, ''), ' ', ifnull(LastName, '')) as FullName
  from {{ ref('customer') }}
  where dbt_valid_to is null
)

, customeraddress_snapshot as (
  select
    CustomerID,
    AddressID,
    AddressType
  from {{ ref('customeraddress') }}
  where dbt_valid_to is null
)

, transformed as (
  select
    row_number() over (order by customer_snapshot.customerid) as customer_sk,
    customer_snapshot.customerid,
    customer_snapshot.fullname,
    customeraddress_snapshot.addressid,
    customeraddress_snapshot.addresstype,
    address_snapshot.addressline1,
    address_snapshot.city,  
    address_snapshot.stateprovince,
    address_snapshot.countryregion,
    address_snapshot.postalcode
  from customer_snapshot
  inner join customeraddress_snapshot on customer_snapshot.customerid = customeraddress_snapshot.customerid
  inner join address_snapshot on customeraddress_snapshot.addressid = address_snapshot.addressid
)

select * from transformed