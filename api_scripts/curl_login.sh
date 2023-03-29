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

  printf "Example:\n\t$0 -u localhost:9000/login admin root\n\tLogin providing a the url.\n\n\t$0 admin root\n\tLogin providing only username and password using the default url\n\n"
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
shift $(( OPTIND -1 ))

echo the request url $request_url
echo "all arguments $@"
