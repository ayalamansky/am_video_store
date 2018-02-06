view: inventory_history2 {
  derived_table: {
    sql: select date(rentals.inventory_date) as inventory_date, count(*) as rentals_count, count(*)/(select count(distinct rental.inventory_id) as inventory from rental
LEFT JOIN sakila.inventory  AS inventory ON rental.inventory_id = inventory.inventory_id
LEFT JOIN sakila.film  AS film ON inventory.film_id = film.film_id
LEFT JOIN sakila.film_category  AS film_category ON film.film_id = film_category.film_id
LEFT JOIN sakila.category  AS category ON film_category.category_id = category.category_id where {% condition title_filter %} film.title {% endcondition %}
      AND {% condition category_filter %} category.name {% endcondition %})  as rentals_ratio
FROM
(select rental_id, rental_date, return_date, DATE_ADD(rental_date, INTERVAL rank-1 DAY) as inventory_date, rank
from rental
JOIN (
SELECT @rank:=@rank+1 AS rank
FROM rental, (select @rank:=0) b limit 100 ) nums
ON nums.rank <= datediff(return_date, rental_date)+1)  rentals
LEFT JOIN sakila.rental  AS rental ON rentals.rental_id = rental.rental_id
LEFT JOIN sakila.inventory  AS inventory ON rental.inventory_id = inventory.inventory_id
LEFT JOIN sakila.film  AS film ON inventory.film_id = film.film_id
LEFT JOIN sakila.film_category  AS film_category ON film.film_id = film_category.film_id
LEFT JOIN sakila.category  AS category ON film_category.category_id = category.category_id
WHERE {% condition title_filter %} film.title {% endcondition %}
      AND {% condition category_filter %} category.name {% endcondition %}
group by 1;;
}
dimension: inventory_date {
  type: date
  primary_key: yes
  sql: ${TABLE}.inventory_date ;;
}
dimension: rentals_count {
  type: number
  sql: ${TABLE}.rentals_count ;;
}
dimension: rentals_ratio {
  type: number
  sql: ${TABLE}.rentals_ratio ;;
  value_format_name: percent_2
}
  filter: title_filter {
    type: string
    suggest_dimension: film.title
  }

  filter: category_filter {
    type: string
    suggest_dimension: category.name
  }
}
