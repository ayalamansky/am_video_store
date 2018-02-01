view: numbers_table {
  derived_table: {
    sql: SELECT @rank:=@rank+1 AS rank
          FROM rental, (select @rank:=0) b limit 100 ;;
  }
  dimension: rank {
    primary_key: yes
    type: number
    sql: ${TABLE}.rank ;;
  }
}
