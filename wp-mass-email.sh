#!/bin/sh
# Send email ONLY to site owners listed in wp-sites.sh - does not modify any files
# Use this script if you simply want to announce something to your bloggers.


# Path on server where wp-mass-tools are kept:
scriptpath='/root/scripts/wp-mass-tools'

# Path to mail binary. Use 'which mail' to discover
mailpath='/bin/mail'

# ===================

echo -n "This script sends live email to recipients in wp-sites.sh. Continue? (y/n)"
read answer
if [ $answer != "y" ]; then
  echo  "Halting."
  exit
fi


echo -n "Did you remember to edit the email announcement ($scriptpath/email.txt) that will be sent out? "
read answer
if [ $answer != "y" ]; then
  echo  "Halting."
  exit
fi

echo "Please enter the subject line to use:"
read subjline

# Read in the array of WP sites from external file
source $scriptpath/wp-sites.sh


# Iterate through array
for blog in ${sites[@]}
do
	dir=$(echo $blog | cut -f1 -d\|)
	url=$(echo $blog | cut -f2 -d\|)
	email=$(echo $blog | cut -f3 -d\|)
	owner=$(echo $blog | cut -f4 -d\|)	
	echo "Sending email to:"
	echo "E-mail: $email"
	echo "User: $owner"	
	echo

    	
	# Send announcement email
    echo "$msgtext" | $mailpath -s $subjline $email < $scriptpath/email.txt
    echo
    echo "Announcement email sent to $email"
    echo "------------------------------------"
    echo
done

