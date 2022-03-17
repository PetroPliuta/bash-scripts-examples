#!/usr/bin/env bash

# a, b - test only presense of these params
# u:, p: - get the value (colon in the end)
# : at the very beginning - get any other options
# case ?) - other options

while getopts :u:p:ab option; do
  # echo "option:$option, OPTARG:$OPTARG"
  case $option in
    u) user=$OPTARG;;
    p) pass=$OPTARG;;
    a) echo "flag A" ;;
    b) echo flag B ;;
    ?) echo "other option(s): $OPTARG" ;; 
  esac
done

echo "user:$user, pass:$pass"

# call:
# ./getopts.sh -ab -uuu -p asd -z

