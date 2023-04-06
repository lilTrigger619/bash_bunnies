#!/bin/bash

# check if the log file exist
Default_base_url="http://localhost:8000"

function checkFileExist(){ # check if a file exists
	file_dir=$1
	if [[ -e "$file_dir" && -f "$file_dir" ]]
	then
		exit 0
	else exit 1;
	fi
}


# request to check if the log file is empty
function checkFileNotEmpty(){
	file_dir=$1
	$(checkFileExist $1)
	exist_status=$?
	if [[ -s "$file_dir" && $exist_status != 1 ]]
	then exit 0
	else exit 1
	fi
}

# get access token from file
function getAccessToken(){
	file_dir=$1	
	a_token=$(cat $file_dir | grep -oP "(?<=\"access\":\")[^\"]+")
	echo $a_token
}

# request to verify accessToken
function verifyAccessToken(){
	token_log=$1
	url_loc=$2
	access_token=$(getAccessToken "$token_log")
	verify_res=$(curl -s -X POST -d token=$access_token --url $Default_base_url$url_loc)
	curl_cmd_status=$?
	if [[ $curl_cmd_status -ne 0 ]]
	then 
		printf "Oops an error happend in the request. \n (curl: $curl_cmd_status)";
		exit 1;
	fi
	unset curl_cmd_status
	echo $verify_res | grep -oP "(?<=\"detail\":\")[^\"]+" | grep -Pi "(invalid|expired)" 2>&1 /dev/null
	grep_cmd_status=$?

	# the grep command should return an error cause
	# +the respose should be empty.
	if [[ $grep_cmd_status -eq 0 ]]
	then exit 1
	fi
	exit 0
}
