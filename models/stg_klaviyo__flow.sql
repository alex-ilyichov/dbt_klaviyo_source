
with base as (

    select * 
    from {{ ref('stg_klaviyo__flow_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_klaviyo__flow_tmp')),
                staging_columns=get_flow_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        created as created_at,
        id as flow_id,
        name as flow_name,
        status,
        /*******************
          See the `get_flow_columns` macro for additional context. Not sure what we decided was the best
          approach for handling reserved words. Conditional within the staging model, or in the macro?
        *******************/
        {% if target.type == 'snowflake'%}
        "TRIGGER" 
        {% else %}
        trigger
        {% endif %}
        as flow_trigger,
        updated as updated_at,
        customer_filter as person_filter

    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * from final