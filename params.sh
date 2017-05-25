#!/bin/bash

export Path=/sbin:/usr/sbin:/bin:/usr/bin

case $1 in
    "hello")
    echo "Hello, how are you?"
    ;;
    "") 
    echo "You must input parameters, ex> {$0 someWord}"
    ;;
    *)
    echo "The only paramter is hello, ex> {$0 hello}"
    ;;
esac
