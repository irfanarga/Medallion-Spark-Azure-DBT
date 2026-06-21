{% snapshot productmodel %}

{{
    config(
        file_format = "delta",
        location_root = "abfss://silver@medallionsanew.dfs.core.windows.net/",
        target_schema = 'snapshots',
        target_catalog = 'medallion_spark_databricks',
        invalidate_hard_deletes = True,
        unique_key = "ProductModelID",
        strategy = 'check',
        check_cols = 'all'
    )
}}

with source_data as (
    select 
        ProductModelID,
        Name,
        CatalogDescription
    from {{ source('saleslt', 'productmodel') }}
)

select * from source_data

{% endsnapshot %}
