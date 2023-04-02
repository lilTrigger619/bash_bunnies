#! /bin/bash
: '
This project is for make a post request to a specified url to test login
on a server.
All credit to :
@ author: Shadrack Opoku
@ email:  shaddyopoku1@gmail.com
@ phone: 0560451186
'
request_url="None"
options="u:h"

# ---------------------------------------------------------------------------------
# Declaring functions
# ---------------------------------------------------------------------------------
function display_help(){
  printf "\nA script to to make a login request a api-server"
  printf "\nUsage:"
  printf "\n\t$0 {-option} { option value } {username} {password}"
  printf "\nOptions:"
  printf "\n\t-u : provide url rather than using the default url.\n\n"

  printf "Example:\n\t$0 -u http://localhost:9000/login admin root\n\tLogin providing a the url.\n\n\t$0 admin root\n\tLogin providing only username and password using the default url\n\n"
}

# function to make the login request.
function login_request(){
	url_loc=$1
	username_=$2
	password_=$3
	request_response=$(curl -s -X POST -d username\=$username_\&password\=$password_ --url $url_loc )
	command_status=$?

	# check_and grep when there is no account.
	No_acc="no active account found"

	# check if the request was ok
	if [[ $command_status == "0" ]]; then
		# put response in a log	
		echo $request_response | grep -ioP "(?<=\"detail\":\")[^\"]+" | grep -oie "$No_acc" > "/dev/null"
		# when the credentials is wrong it will return error in the status
		if [[ $? -eq 0 ]]
		then
			echo "You crendentials seems to be wrong!"
			exit 1
		fi
		echo $request_response > "./token.log"
		echo "Logged in successfully :-)"
	else
		echo "request was not ok!"
		echo "command status $command_status"
	fi
}

# ---------------------------------------------------------------------------------
# End of all function declarations.
# ---------------------------------------------------------------------------------

# if the url is provided
while getopts $options opt
do
  case $opt in
    u) request_url=$OPTARG;;
    h) display_help;exit 0;;
    \?) echo "Invalid Option provided " 1>&2; display_help; exit 1;;
    :) echo "Invalid value provided for the option " 1>&2; display_help; exit 1;;
    *) echo "Unknown Input " 1>&2; display_help; exit 1;;
  esac
done
shift $(( OPTIND -1 )) # remove all options and their values from the argument list.

if [[ $request_url = "None" ]]  
then 
	# when no url is provided
	login_request "http://localhost:8000/login" $1 $2
else
  # echo "The url is provided by user"
	login_request $request_url $1 $2
fi
