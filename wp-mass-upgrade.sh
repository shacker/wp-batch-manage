#!/bin/sh
# Batch-update WordPress .svn installations.
# We now assume you have SuPHP installed - perms are set to owner, not nobody!

# Iterate over array of installations and split vars into components:
# path|URL|email|owner
# cd to path, back up db run svn sw [to latest tag release]
# Send email to owner noting new features and that one-click db upgrade may be required.

# If you want to send email announcements only without modifing files, use wp-mass-email.sh

# Path on server where wp-mass-tools are kept:
scriptpath='/root/scripts/wp-mass-tools'

# Full path to the svn binary on your system (use 'which svn' to obtain if not sure)
svnpath='/usr/bin/svn'

mailpath='/bin/mail'

# ===================

# Current version and tag URL, to which all blogs will be upgraded
echo -n "WordPress version? "; read ver
wptagurl="http://svn.automattic.com/wordpress/tags/$ver/"


echo -n "Upgrading sites to version $ver. Is this correct? (y/n) "
read answer
if [ $answer != "y" ]; then
  echo  "Halting. Try again."
  exit
fi


echo -n "Did you remember to edit the email announcement ($scriptpath/email.txt) that will be sent out? "
read answer
if [ $answer != "y" ]; then
  echo  "Halting. Please get version info from http://wordpress.org/development/ "
  exit
fi

# Read in the array of WP sites from external file
source $scriptpath/wp-sites.sh

echo "Upgrading blogs to $ver"
echo

# Iterate through array, upgrading each
for blog in ${sites[@]}
do
	dir=$(echo $blog | cut -f1 -d\|)
	url=$(echo $blog | cut -f2 -d\|)
	email=$(echo $blog | cut -f3 -d\|)
	owner=$(echo $blog | cut -f4 -d\|)	
	echo "Upgrading WordPress installation:"
	echo "Dir: $dir"
	echo "URL: $url"
	echo "E-mail: $email"
	echo "User: $owner"	
	echo
  
  # Safeguard - in case the array of sites has a blank line at the end. 
  # Bail out before we start changing permissions on the wrong files!
  if [[ $dir != */home/* ]]; then  echo "Script is working in the wrong place - remove blank lines from your array. Exiting"; exit; fi

  # From here on, do all work is in the installation directory
  cd $dir
  
	# Get the database name fro the config
	dbname=`grep -i "db_name" wp-config.php | sed s/define\(\'DB_NAME\',\ //g | sed s/\).*$//g | sed s/\'//g`
	
	# Back up the existing db. We'll only keep one copy, overwriting the old.
	# To accomodate old versions of the script, which put the db backup in the current dir,
	# we check both in the current dir and in the home (the new location)
	# OLD location
	if [ -f $dbname.sql.gz ]
    then
    	rm -f $dbname.sql.gz
  fi
  
  # NEW location - Stick a db backup in the home dir
  backupdbpath="/home/${owner}/${dbname}.sql.gz"
  if [ -f $backupdbpath ]
    then
    	rm -f $backupdbpath
  fi
	

  mysqldump $dbname > $dbname.sql
  gzip $dbname.sql
  chown -R $owner:$owner $dbname.sql.gz
  mv $dbname.sql.gz $backupdbpath
	echo "Backed up database as $backupdbpath."   
	
	# For the 2.x - 3.0 upgrade  - back up the default theme directory in case site owner
	# was using or had modified it - otherwise the svn update command will delete it!
	if [ -d "wp-content/themes/default" ]
    then
    	cp -r wp-content/themes/default wp-content/themes/default-bak 
    fi

    # OK, let's do the upgrade.	
    cd $dir
    $svnpath sw $wptagurl .
	echo 
	echo "If no errors shown above, upgrade successful."
	echo "Fixing permissions..."

    # Setting perms for phpusexec systems - tweak if on a non-phpsuexec system	
    chown -R $owner:$owner *
    find . -type d -exec chmod 755 {} \;
    find . -type f -exec chmod 644 {} \;
    chmod 600 wp-config.php
    echo
    
    	
	# Send announcement email
    echo "$msgtext" | $mailpath -s "Your WordPress installation has been updated" $email < $scriptpath/email.txt
    echo
    echo "Upgrade announcement email sent."
    echo "------------------------------------"
    echo
done

