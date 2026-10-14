{{
    config
    (
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = 'purchase_id',
        merge_exclude_columns = ['INSERT_DTS']
    )
}}

with purchase_src as 
(
    select  PURCHASE_ID, 
            PURCHASE_DATE, 
            PURCHASE_STATUS, 
            CREATED_AT, 
            CURRENT_TIMESTAMP AS INSERT_DTS, 
            CURRENT_TIMESTAMP AS UPDATE_DTS
    FROM {{source('purchase','purchase_src')}}

    {% if is_incremental()%}
    where CREATED_AT > (SELECT MAX(UPDATE_DTS) FROM {{this}})
    {% endif %}
)
select * from purchase_src