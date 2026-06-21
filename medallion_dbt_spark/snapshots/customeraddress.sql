{% snapshot customeraddress %}

{{
    config(
        file_format = "delta",
        location_root = "abfss://silver@medallionsanew.dfs.core.windows.net/",
        target_schema = 'snapshots',
        target_catalog = 'medallion_spark_databricks',
        invalidate_hard_deletes = True,
        unique_key = "CustomerID||'-'||AddressID",
        strategy = 'check',
        check_cols = 'all'
    )
}}

with source_data as (
    select 
        CustomerID,
        AddressID,
        AddressType
    from {{ source('saleslt', 'customeraddress') }}
)

select * from source_data

{% endsnapshot %}
