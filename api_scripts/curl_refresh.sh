#!/bin/bash

: '
This program is used to make a refresh request when the access token expires.
But will return an error when the refresh token has expired or does not exist.
Please not is uses the token stored in the token.log file in the source directory.
'

URL="http://localhost:8000/MainApp/refresh/"
VerifyLoc="/MainApp/verify/"
source "./utils.sh"

`checkFileExist "./token.log"` # check if the token.log  file exists.
cmd_status=$?

# check if the File exists
if [[ $cmd_status -ne 0 ]]
then echo file error: Token does not exist!
	exit $cmd_status
fi

# get the refresh token.
refresh_token=$(getToken "./token.log" "refresh")
# get access token
access_token=$(getToken "./token.log" "access")

echo refresh: $refresh_token access: $access_token


`verifyToken $refresh_token $VerifyLoc` # verify if the refresh token exists.
verify_status=$?

# check verification status.
if [[ $verify_status -eq 7 ]]
then 
	echo Fatal error occured
	exit 7
elif [[ $verify_status -ne 0 ]]
then 
	echo Refresh token expired!
	echo Refresh !
	exit $verify_status;
fi 
unset verify_status;

# verify access Token
`verifyToken $access_token $VerifyLoc`
verify_status=$?

if [[ $verify_status -eq 7 ]]
then
	echo Fatal error!
	exit $verify_status
elif [[ $verify_status -eq 0 ]]
then
	echo Token is still valid, no need to refresh. 
	exit 0;
fi
unset verify_status;

#continue to refresh when the verification is a 401.


# make refresh request otherwise
refresh_response=$(curl -s -X POST -d refresh\=$refresh_token --url $URL)
cmd_status=$?

# checking the status of the curl command request.
if [[ $cmd_status -eq 7 ]]
then 
	echo There was a fatal error!
	echo The host may down!.
	exit 7
elif [[ $cmd_status -ne 0 ]]
then
	echo An unknown error occured!
	exit $cmd_status
fi
unset cmd_status

# when the request is successful.
access_token=$(echo $refresh_response | grep -oP "(?<=\"access\":\")[^\"]+")
cmd_status=$?

if [[ $cmd_status -ne 0 ]]
then echo Access token no found!
	exit $cmd_status
fi

# when the grep cmd is successful

cached_hard_reset $access_token $refresh_token

