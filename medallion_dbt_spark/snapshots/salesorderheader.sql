{% snapshot salesorderheader %}

{{
    config(
        file_format = "delta",
        location_root = "abfss://silver@medallionsanew.dfs.core.windows.net/",
        target_schema = 'snapshots',
        target_catalog = 'medallion_spark_databricks',
        invalidate_hard_deletes = True,
        unique_key = "SalesOrderID",
        strategy = 'check',
        check_cols = 'all'
    )
}}

with source_data as (
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
        ShipMethod,
        CreditCardApprovalCode,
        SubTotal,
        TaxAmt,
        Freight,
        TotalDue,
        Comment
    from {{ source('saleslt', 'salesorderheader') }}
)

select * from source_data

{% endsnapshot %}
