{% snapshot salesorderdetail_snapshot %}

{{
    config(
        file_format = "delta",
        location_root = "abfss://silver@medallionsanew.dfs.core.windows.net/",
        target_schema = 'snapshots',
        invalidate_hard_deletes = True,
        unique_key = "SalesOrderID",
        strategy = 'check',
        check_cols = 'all'
    )
}}

with source_data as (
    select 
        SalesOrderID,
        SalesOrderDetailID,
        OrderQty,
        ProductID,
        UnitPrice,
        UnitPriceDiscount,
        LineTotal
    from {{ source('saleslt', 'salesorderdetail') }}
)

select * from source_data

{% endsnapshot %}
