#!/bin/bash
: '
This program is used to make a request to the backend without
having to provide auth token. The token is used from the cached
one after you have successfully run the login request with a 
valid username and password.
'

source "./utils.sh" # for all necessary functions

$(checkFileNotEmpty "./token.log")

file_empty_status=$?
if [[ $file_empty_status != 0 ]]
then 
	echo "Please make sure to run the login script before making an auth request"
	exit 1
fi

unset file_empty_status
access_token=$(getToken "./token.log" "access")

request_response=$(curl -s -H "Authorization: Bearer $access_token" --url http://localhost:8000/MainApp/getMiniUser/)
curl_cmd_status=$?
if [[ $curl_cmd_status -eq 6 ]]
then echo "Could not resolve the url!"; exit 1;
elif [[ $curl_cmd_status -ne 0 ]]
then echo "Oops something happend!" exit 1;
else unset curl_cmd_status;
fi

refresh_token=$(getToken "./token.log" "refresh")
# verify refresh token
`verifyToken "$refresh_token" "/MainApp/verify/"`
verify_response=$?

if [[ $verify_response -ne 0 ]]
then
	echo "The refresh response is invalid. Please re-login!"
fi
unset verify_response

# verify access toekn
`verifyToken "$access_token" "/MainApp/verify/"`
verify_response=$?

if [[ $verify_response -ne 0 ]]
then echo "Please refresh the token!";exit 1;
fi

