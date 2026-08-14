{{ config(
    materialized='table'
) }}

with source_data as (

    select
        provnum,
        provname,
        state,
        workdate,

        coalesce(hrs_rn, 0) as rn_hours,
        coalesce(hrs_lpn, 0) as lpn_hours,
        coalesce(hrs_cna, 0) as cna_hours

    from {{ source('PBJ_DATA_Q2_2024', 'PBJ_NURSE_STAFFING_Q2_2024') }}

),

monthly_nurse_hours as (

    select
        provnum,
        provname,
        state,
        date_trunc('month', workdate) as month,

        sum(rn_hours) as total_rn_hours,
        sum(lpn_hours) as total_lpn_hours,
        sum(cna_hours) as total_cna_hours,

        sum(
            rn_hours
            + lpn_hours
            + cna_hours
        ) as total_nurse_hours

    from source_data

    group by
        provnum,
        provname,
        state,
        date_trunc('month', workdate)

)

select *
from monthly_nurse_hours