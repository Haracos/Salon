#! /bin/bash

# Function to display services
display_services() {
  echo "Here are the services we offer:"
  psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT service_id, name FROM services ORDER BY service_id;" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Function to schedule an appointment
schedule_appointment() {
  echo -e "\nEnter the service ID:"
  read SERVICE_ID_SELECTED

  # Check if service exists
  SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]; then
    echo "Invalid service. Please select again."
    display_services
    schedule_appointment
    return
  fi

  echo -e "\nEnter your phone number:"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nIt seems you're a new customer. Please enter your name:"
    read CUSTOMER_NAME
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
  fi

  CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  echo -e "\nEnter a time for your appointment:"
  read SERVICE_TIME

  # Insert appointment
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Main script
echo "Welcome to the Salon!"
display_services
schedule_appointment
