#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"
echo Enter your username:
read USERNAME

# check username
USERNAME_RESULT=$($PSQL "SELECT users.user_id, count(*) AS games_played, MIN(attempts) AS best_game FROM users RIGHT JOIN games USING(user_id) WHERE username='$USERNAME' GROUP BY users.user_id;")
if [[ -z $USERNAME_RESULT ]]
then 
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME');")
else
  echo $USERNAME_RESULT | while read _ BAR GAMES_PLAYED BAR BEST_GAME
  do 
    echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  done
fi
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

SECRET_NUMBER=$((1 + $RANDOM % 1000))
echo Guess the secret number between 1 and 1000:

ATTEMPTS=0

CHECK_INPUT(){

if [[ ! $1 =~ ^[0-9]+$ ]]
then
  echo That is not an integer, guess again:
  READ_INPUT
else
  ATTEMPTS=$(( $ATTEMPTS + 1 ))
  if [[ $1 -gt $SECRET_NUMBER ]]
  then
    echo It\'s lower than that, guess again:
    READ_INPUT
  elif [[ $1 -lt $SECRET_NUMBER ]]
  then 
    echo It\'s higher than that, guess again:
    READ_INPUT
  else
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (user_id,attempts) VALUES ($USER_ID,$ATTEMPTS);")
    echo You guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUMBER. Nice job!
  fi
fi

}

READ_INPUT(){
  read INPUT
  CHECK_INPUT $INPUT
}

READ_INPUT