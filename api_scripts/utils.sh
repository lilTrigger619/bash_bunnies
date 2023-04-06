#!/bin/bash

Default_base_url="http://localhost:8000"

# check if the log file exist
# usage: checkFileExist {file_dir}
function checkFileExist(){ # check if a file exists
	file_dir=$1
	if [[ -e "$file_dir" && -f "$file_dir" ]]
	then
		exit 0
	else exit 1;
	fi
}


# request to check if the log file is empty
# usage: checkFileNotEmpty {file_dir}
function checkFileNotEmpty(){
	file_dir=$1
	$(checkFileExist $1)
	exist_status=$?
	if [[ -s "$file_dir" && $exist_status != 1 ]]
	then exit 0
	else exit 1
	fi
}

# get access or refresh token from file
# usage: getToken {dir} {token_type (access| refresh)}
function getToken(){
	file_dir=$1	
	token_type=$2
	case $token_type in
		"access")
			_token=$(cat $file_dir | grep -oP "(?<=\"access\":\")[^\"]+");;
		"refresh")
			_token=$(cat $file_dir | grep -oP "(?<=\"refresh\":\")[^\"]+");;
		*) 
			_token=$(cat $file_dir | grep -oP "(?<=\"access\":\")[^\"]+");;
	esac
	echo $_token
	exit 0
}

# request to verify accessToken
# usage: verifyToken {token} {url}
function verifyToken(){
	_token=$1
	url_loc=$2
	verify_res=$(curl -s -X POST -d token=$_token --url $Default_base_url$url_loc)
	curl_cmd_status=$?
	if [[ $curl_cmd_status -ne 0 ]]
	then 
		printf "Oops an error happend in the request. \n (curl: $curl_cmd_status)";
		exit 1;
	fi
	unset curl_cmd_status
	echo $verify_res | grep -oP "(?<=\"detail\":\")[^\"]+" | grep -Pi "(invalid|expired)" > /dev/null 2>&1
	grep_cmd_status=$?

	# the grep command should return an error cause
	# +the respose should be empty.
	if [[ $grep_cmd_status -eq 0 ]]
	then exit 1
	fi
	exit 0
}
