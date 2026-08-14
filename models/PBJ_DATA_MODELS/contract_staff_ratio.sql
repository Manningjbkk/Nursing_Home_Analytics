with source_data as (

    select
        provnum,
        provname,
        state,
        workdate,

        coalesce(hrs_rn, 0) as rn_hours,
        coalesce(hrs_lpn, 0) as lpn_hours,
        coalesce(hrs_cna, 0) as cna_hours,

        coalesce(hrs_rn_ctr, 0) as rn_contract_hours,
        coalesce(hrs_lpn_ctr, 0) as lpn_contract_hours,
        coalesce(hrs_cna_ctr, 0) as cna_contract_hours

    from {{ source('PBJ_DATA_Q2_2024', 'PBJ_NURSE_STAFFING_Q2_2024') }}

),

monthly_staffing as (

    select
        provnum,
        provname,
        state,
        date_trunc('month', workdate) as month,

        sum(
            rn_hours
            + lpn_hours
            + cna_hours
        ) as total_nurse_hours,

        sum(
            rn_contract_hours
            + lpn_contract_hours
            + cna_contract_hours
        ) as total_contract_hours

    from source_data

    group by
        provnum,
        provname,
        state,
        date_trunc('month', workdate)

),

ratio_calculation as (

    select
        provnum,
        provname,
        state,
        month,
        total_nurse_hours,
        total_contract_hours,

        case
            when total_nurse_hours > 0
            then total_contract_hours / total_nurse_hours
            else null
        end as contract_staff_ratio

    from monthly_staffing

)

select *
from ratio_calculation