#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USER

USERNAME=$($PSQL "SELECT * FROM users WHERE username='$USER'")

if [[ -z $USERNAME ]]
then
  echo "Welcome, $USER! It looks like this is your first time here."
  INSERT_RESULT=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USER',0,0)")
else
  UN=$($PSQL "SELECT username FROM users WHERE username='$USER'")
  BG=$($PSQL "SELECT best_game FROM users WHERE username='$USER'")
  GP=$($PSQL "SELECT games_played FROM users WHERE username='$USER'")
  echo "Welcome back, $UN! You have played $GP games, and your best game took $BG guesses."
fi

SECRET=$(( RANDOM%1001 ))
GUESS_COUNT=1

echo -e "\nGuess the secret number between 1 and 1000:"

while true; do

  read GUESS

  if [[ $GUESS =~ ^[0-9]+$ ]]
  then

    if [[ $GUESS -eq $SECRET ]]; then
        echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET. Nice job!"
        INSERT_RESULT=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USER'")
        INSERT_RESULT=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE username='$USER' AND (best_game>$GUESS_COUNT OR best_game=0)")
        break
    elif [[ $GUESS -lt $SECRET ]]; then
        GUESS_COUNT=$(( $GUESS_COUNT+1 ))
        echo "It's higher than that, guess again:"
    else
        GUESS_COUNT=$(( $GUESS_COUNT+1 ))
        echo "It's lower than that, guess again:"
    fi
    
  else
    echo "That is not an integer, guess again:"
  fi
done

