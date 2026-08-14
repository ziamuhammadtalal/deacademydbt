{{
    config
    (
        materialized = 'incremental',
        incremental_strategy = 'delete+insert',
        unique_key = 'PRODUCT_ID'
    )
}}

with product_src as 
(
    select PRODUCT_ID, PRODUCT_NAME, PRODUCT_PRICE, CREATED_AT, CURRENT_TIMESTAMP AS INSERT_DTS
    FROM {{source('product','product_src')}}
    
    {% if is_incremental() %}
    where CREATED_AT > (SELECT MAX(INSERT_DTS) FROM {{this}})
    {% endif %}
)
SELECT * FROM product_src
