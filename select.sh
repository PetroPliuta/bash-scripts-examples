#!/usr/bin/env bash

select animal in cat dog bird fish quit
do
  # echo "animal:$animal"
  case $animal in
    cat) echo "cats...";;
    dog) echo "dogs...";;
    quit) break;;
    *) echo "What?" ;;
  esac
done
