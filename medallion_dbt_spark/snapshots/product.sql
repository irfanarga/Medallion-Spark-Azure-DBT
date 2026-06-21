{% snapshot product %}

{{
    config(
        file_format = "delta",
        location_root = "abfss://silver@medallionsanew.dfs.core.windows.net/",
        target_schema = 'snapshots',
        target_catalog = 'medallion_spark_databricks',
        invalidate_hard_deletes = True,
        unique_key = "ProductID",
        strategy = 'check',
        check_cols = 'all'
    )
}}

with source_data as (
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
        DiscontinuedDate,
        ThumbNailPhoto,
        ThumbnailPhotoFileName
    from {{ source('saleslt', 'product') }}
)

select * from source_data

{% endsnapshot %}
