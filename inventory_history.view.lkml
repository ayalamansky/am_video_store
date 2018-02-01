view: inventory_history {
  derived_table: {
    sql: select rental_id, rental_date, return_date,
          DATE_ADD(rental_date, INTERVAL rank-1 DAY) as inventory_date
          from rental
          JOIN ${numbers_table.SQL_TABLE_NAME} nums
          ON nums.rank <= datediff(return_date, rental_date)+1;;
    sql_trigger_value: select max(rental_id) from rental;;
    indexes: ["inventory_date"]
  }

  dimension_group: inventory {
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
    sql: concat(${inventory_raw},${rental_id}) ;;
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

  dimension: total_inventory {
    type: number
    sql: (select count(distinct inventory_id) from rental)
    ) ;;
  }

  filter: title_filter {
    type: string
    suggest_dimension: film.title
  }

  filter: category_filter {
    type: string
    suggest_dimension: category.name
  }

  measure: count {
    type: sum
    sql:
    CASE
      WHEN {% condition title_filter %} film.title {% endcondition %}
      AND {% condition category_filter %} category.name {% endcondition %}
      THEN 1
      ELSE 0
    END
  ;;
  }

}
