#!/bin/bash
#This program is part of the except script library. 
#Read the docs more to know what it does.

#-------------------------------------------------------------------------------------
#	functions declaration
#-------------------------------------------------------------------------------------
function show_help(){
	echo ""
	echo "-- The program copy's all the items from a directory with an exception of one or more files --"
	echo "usage"
	printf "\t$0 -e {file_or_foldernames} {source_dir} {dest_dir}"
	echo ""
}
#-------------------------------------------------------------------------------------
#	functions declaration
#-------------------------------------------------------------------------------------
options="e:h"
ex_items=() # directories and files to ignore.
dest_dir="" # destination directory to copyt to.
src_dir="" # source directory to copy from.

counter=0
while getopts $options opt # get options example -e
do
	counter=`expr $counter + 1`
	case $opt in
		e) ex_items[$counter]=$OPTARG;;
		h) show_help; exit 0;;
		\?) echo "Invalid option provided!" 1>&2; show_help; exit 1;;
		:) echo "Invalid or no value provided to option!" 1>&2; show_help; exit 1;;
		*) echo "Uknown error!" 1>&2; show_help;exit 1;;
	esac
done

shift $(( OPTIND -1 ))

# check where the source and dest parameters have been passed.
case $# in 
	1) echo "Please provide the destination argument path!"; exit 1;;
	0) echo "Please provide the source and destination path!"; exit 1;;
	#*) echo "Unown error: $#"; exit 1;; 
esac

all_args=($@)
dest_dir=${all_args[`expr $# - 1`]} # assign the dest dir.
unset all_args[`expr $# - 1`] # remove the dest dir from the list.
src_dir=(${all_args[@]}) # assign the src dir.
unset all_args # unset the rest of the arguments for performance.
# echo "source dir: ${src_dir[@]}, destination dir: $dest_dir"

# if more than one file is described
if [[ ${#src_dir[@]} -gt 1 ]]
then
	# check if the destination is a directory
	if [[ !(-d $dest_dir) ]]
	then
		echo "The path is not a directory"
		exit 1
	fi
fi

: '
for src in ${src_dir}
do
done
'
