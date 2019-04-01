connection: "video_store"

include: "*.view.lkml"         # include all views in this project
# include: "*.dashboard.lookml"  # include all dashboards in this project

datagroup: 5_min {
  sql_trigger: select date_trunc('min', current_timestamp) ;;
}
# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }

explore: rental {
  persist_with: 5_min
  join: customer {
    relationship: many_to_one
    sql_on: ${rental.customer_id} = ${customer.customer_id} ;;
  }
  join: payment {
    relationship: one_to_one
    sql_on: ${rental.rental_id} = ${payment.rental_id} ;;
  }
  join: customer_facts {
    relationship: many_to_one
    sql_on: ${rental.customer_id} = ${customer_facts.customer_id} ;;
  }
  join: inventory {
    relationship: many_to_one
    sql_on: ${rental.inventory_id} = ${inventory.inventory_id} ;;
  }
  join: film {
    relationship: many_to_one
    sql_on: ${inventory.film_id} = ${film.film_id} ;;
  }
  join: film_category {
    view_label: "Film"
    relationship: one_to_one
    sql_on: ${film.film_id} = ${film_category.film_id} ;;
  }
  join: category {
    view_label: "Film"
    relationship: many_to_one
    sql_on: ${film_category.category_id} = ${category.category_id} ;;
  }
}

explore: inventory_analysis {
  fields: [ALL_FIELDS*, -inventory.inventory_id, -customer_facts.customer_id,
    -customer_facts.count, -payment.customer_id]
  join: rental {
    relationship: many_to_one
    sql_on: ${inventory_analysis.rental_id} = ${rental.rental_id} ;;
  }
  join: customer {
    relationship: many_to_one
    sql_on: ${rental.customer_id} = ${customer.customer_id} ;;
  }
  join: payment {
    relationship: one_to_one
    sql_on: ${rental.rental_id} = ${payment.rental_id} ;;
  }
  join: customer_facts {
    view_label: "Customer"
    relationship: many_to_one
    sql_on: ${rental.customer_id} = ${customer_facts.customer_id} ;;
  }
  join: inventory {
    view_label: "Inventory"
    relationship: many_to_one
    sql_on: ${inventory_analysis.inventory_id} = ${inventory.inventory_id} ;;
  }
  join: film {
    relationship: many_to_one
    sql_on: ${inventory.film_id} = ${film.film_id} ;;
  }
  join: film_category {
    view_label: "Film"
    relationship: one_to_one
    sql_on: ${film.film_id} = ${film_category.film_id} ;;
  }
  join: category {
    view_label: "Film"
    relationship: many_to_one
    sql_on: ${film_category.category_id} = ${category.category_id} ;;
  }
}
