# format "hh:mm"
BEDTIME="10:34"
DISARM_TIME="05:35"


function validate_time_format() {
	# returns 1 if the time code argument doesn't follow valid hh:mm format
	if [[ $1 =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
		return 0
	fi
	return 1
}

validate_time_format ${BEDTIME} || {
	echo "BEDTIME variable doesn't follow valid hh:mm format"
	exit 1
}
validate_time_format ${DISARM_TIME} || {
	echo "DISARM_TIME variable doesn't follow valid hh:mm format"
	exit 1
}


function fetch_time_utc() {
	# sets the variable `utc_time`

	_output_file=$(mktemp)
	wget http://worldtimeapi.org/api/timezone/Etc/UTC -O ${_output_file}
	_datetime=$(cat ${_output_file} | jq -r '.utc_datetime')
	rm ${_output_file}

	utc_time=${_datetime:11:5}
	validate_time_format ${utc_time} || {
		echo 'something went wrong when fetching or decoding time from API'
		exit 1
	}
}


function trigger_shutdown() {
	shutdown now
}


function check_if_shutdown_time() {
	function convert_to_minutes() {
	    local time=$1
	    local hours=${time:0:2}
	    local minutes=${time:3:2}
	    echo $((10#$hours * 60 + 10#$minutes))
	}

	validate_time_format ${1} || {
		echo "START_TIME doesn't follow valid hh:mm format"
		exit 1
	}
	validate_time_format ${2} || {
		echo "CUR_TIME doesn't follow valid hh:mm format"
		exit 1
	}
	validate_time_format ${3} || {
		echo "END_TIME doesn't follow valid hh:mm format"
		exit 1
	}

	start_time=$1
	current_time=$2
	end_time=$3

	start_total_minutes=$(convert_to_minutes "$start_time")
	cur_total_minutes=$(convert_to_minutes "$current_time")
	end_total_minutes=$(convert_to_minutes "$end_time")

	if [[ $end_total_minutes -ge $start_total_minutes ]]; then
		if [[ $cur_total_minutes -ge $start_total_minutes && $cur_total_minutes -lt $end_total_minutes ]]; then
			trigger_shutdown
		elif [[ $cur_total_minutes -eq $start_total_minutes && $cur_total_minutes -eq $end_total_minutes ]]; then
			trigger_shutdown
		fi
	elif [[ $cur_total_minutes -ge $start_total_minutes || $cur_total_minutes -lt $end_total_minutes ]]; then
		trigger_shutdown
	fi
}


fetch_time_utc
echo "time UTC: $utc_time"

check_if_shutdown_time ${BEDTIME} ${utc_time} ${DISARM_TIME}
