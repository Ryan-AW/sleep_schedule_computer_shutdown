function fetch_datetime_utc() {
	# sets the variable `datetime` to UTC time

	_output_file=$(mktemp)
	wget http://worldtimeapi.org/api/timezone/Etc/UTC -O ${_output_file}
	datetime=$(cat ${_output_file} | jq -r '.utc_datetime')
	rm ${_output_file}
}


fetch_datetime_utc
echo "the datetime is $datetime"
