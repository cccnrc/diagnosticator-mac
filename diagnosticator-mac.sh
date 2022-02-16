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


# printf "%40s\n" " ${BRIGHT}${UNDERLINE}${RED}ATTENTION${NORMAL}: you have another instance of ${BRIGHT}${GREEN}diagnosticator${NORMAL} running (PID: ${BLUE}${BRIGHT}CIAO${NORMAL})"

### 0. CHECK
# 1. docker
echo
printf "%40s\n" " 0.1. checking ${BRIGHT}${GREEN}docker${NORMAL} ..."
if [ ! "$(command -v docker)" ]; then
  printf "%40s\n" "   -> Please install ${BRIGHT}${GREEN}docker${NORMAL} first: ${BLUE}${UNDERLINE}https://github.com/cccnrc/diagnosticator-mac#dependencies${NORMAL}"
  exit 1
else
  printf "%40s\n" "   -> ${BRIGHT}${GREEN}docker${NORMAL} found"
fi
# 2. docker-compose
printf "%40s\n" " 0.2. checking ${BRIGHT}${GREEN}docker-compose${NORMAL} ..."
if [ ! "$(command -v docker-compose)" ]; then
  printf "%40s\n" "   -> Please install ${BRIGHT}${GREEN}docker-compose${NORMAL} first: ${BLUE}${UNDERLINE}https://github.com/cccnrc/diagnosticator-mac#dependencies${NORMAL}"
  exit 1
else
  printf "%40s\n" "   -> ${BRIGHT}${GREEN}docker-compose${NORMAL} found"
fi
echo
























exit 0
