#!/bin/sh
# Obtain a list of all plugins on all WP sites on the server.
# Before a major upgrade, redirect output to a file and compare
# to a list of known-incompatible plugins.
# This script is always safe to run and does not change anything.


# Iterate over array of installations and split vars into components:
# path|URL|email|owner

# Path on server where wp-mass-tools are kept:
scriptpath='/root/scripts/wp-mass-tools'

# Read in the array of WP sites from external file
source ./wp-sites.sh

echo "Extracting list of plugins"
echo

# Iterate through array, upgrading each
for blog in ${site[@]}
do
	#echo $blog
	dir=$(echo $blog | cut -f1 -d\|)
	url=$(echo $blog | cut -f2 -d\|)
	email=$(echo $blog | cut -f3 -d\|)
	owner=$(echo $blog | cut -f4 -d\|)	
	
	# Get the db name from wp-config. 
    cd $dir	
	dbname=`grep -i "db_name" wp-config.php | sed s/define\(\'DB_NAME\',\ //g | sed s/\).*$//g | sed s/\'//g`
	
	echo
	echo "Examining WordPress installation:"
	echo "Dir: $dir"
	echo "URL: $url"
	echo "E-mail: $email"
	echo "User: $owner"	
	echo "Database: $dbname"
	    
    # List of active plugins is serialized in a single db field and difficult to extract from shell.
    # Use an external PHP script to grab them instead. 
    echo
    echo "Active plugins:"
    php -f $scriptpath/wp-find-plugins.php $dbname
    echo
    echo "-------------------"
    echo
	
done

