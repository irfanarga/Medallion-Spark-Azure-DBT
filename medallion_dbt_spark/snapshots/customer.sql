{% snapshot customer %}

{{
    config(
        file_format = "delta",
        location_root = "abfss://silver@medallionsanew.dfs.core.windows.net/",
        target_schema = 'snapshots',
        target_catalog = 'medallion_spark_databricks',
        invalidate_hard_deletes = True,
        unique_key = 'CustomerID',
        strategy = 'check',
        check_cols = 'all'
    )
}}

with source_data as (
    select 
        CustomerID,
        NameStyle,
        Title,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        CompanyName,
        SalesPerson,
        EmailAddress,
        Phone,
        PasswordHash,
        PasswordSalt
    from {{ source('saleslt', 'customer') }}
)

select * from source_data

{% endsnapshot %}
