{{ config(
    materialized='table'
) }}

with source_data as (

    select
        provnum,
        provname,
        city,
        state,
        county_name,
        county_fips,
        cy_qtr,
        workdate,
        mdscensus,

        coalesce(hrs_rn, 0) as rn_hours,
        coalesce(hrs_lpn, 0) as lpn_hours,
        coalesce(hrs_cna, 0) as cna_hours

    from {{ source('PBJ_DATA_Q2_2024', 'PBJ_NURSE_STAFFING_Q2_2024') }}

),

staffing_calculation as (

    select
        provnum,
        provname,
        city,
        state,
        county_name,
        county_fips,
        cy_qtr,
        workdate,
        mdscensus,

        rn_hours,
        lpn_hours,
        cna_hours,

        rn_hours
        + lpn_hours
        + cna_hours as total_nursing_hours,

        case
            when mdscensus > 0
            then (
                rn_hours
                + lpn_hours
                + cna_hours
            ) / mdscensus
            else null
        end as nurse_to_patient_ratio

    from source_data

)

select *
from staffing_calculation