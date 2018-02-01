view: category {
  sql_table_name: sakila.category ;;

  dimension: category_id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.category_id ;;
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

  dimension: category_name {
    type: string
    sql: ${TABLE}.name ;;
  }
}
