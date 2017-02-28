#!/bin/bash
if [ -z "$PUSHOVER_APP_TOKEN" ] || [ -z "$PUSHOVER_USER_KEY" ]
then
	echo "Pushover environment variables missing" >&2
	exit 1
fi

title="$1"
priority="$2"
shift 2
message="$@"

# Check for required arguments
if [ -z "$title" ] || [ -z "$priority" ] || [ -z "$message" ]
then
	echo  "Usage: $(basename $BASH_SOURCE) <title> <priority> <message>" >&2
	exit 1
fi

# Validate priority
case "$priority" in
	lowest)
		priority_int=-2
		;;
	low)
		priority_int=-1
		;;
	normal)
		priority_int=0
		;;
	high)
		priority_int=1
		;;
	emergency)
		priority_int=2
		;;
	*)
		echo "Invalid priority '$priority'" >&2
		exit 1
		;;
esac

# Send notification
if curl -s \
    --form-string "token=${PUSHOVER_APP_TOKEN}" \
    --form-string "user=${PUSHOVER_USER_KEY}" \
    --form-string "title=${title}" \
    --form-string "priority=${priority_int}" \
    --form-string "message=${message}" \
    https://api.pushover.net/1/messages |
		jq -e '.status == 2' > /dev/null
then
	echo "Failed to send push notification" >&2
	exit 1
fi

