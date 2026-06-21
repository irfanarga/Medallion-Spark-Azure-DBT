{{
    config(
        materialized = "table",
        file_format = "delta",
        location_root = "abfss://gold@medallionsanew.dfs.core.windows.net/",
        target_catalog = 'medallion_spark_databricks',
        invalidate_hard_deletes = True
    )
}}

with salesorderdetail_snapshot as (
  select
    SalesOrderID,
    SalesOrderDetailID,
    OrderQty,
    ProductID,
    UnitPrice,
    UnitPriceDiscount,
    LineTotal
  from {{ ref('salesorderdetail') }}
  where dbt_valid_to is null
)

, product_snapshot as (
    select 
      ProductID,
      Name,
      ProductNumber,
      Color,
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
    where dbt_valid_to is null
)

, salesorderheader_snapshot as (
    select
      SalesOrderID,
      RevisionNumber,
      OrderDate,
      DueDate,
      ShipDate,
      Status,
      OnlineOrderFlag,
      SalesOrderNumber,
      PurchaseOrderNumber,
      AccountNumber,
      CustomerID,
      ShipToAddressID,
      BillToAddressID,
      ShipMethod, -- DIPERBAIKI: Diubah dari ShipMethodID menjadi ShipMethod
      CreditCardApprovalCode,
      SubTotal,
      TaxAmt,
      Freight,
      TotalDue,
      Comment
    from {{ ref('salesorderheader') }}
    where dbt_valid_to is null
)

, transformed as (
    select
        sod.salesorderid,
        sod.salesorderdetailid,
        sod.orderqty,
        sod.productid,
        sod.unitprice,
        sod.unitpricediscount,
        sod.linetotal,
        p.name,
        p.productnumber,
        p.color,
        p.standardcost,
        p.listprice,
        p.size,
        p.weight,
        p.sellstartdate,
        p.sellenddate,
        p.discontinueddate,
        soh.revisionnumber,
        soh.orderdate,
        soh.duedate,
        soh.shipdate,
        soh.status,
        soh.onlineorderflag,
        soh.salesordernumber,
        soh.purchaseordernumber,
        soh.accountnumber,
        soh.customerid,
        soh.shiptoaddressid,
        soh.billtoaddressid,
        soh.shipmethod, -- DIPERBAIKI: Mengikuti perubahan alias nama kolom
        soh.creditcardapprovalcode,
        soh.subtotal,
        soh.taxamt,
        soh.freight,
        soh.totaldue,
        soh.comment
    from salesorderdetail_snapshot as sod
    left join salesorderheader_snapshot as soh on sod.salesorderid = soh.salesorderid
    left join product_snapshot as p on sod.productid = p.productid
)

select * from transformed