#!/bin/bash

app_dir="/home/ebpearls/projects"

echo "Which app do you want to host?"
echo "******************************"

echo "1) Wordpress" 	
echo "2) Express js"
echo "3) Laravel"

echo "Enter the number of your choice:"
read choice
echo "Your choice is $choice."



if [[ choice -eq 1 ]]; then
	source wordpress.sh	
elif [[ choice -eq 2 ]]; then
	source expressjs.sh
elif [[ choice -eq 3 ]]; then
	source laravel.sh
else
	echo "Error!! enter a valid choice[1-3]"
fi
