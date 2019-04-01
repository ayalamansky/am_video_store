view: rental {
  sql_table_name: sakila.rental ;;

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension: customer_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: inventory_id {
    type: number
    sql: ${TABLE}.inventory_id ;;
  }

  dimension_group: last_update {
    hidden: yes
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
    sql: ${TABLE}.last_update ;;
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
      year,
      month_name
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

  dimension: days_rented {
    type: number
    sql: datediff(${return_raw},${rental_raw}) ;;
  }

  dimension: rental_is_late {
    type: yesno
    sql: (${return_raw} is null and datediff(curdate(), ${rental_raw}) > 7) or ${days_rented} > 7 ;;
  }

  dimension: staff_id {
    type: yesno
    sql: ${TABLE}.staff_id ;;
  }

  measure: count {
    type: count
    drill_fields: [rental_id, customer.customer_id, customer.last_name, customer.first_name, payment.count]
  }
}
