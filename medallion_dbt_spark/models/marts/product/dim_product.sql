{{
    config(
        materialized = "table",
        file_format = "delta",
        location_root = "abfss://gold@medallionsanew.dfs.core.windows.net/",
        target_catalog = 'medallion_spark_databricks',
        invalidate_hard_deletes = True
    )
}}

with product_snapshot as (
  select
    ProductID,
    Name,
    StandardCost,
    ListPrice,
    Size,
    Weight,
    ProductCategoryID,
    ProductModelID,
    SellStartDate,
    SellEndDate,
    DiscontinuedDate
  from {{ ref('product') }}
  where dbt_valid_to is null -- Mengambil data aktif saat ini
)

, product_model_snapshot as (
    select
      ProductModelID,
      Name,
      CatalogDescription, -- DIPERBAIKI: Ditambahkan tanda koma di sini
      row_number() over (order by name) as model_id
    from {{ ref('productmodel') }}
    where dbt_valid_to is null -- Mengambil data aktif saat ini
)

, transformed as (
    select
        row_number() over (order by product_snapshot.productid) as product_sk,
        product_snapshot.name as product_name,
        product_snapshot.standardcost,
        product_snapshot.listprice,
        product_snapshot.size,
        product_snapshot.weight,
        product_model_snapshot.name as model,
        product_model_snapshot.catalogdescription,
        product_snapshot.sellstartdate,
        product_snapshot.sellenddate,
        product_snapshot.discontinueddate
    from product_snapshot
    left join product_model_snapshot on product_snapshot.productmodelid = product_model_snapshot.productmodelid
)

select * from transformed