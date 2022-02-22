#!/usr/bin/env bash

### define colors
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)


### define files pathways
DIAGNOSTICATOR_FILES_DIR=/usr/local/opt/diagnosticator/bin/files/
DOCKER_COMPOSE_FILE=${DIAGNOSTICATOR_FILES_DIR}/docker-compose.yml
DOCKER_COMPOSE_PID_FILE=${DIAGNOSTICATOR_FILES_DIR}/docker-compose.pid
DIAGNOSTICATOR_CREDENTIALS=${DIAGNOSTICATOR_FILES_DIR}/credentials.json
DOCKER_COMPOSE_LOGS=${DIAGNOSTICATOR_FILES_DIR}/docker-compose.log
DOCKER_COMPOSE_REPLACED_FILE=${DIAGNOSTICATOR_FILES_DIR}/docker-compose.yml.REPLACED_$(date '+%d-%m-%Y_%H.%M.%S')
DOCKER_COMPOSE_LATEST_FILE=${DIAGNOSTICATOR_FILES_DIR}/docker-compose.yml.LATEST
DIAGNOSTICATOR_SERVER_URL='https://diagnosticator.com'
DIAGNOSTICATOR_LOCAL_URL='http://localhost:9000'
DIAGNOSTICATOR_MAIL_ADDRESS='diagnosticator.edu@gmail.com'
NEED_AUTHENTICATION=1


### 0. CHECK DEPENDENCIES
DEPENDENCIES=( docker docker-compose jq printf cmp curl wget date cut )
echo
printf "%s\n" "${YELLOW}0.${NORMAL} checking ${MAGENTA}${#DEPENDENCIES[@]}${NORMAL} dependencies ..."
# 1. docker
i=0
for DEP in "${DEPENDENCIES[@]}"; do
  i=$((i+1))
  printf "%s\n" " ${YELLOW}0.${i}.${NORMAL} checking ${BRIGHT}${GREEN}${DEP}${NORMAL} ..."
  if [ ! "$(command -v docker)" ]; then
    printf "%s\n" "       -> Please install ${BRIGHT}${GREEN}${DEP}${NORMAL} first: ${BLUE}${UNDERLINE}https://github.com/cccnrc/diagnosticator-mac#dependencies${NORMAL}"
    exit 1
  else
    printf "%s\n" "   -> ${BRIGHT}${GREEN}${DEP}${NORMAL} found"
  fi
done
echo

### 0.a check docker actually runs
if ! docker info > /dev/null 2>&1; then
  printf "%s\n" "     ${BRIGHT}${RED}ERROR${NORMAL}: -> ${BRIGHT}${GREEN}docker${NORMAL} is found in path but is not running, please fix it: ${BLUE}${UNDERLINE}https://github.com/cccnrc/diagnosticator-mac#dependencies${NORMAL} and come back ;)"
  printf "%s\n" "               -> tip: you need to successfully run ${BRIGHT}${LIME_YELLOW}docker run hello-world${NORMAL} from the terinal"
  echo
  exit 1
fi

### 1. CHECK PROCESS RUNNING
echo
printf "%s\n" "${YELLOW}1.${NORMAL} checking if ${BRIGHT}${GREEN}diagnosticator${NORMAL} is running already on this system ..."
if [ -s $DOCKER_COMPOSE_PID_FILE ]; then
  DOCKER_COMPOSE_PID=$( cat $DOCKER_COMPOSE_PID_FILE )
  WORKING=$( ps aux | awk -vPID=$DOCKER_COMPOSE_PID '$2==PID' | wc -l | awk '{ print $1 }' )
  if [ $WORKING -gt 0 ]; then
    echo
    printf "%s\n" " ${BRIGHT}${UNDERLINE}${RED}ATTENTION${NORMAL}: you have another instance of ${BRIGHT}diagnosticator${NORMAL} running (PID: ${BLUE}${BRIGHT}${DOCKER_COMPOSE_PID}${NORMAL})"
    printf "%s\n" " -> access it here: ${BRIGHT}${UNDERLINE}${BLUE}${DIAGNOSTICATOR_LOCAL_URL}${NORMAL}"
    echo
    open ${DIAGNOSTICATOR_LOCAL_URL} >/dev/null 2>&1
    read  -n 1 -p " Do you want to stop it? [Y/n]  " USER_RUN_BOOL
    echo
    if [[ "$USER_RUN_BOOL" == "y" ]] || [[ "$USER_RUN_BOOL" == "Y" ]]; then
      cd $( dirname $DOCKER_COMPOSE_OLD_FILE )
      echo " -> stopping diagnosticator:"
      echo " ------------------------------------------------------------ "
      docker-compose down
      wait
      echo " ------------------------------------------------------------ "
      echo
      read  -n 1 -p " Do you want to launch another one? [Y/n]  " USER_RUN_BOOL_2
      echo
      if [[ "$USER_RUN_BOOL_2" == "y" ]] || [[ "$USER_RUN_BOOL_2" == "Y" ]]; then
        echo " -> launching new one ..."
      else
        echo " -> bye :)"
        echo
        exit 1
      fi
    else
      exit 1
    fi
  else
    printf "%s\n" "   -> no ${BRIGHT}${GREEN}diagnosticator${NORMAL} running instance found"
  fi
else
  printf "%s\n" "   -> no ${BRIGHT}${GREEN}diagnosticator${NORMAL} running instance found"
fi
echo

### 2. CHECK STORED CREDENTIALS
echo
printf "%s\n" "${YELLOW}2.${NORMAL} checking if ${BRIGHT}${GREEN}diagnosticator${NORMAL} credentials stored on this system ..."
if [ -s $DIAGNOSTICATOR_CREDENTIALS ]; then
  echo
  echo " -> using $DIAGNOSTICATOR_CREDENTIALS to authenticate ..."
  TOKEN=$( cat $DIAGNOSTICATOR_CREDENTIALS | jq -r ".token" )
  EXP=$( cat $DIAGNOSTICATOR_CREDENTIALS | jq -r ".exp" )
  NEED_AUTHENTICATION=0
  echo
else
  printf "%s\n" "   -> no ${BRIGHT}${GREEN}diagnosticator${NORMAL} stored token found"
fi


### 3. check internet connection
echo
printf "%s\n" "${YELLOW}3.${NORMAL} checking your ${BRIGHT}${GREEN}internet connection${NORMAL} ..."
wget -q --spider http://google.com
if [ $? -eq 0 ]; then
    printf "%s\n" " -> ${BRIGHT}internet connection ${BRIGHT}${GREEN}established${NORMAL}"
else
    printf "%s\n" " -> ${BRIGHT}internet connection${NORMAL} can ${BRIGHT}${UNDERLINE}${RED}not${NORMAL} be established. Exiting ..."
    exit 1
fi
echo

### 4. check user registration
echo
printf "%s\n" "${YELLOW}4.${NORMAL} checking ${BRIGHT}${GREEN}diagnosticator user${NORMAL} ..."
### if stored token check it is not expired
if [ $NEED_AUTHENTICATION -eq 0 ]; then
  echo " -> using stored token: $DIAGNOSTICATOR_CREDENTIALS"
  if [ ! -z "$TOKEN" ]; then
    if [ ! -z "$EXP" ]; then
      EXP_DATE=$( date -j -f '%m/%d/%y %H:%M:%S' "$EXP" '+%s'  )
      ### check token not expired
      if [ "$EXP_DATE" -gt "$(date +%s)" ]; then
          printf "%s\n" "    -> token looks ok"
      else
        printf "%s\n" "    -> token expired on: ${BRIGHT}${BLUE}${EXP_DATE}${NORMAL}. Getting new one ..."
        NEED_AUTHENTICATION=1
      fi
    else
      printf "%s\n" "    -> problems with the token. Getting new one ..."
      NEED_AUTHENTICATION=1
    fi
  else
    printf "%s\n" "    -> problems with the token. Getting new one ..."
    NEED_AUTHENTICATION=1
  fi
fi

### if it needs authentication
if [ $NEED_AUTHENTICATION -ne 0 ]; then
  ### if no stored credentials
  if [ $NEED_AUTHENTICATION -ne 0 ]; then
    echo
    printf "%s\n" " ${BRIGHT}${UNDERLINE}${RED}IMPORTANT${NORMAL}: diagnosticator requires a ${BRIGHT}${UNDERLINE}${RED}valid user${NORMAL}"
    echo
    while true; do
      read  -n 1 -p " Did you register online? [Y/n]  " USER_BOOL
      echo
      if [[ "$USER_BOOL" == "y" ]] || [[ $USER_BOOL == "Y" ]]; then
        printf "%s" "${NORMAL} -> enter your ${BRIGHT}${CYAN}username${NORMAL}:  ${LIME_YELLOW}"
        read  -p "" BASIC_AUTH_USER
        printf "%s" "${NORMAL} -> enter your ${BRIGHT}${CYAN}password${NORMAL}:  "
        read  -s BASIC_AUTH_PASSWORD
        echo
        break
      elif [[ "$USER_BOOL" == "n" ]] || [[ "$USER_BOOL" == "N" ]]; then
        printf "%s\n" " -> register here: ${BRIGHT}${UNDERLINE}${BLUE}https://diagnosticator.com/auth/register${NORMAL}"
        echo "   -> and come back ;)"
        open https://diagnosticator.com/auth/register >/dev/null 2>&1
        echo
        exit 1
      else
        echo " -> please enter a valid choice: Y(yes) / N(no)"
        echo
      fi
    done
    echo
  fi
  AUTH=$( echo -ne "$BASIC_AUTH_USER:$BASIC_AUTH_PASSWORD" | base64 )
  RESPONSE=$(  curl \
                    --header "Content-Type: application/json" \
                    --header "Authorization: Basic $AUTH" \
                    --request POST \
                    $DIAGNOSTICATOR_SERVER_URL/api/long_tokens 2> /dev/null )
  TOKEN=$( echo "$RESPONSE" | jq -r ".token" )
  EXP=$( echo "$RESPONSE" | jq -r ".exp" | cut -d':' -f1,2,3 )
fi

### check token and exp
if [ ! -z "$TOKEN" ] && [[ "$TOKEN" != "null" ]]; then
  echo " -> valid user"
  printf "%s\n" "    -> token: ${BRIGHT}${BLUE}${TOKEN}${NORMAL}"
  if [ ! -z "$EXP" ] && [[ "$EXP" != "null" ]]; then
    EXP_DATE=$( date -j -f '%m/%d/%y %H:%M:%S' "$EXP" +'%s' )
    if [ "$EXP_DATE" -gt "$(date +%s)" ]; then
        printf "%s\n" "    ->   exp: ${BRIGHT}${BLUE}${EXP}${NORMAL}"
        ### save token to $DIAGNOSTICATOR_CREDENTIALS
        echo -e "{\n  \"token\": \"${TOKEN}\",\n  \"exp\": \"${EXP}\"\n}" > $DIAGNOSTICATOR_CREDENTIALS
        printf "%s\n" " -> token stored in ${BRIGHT}${BLUE}${DIAGNOSTICATOR_CREDENTIALS}${NORMAL} (we won't ask again until ${BLUE}${EXP}${NORMAL})"
    else
        printf "%s\n" " -> ${BRIGHT}${UNDERLINE}${RED}ERROR${NORMAL}: ${UNDERLINE}${RED}invalid token expiration${NORMAL}"
        printf "%s\n" "    -> this could be on our end, please try again and contact developers if it fails ${BRIGHT}${UNDERLINE}${BLUE}${DIAGNOSTICATOR_MAIL_ADDRESS}${NORMAL}"
        echo "    -> exiting ..."
        echo
        exit 1
    fi
  else
      printf "%s\n" " -> ${BRIGHT}${UNDERLINE}${RED}ERROR${NORMAL}: ${UNDERLINE}${RED}invalid token${NORMAL}"
      printf "%s\n" "    -> this could be on our end, please try again and contact developers if it fails ${BRIGHT}${UNDERLINE}${BLUE}${DIAGNOSTICATOR_MAIL_ADDRESS}${NORMAL}"
      echo "    -> exiting ..."
      echo
      exit 1
  fi
  echo
else
  printf "%s\n" " -> ${BRIGHT}${UNDERLINE}${RED}ERROR${NORMAL}: ${UNDERLINE}${RED}invalid username or password${NORMAL}"
  printf "%s\n" "    -> re-type them correctly (try: ${BRIGHT}${UNDERLINE}${BLUE}https://diagnosticator.com/auth/login${NORMAL})"
  if [ -s $DIAGNOSTICATOR_CREDENTIALS ]; then rm $DIAGNOSTICATOR_CREDENTIALS; fi
  echo "    -> exiting ..."
  echo
  exit 1
fi

### 4. download docker-compose.yml
echo
printf "%s\n" "${YELLOW}5.${NORMAL} downloading latest ${BRIGHT}${GREEN}docker-compose.yml${NORMAL} from ${BLUE}${UNDERLINE}${DIAGNOSTICATOR_SERVER_URL}${NORMAL} ..."
RESPONSE=$(  curl \
                  --header "Content-Type: application/json" \
                  --header "Authorization: Bearer ${TOKEN}" \
                  --request POST \
                  $DIAGNOSTICATOR_SERVER_URL/api/download/docker-compose.yml 1>$DOCKER_COMPOSE_LATEST_FILE 2>/dev/null )
if [ $? -eq 0 ]; then
  DOCKER_COMPOSE_START=$( cat $DOCKER_COMPOSE_LATEST_FILE | head -1 | cut -d':' -f1 )
  DOCKER_COMPOSE_END=$( cat $DOCKER_COMPOSE_LATEST_FILE | tail -1 | cut -d':' -f1 | xargs )
  if [[ "$DOCKER_COMPOSE_START" == "version" ]] && [[ "$DOCKER_COMPOSE_END" == "DX-REDIS" ]]; then
    echo -e " -> docker-compose file looks ${BRIGHT}good${NORMAL}"
    ### check for differences from last docker-compose.yml
    if [ -s $DOCKER_COMPOSE_FILE ]; then
      if [ -n "$( cmp $DOCKER_COMPOSE_FILE $DOCKER_COMPOSE_LATEST_FILE )" ]; then
        echo "    -> files are ${BRIGHT}different${NORMAL}. Replacing: $DOCKER_COMPOSE_FILE ..."
        mv $DOCKER_COMPOSE_FILE $DOCKER_COMPOSE_REPLACED_FILE
        mv $DOCKER_COMPOSE_LATEST_FILE $DOCKER_COMPOSE_FILE
      else
        echo "    -> files are ${BRIGHT}identical${NORMAL}. Ignoring latest file: $DOCKER_COMPOSE_LATEST_FILE ..."
        rm $DOCKER_COMPOSE_LATEST_FILE
      fi
    else
      echo "    -> fresh new installation ;)"
      mv $DOCKER_COMPOSE_LATEST_FILE $DOCKER_COMPOSE_FILE
    fi
  ### if it fails token check
  else
    printf "%s\n" " -> ${BRIGHT}${UNDERLINE}${RED}ERROR${NORMAL}: ${UNDERLINE}${RED}invalid docker-compose.yml${NORMAL}"
    printf "%s\n" "    -> this could be on our end, please try again and contact developers if it fails ${BRIGHT}${UNDERLINE}${BLUE}${DIAGNOSTICATOR_MAIL_ADDRESS}${NORMAL}"
    echo "    -> exiting ..."
    echo
    exit 1
  fi
fi
echo







### 6. launch diagnosticator local app
echo
printf "%s\n" "${YELLOW}6.${NORMAL} launching ${BRIGHT}diagnosticator${NORMAL} ..."
if [ -s $DOCKER_COMPOSE_FILE ]; then
  cd $( dirname $DOCKER_COMPOSE_FILE )
  echo " -> pulling latest docker images:"
  echo " ------------------------------------------------------------ "
  docker-compose pull
  wait
  echo " ------------------------------------------------------------ "
  echo
  docker-compose up &>$DOCKER_COMPOSE_LOGS &
  PID=$!
  echo $PID > $DOCKER_COMPOSE_PID_FILE
  printf "%s\n" " -> ${BRIGHT}diagnosticator${NORMAL} launched in backgorund (PID: ${BRIGHT}${CYAN}${PID}${NORMAL})"
  printf "%s\n" "    -> logs stored to ${BRIGHT}${BLUE}${DOCKER_COMPOSE_LOGS}${NORMAL}"
  echo
  printf "%s\n" "    ===>   ${BRIGHT}${RED}Enjoy${NORMAL} ;)   <==="
  echo
  open ${DIAGNOSTICATOR_LOCAL_URL} >/dev/null 2>&1
else
  printf "%s\n" " -> ${BRIGHT}${UNDERLINE}${RED}ERROR${NORMAL}: ${UNDERLINE}${RED}missing ${DOCKER_COMPOSE_FILE}${NORMAL}. Exiting ..."
  exit 1
  echo
fi
echo















exit 0
