# format "hh:mm"
BEDTIME="10:00"
DISARM_TIME="05:00"


function validate_time_format() {
	# returns 1 if the time code argument doesn't follow valid hh:mm format
	if [[ $1 =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
		return 0
	fi
	return 1
}

validate_time_format ${BEDTIME} ||
	(echo "BEDTIME variable doesn't follow valid hh:mm format"; exit 1)
validate_time_format ${DISARM_TIME} ||
	(echo "DISARM_TIME variable doesn't follow valid hh:mm format"; exit 1)


function fetch_time_utc() {
	# sets the variable `utc_time`

	_output_file=$(mktemp)
	wget http://worldtimeapi.org/api/timezone/Etc/UTC -O ${_output_file}
	_datetime=$(cat ${_output_file} | jq -r '.utc_datetime')
	rm ${_output_file}

	utc_time=${_datetime:11:5}
	validate_time_format ${utc_time} ||
		(echo 'something went wrong when fetching or decoding time from API'; exit 1)
}

fetch_time_utc
echo "time UTC: $utc_time"
