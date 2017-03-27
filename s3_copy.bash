#!/usr/bin/env bash

#set -eou pipefail # strict mode

#\S+(?=\-)/g
#(?<=\-)\d+

function copy_command() {

	local domain_name="s3://ewe-trafficintelligence-test"
	local filename=$(echo "$1" | perl -ne 'print "$&" if /\S+(?=\-)/')
	local filepath="$filename"
	#local filename=$(echo "$1" | perl -ne 'print "$&" if /.+?(?=((\.[^.\s]+)+))/')

	case "$2" in
		geo)
			local subfolder="/gaia"
			;;
		business)
			local subfolder="/business"
			;;
		temporality)
			local subfolder="/temporality"
			;;
	esac

	# deal with timestamp file names. parsing out of year/month/day
	if [[ $filename = *[!\ ]* ]]; then
		local timestamp=$(echo "$1" | perl -ne 'print "$&" if /(?<=\-)\d+/')
	else
		filepath=$(echo "$1" | perl -ne 'print "$&" if /\S+(?=\.)/')
		local timestamp=`date +%Y%m%d%H%M%S`
	fi

	local pathyear=${timestamp:0:4}
	local pathmonth=${timestamp:4:2}
	local pathday=${timestamp:6:2}

	# change echo to eval for excuting the line
	eval "aws s3 cp $1 $domain_name/dev/LZ/trafficintelligence$subfolder/$filepath/$pathyear/$pathmonth/$pathday/"
	# "aws s3 cp $domain_name/test/LZ/trafficintelligence$subfolder/$filepath/$pathyear/$pathmonth/$pathday/$1 $domain_name/dev/LZ/trafficintelligence$subfolder/$filepath/$pathyear/$pathmonth/$pathday/"
}

# ls -p | grep / > list all folders
# ls -p | grep -v / > list all files besides folders
function filelist() {
	if [ -d "$1" ]; then
		cd $1
			temparray=( $(ls -p | grep -v /) )

			for i in ${temparray[@]}
			do
				copy_command $i $1
			done
		cd ..
	fi
}

# geo files
filelist "geo"

# temp files
filelist "temporality"

# business files
filelist "business"

exit
