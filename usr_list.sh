#!/bin/bash

#######################################################################################################
##
## The script creates a list of users on the system in the next format
##  username:/user-home-directory
##  .
## and put it in the ./usr_list.txt 
##
## Maintainer - Sergei Sheshukov. me@sergeek.space
##
########################################################################################################

cut -d: -f1,6 /etc/passwd > usr_list.txt
echo . >> usr_list.txt