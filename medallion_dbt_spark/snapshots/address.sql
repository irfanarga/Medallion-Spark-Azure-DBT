{% snapshot address %}

{{
    config(
        file_format = "delta",
        location_root = "abfss://silver@medallionsanew.dfs.core.windows.net/",
        target_schema = 'snapshots',
        target_catalog = 'medallion_spark_databricks',
        invalidate_hard_deletes = True,
        unique_key = 'AddressID',
        strategy = 'check',
        check_cols = 'all'
    )
}}

with source_data as (
    select 
        AddressID,
        AddressLine1,
        AddressLine2,
        City,
        StateProvince,
        CountryRegion,
        PostalCode
    from {{ source('saleslt', 'address') }}
)

select * from source_data

{% endsnapshot %}
