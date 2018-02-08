view: inventory_analysis {
  derived_table: {
    sql: select ids.inventory_id as inventory_id, dates.inventory_date as inventory_date,
          inv.rental_date, inv.return_date from
          (select distinct inventory_id from ${inventory_history.SQL_TABLE_NAME}) ids
          cross join
          (select distinct inventory_date from ${inventory_history.SQL_TABLE_NAME}) dates
          left join
          ${inventory_history.SQL_TABLE_NAME} inv on
          dates.inventory_date = inv.inventory_date
          and ids.inventory_id = inv.inventory_id;;
    sql_trigger_value: select max(rental_id) from rental;;
    indexes: ["inventory_date"]
  }

  dimension: inventory_date {
    type: date
    sql: ${TABLE}.inventory_date ;;
  }

  dimension: inventory_id {
    type: number
    sql: ${TABLE}.inventory_id ;;
  }

  dimension: unique_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: concat(${inventory_date},${inventory_id}) ;;
  }

  dimension_group: rental {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.rental_date ;;
  }

  dimension_group: return {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.return_date ;;
  }

  dimension: is_rented {
    type: yesno
    sql: ${rental_date} is not null ;;
  }

  measure: rental_count {
    type: count
    filters: {
      field: is_rented
      value: "Yes"
    }
  }

  measure: total_count {
    type: count
  }

  measure: rentals_ratio {
    type: number
    sql: 1.0*${rental_count}/nullif(${total_count},0) ;;
    value_format_name: percent_2
  }
}
