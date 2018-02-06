view: inventory_history {
  derived_table: {
    sql: select rental_id, rental_date, return_date,
          date(DATE_ADD(rental_date, INTERVAL rank-1 DAY)) as inventory_date, rank
          from rental
          JOIN ${numbers_table.SQL_TABLE_NAME} nums
          ON nums.rank <= datediff(return_date, rental_date)+1;;
    sql_trigger_value: select max(rental_id) from rental;;
    indexes: ["inventory_date"]
  }

  dimension: inventory_date {
    type: date
    sql: ${TABLE}.inventory_date ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension: unique_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: concat(${inventory_date},${rental_id}) ;;
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

  measure: count {
    type: count_distinct
    sql: ${rental.inventory_id} ;;
    drill_fields: [rental_id, customer.customer_id, customer.last_name, customer.first_name, payment.count]
  }

}
