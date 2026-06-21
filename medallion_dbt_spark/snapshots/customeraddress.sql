{% snapshot customeraddress_snapshot %}

{{
    config(
        file_format = "delta",
        location_root = "abfss://silver@medallionsanew.dfs.core.windows.net/",
        target_schema = 'snapshots',
        invalidate_hard_deletes = True,
        unique_key = "CustomerID||'-||AddressID",
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
