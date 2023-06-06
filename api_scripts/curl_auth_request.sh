#!/bin/bash
: '
This program is used to make a request to the backend without
having to provide auth token. The token is used from the cached
one after you have successfully run the login request with a 
valid username and password.
'

source "./utils.sh" # for all necessary functions

refresh_token=$(getToken "./token.log" "refresh")
access_token=$(getToken "./token.log" "access")
request_method="default"
#request_url=$1
#
## options
#options="p:u:d" # p: post, u: update, d: delete
#
#while getopts $options opt
#do
#	# incase the user sets more than one option.
#	if [[ $request_method != "default" ]]
#	then echo "Multiple options not allowed!";
#		exit 1;
#	fi
#
#	case $opt in 
#		p) 
#			request_method="POST"; 
#			opt_arg=$OPTARG;;
#		u) 
#			request_method="PUT";
#			opt_arg=$OPTARG;;
#		d) request_method="DELETE";;
#		\?) echo Unrecognized option provided;
#			exit 1;;
#		*) echo An uknown error occured!;
#			exit 1;;
#	esac
#done
#shift $(( OPTIND -1 ))
#args=($@)
#request_url=${args[0]}

# options
options="p:u:d" # p: post, u: update, d: delete

while getopts $options opt
do
	# incase the user sets more than one option.
	if [[ $request_method != "default" ]]
	then echo "Multiple options not allowed!";
		exit 1;
	fi

	case $opt in 
		p) 
			request_method="POST"; 
			opt_arg=$OPTARG;;
		u) 
			request_method="PUT";
			opt_arg=$OPTARG;;
		d) request_method="DELETE";;
		\?) echo Unrecognized option provided;
			exit 1;;
		*) echo An uknown error occured!;
			exit 1;;
	esac
done
shift $(( OPTIND -1 ))
args=($@)
request_url=${args[0]}

# check if log file not empty
`checkFileNotEmpty "./token.log"`
file_empty_status=$?
if [[ $file_empty_status != 0 ]]
then 
	echo "Please make sure to run the login script before making an auth request"
	exit 1
fi
unset file_empty_status

# verify refresh token
`verifyToken "$refresh_token" "/MainApp/verify/"`
verify_response=$?
# check if verification passed. 
if [[ $verify_response -eq 7 ]] # fatal error in the request.
then 
	echo "Fatal error in request!"
	echo "Host is not up!"
	exit 7
elif [[ $verify_response -ne 0 ]] # an uknown error.
then
	echo "The refresh token is invalid!"
	echo "Please re-login!"
	exit 1
fi
unset verify_response

# verify access toekn
`verifyToken "$access_token" "/MainApp/verify/"`
verify_response=$?
# check if verification passed else refresh.
if [[ $verify_response -ne 0 ]]
then echo "Please refresh the token!";exit $verify_response;
fi

if [[ $request_method == "default" ]]
then 
	request_method="GET";
fi

# finally make the request.
#request_response=$(curl -s\
#	-X $request_method\
#	-H "Authorization: Bearer $access_token"\
#	-d $opt_arg\
#	--url $request_url)
echo "all props $@"
request_response=$(curl -s -H "Authorization: Bearer $access_token" $@)
curl_cmd_status=$?
if [[ $curl_cmd_status -eq 6 ]]
then echo "Could not resolve the url!"; exit 1;
elif [[ $curl_cmd_status -ne 0 ]]
then echo "Oops something happend!" exit 1;
else unset curl_cmd_status;
fi
echo "response: $request_response"
