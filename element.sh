#!/bin/bash

# Element database query script
# Query the periodic table database for element information

# Check if an argument was provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Query the database for the element matching the input
# Support querying by atomic number, symbol, or name
ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number::text = '$1' OR UPPER(symbol) = UPPER('$1') OR UPPER(name) = UPPER('$1') LIMIT 1")

if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse the element result
# Extract atomic number, symbol, and name from query result
IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME <<< "$ELEMENT"

# Get the properties for the element
# Query type, atomic mass, and melting/boiling points
PROPERTIES=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties p JOIN types t ON p.type_id = t.type_id WHERE p.atomic_number = $ATOMIC_NUMBER")

IFS='|' read -r TYPE MASS MELTING BOILING <<< "$PROPERTIES"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
