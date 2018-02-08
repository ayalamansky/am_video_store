view: inventory_history {
  derived_table: {
    sql: select inventory_id, rental_date, return_date,
          date(DATE_ADD(rental_date, INTERVAL rank-1 DAY)) as inventory_date, rank
          from rental
          JOIN
          (SELECT @rank:=@rank+1 AS rank
          FROM rental, (select @rank:=0) b limit 100) nums
          ON nums.rank <= datediff(return_date, rental_date)+1
          ;;
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
}
