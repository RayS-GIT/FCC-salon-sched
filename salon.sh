#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~~ Koki's Salon ~~~~~~"
echo -e "\nWelcome to Koki's, How can I help you?\n"

CUSTOMER_NAME=""
CUSTOMER_PHONE=""
SERVICES=$($PSQL "SELECT service_id, name FROM services")

CREATE_APPOINTMENT() {
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    CUST_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    SERVICE_FORMAT=$(echo $SERVICE | sed 's/\s//g' -E)
    CUST_NAME_FORMAT=$(echo $CUST_NAME | sed 's/\s//g' -E)
    echo -e "\nWhat time would you like to have your $SERVICE_FORMAT, $CUST_NAME_FORMAT?"
    read SERVICE_TIME
    NEW_CUST=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_FORMAT at $SERVICE_TIME, $CUST_NAME_FORMAT."
}

MAIN_MENU () {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  CUSTOMER_AVAIL=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_AVAIL ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    NEW_CUST=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    
    CREATE_APPOINTMENT
  else
    CREATE_APPOINTMENT
  fi
}


LIST_SERVICE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  #if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      LIST_SERVICE "I could not find that service. What else wwould you like today?"
    else
      SERVICE_AVAIL=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      if [[ -z $SERVICE_AVAIL ]]
      then
        LIST_SERVICE "I could not find that service. What else would you like today?"
      else
        MAIN_MENU
      fi
    fi
  
}

LIST_SERVICE
