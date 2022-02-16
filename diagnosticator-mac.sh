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

printf "%40s\n" " 0. checking ${BRIGHT}${GREEN}/usr/lib/diagnosticator${NORMAL} ..."
if [ ! -d /usr/lib/diagnosticator ]; then
  printf "%40s\n" " -> creating ${BRIGHT}${GREEN}/usr/lib/diagnosticator${NORMAL} ..."
  mkdir -p /usr/lib/diagnosticator
else
  printf "%40s\n" " -> ${BRIGHT}${GREEN}/usr/lib/diagnosticator${NORMAL} found"
fi



























exit 0
