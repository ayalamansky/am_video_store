view: customer_facts {
  derived_table: {
    sql: select a.customer_id, count(distinct a.rental_id) as total_rentals, min(a.rental_date) as first_rental, max(a.rental_date) as last_rental, sum(b.amount) as total_revenue
      from rental a
      join payment b on a.rental_id = b.rental_id
      group by 1
       ;;
    indexes: ["customer_id"]
    persist_for: "24 hours"
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: customer_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.customer_id ;;
  }

  dimension: total_rentals {
    type: number
    sql: ${TABLE}.total_rentals ;;
  }

  dimension: rental_tiers {
    type: tier
    style: integer
    tiers: [0,10,20,30,40]
    sql: ${total_rentals} ;;

  }

  dimension_group: first_rental {
    type: time
    sql: ${TABLE}.first_rental ;;
  }

  dimension_group: last_rental {
    type: time
    sql: ${TABLE}.last_rental ;;
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}.total_revenue ;;
  }

  dimension: is_high_value_customer{
    type: yesno
    sql: ${total_revenue} > 200 ;;
  }

  measure: average_revenue {
    description: "Average of total revenue per customer"
    type: average
    sql: ${total_revenue} ;;
    value_format_name: usd
  }

  measure: average_number_rentals {
    description: "Average of total number of rentals per customer"
    type: average
    sql: ${total_rentals} ;;
  }

  measure: average_number_rentals_high_value_customers {
    type: average
    sql: ${total_rentals} ;;
    filters: {
      field: is_high_value_customer
      value: "yes"
    }
  }

  measure: count_high_value_customers {
    type: count
    filters: {
      field: is_high_value_customer
      value: "yes"
    }
  }

  measure: percent_high_value_customers {
    type: number
    sql: 1.0*${count_high_value_customers}/nullif(${count},0) ;;
    value_format_name: percent_2
  }

  set: detail {
    fields: [customer_id, total_rentals, first_rental_time, last_rental_time, total_revenue, payment.amount]
  }
}
