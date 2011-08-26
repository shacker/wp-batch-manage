#!/bin/sh

# WP-Create 1.2 :: Creates a new client WP installation via svn quickly.
# Use wp-mass-upgrade.sh to upgrade sites, i.e. One script to do quick WP svn checkouts, 
# database setup, etc. and another to mass upgrade all WP installations on a server.
# See the readme for information on why this script no longer creates databases.

# Scot Hacker :: http://birdhouse.org/blog

# This script performs the following tasks:
# * Gather installation info
# * Create install dir and check out a copy of WordPress
# * Create database (not currently doing this), db user, set db privs via external .sql file
# * Create WP config file
# * Create upload dir and set filesystem permissions
# * Generate array line for wp-sites.sh
# Final setup is done via browser


# Database root pass - protect this script with chmod 700 !!!
DBROOT="dppass"

# Full path to the svn binary on your system (use 'which svn' to obtain if not sure)
svnpath='/usr/bin/svn'

####################################################
# Gather data

echo
echo -n "WordPress version? "; read wpver
echo -n "System account (e.g. fred) "; read owner
echo -n "Install path (e.g. /home/fred/public_html/blog)? "; read install_path
echo -n "URL (without http, e.g. somedomain.com/blog)? " ; read url
echo -n "Owner email? "; read email
echo -n "Database user? (n.b.: username will be prepended) "; read dbuser
echo -n "Database name? (n.b.: username will be prepended) "; read dbname
echo -n "Database pass? "; read dbpass


# Modify the db and db account names as necessary for the server you're on. For
# example this can be used to prepend "wp-" to the start of WordPress database
# names, or to use cPanel db naming format. 
# For one server, we use the format wp-dbname
# thedb=wp\-${dbname}
# thedbacct=$dbuser

# Concatenate db name and username in cPanel standard format

# Weird quirk: In cPanel, the database name will not appear associated with the username in the
# graphical control panel unless you escape the underscore in the database name in the GRANT
# statement. So we have two variants for $thedb - one with the underscore escaped and the other not.
# If you're not on a cPanel system, season to taste.

thedb1=${owner}_${dbname}
thedb2=${owner}\\_${dbname}
thedbacct=${owner}_${dbuser}

echo
echo "
Version: $wpver
Owner: $owner
Path: $install_path
URL: http://$url
Owner email: $email
Database name: $thedb1
Database user: $thedbacct
Database pass: $dbpass
"

# Verify
echo
echo -n "Is this correct? (y/n) " ; read correct
if [ $correct != "y" ]; then
	echo "Bzzzzt. Start over."
	exit;
else 
	echo
	echo "Installing WordPress..."
	echo
fi

####################################################
# Create install dir and check out a copy of WordPress

if [ ! -d $install_path ]; then
	mkdir -p $install_path
fi
cd $install_path
$svnpath co http://svn.automattic.com/wordpress/tags/$wpver/ .


####################################################
# Create database, db user, set db privs via external .sql file
# Temporarily not working until cPanel db API problems are worked out.


cat <<EOT >$install_path/wp-db.sql
CREATE DATABASE \`$thedb1\`;
GRANT ALL ON \`$thedb2\`.* TO '$thedbacct'@'localhost' IDENTIFIED BY '$dbpass';
FLUSH PRIVILEGES;
EOT

# Feed the db
# This is temporarily commented out until the cPanel db API problems are worked out
# mysql -u root -p$DBROOT < $install_path/wp-db.sql

# Clean up
rm $install_path/wp-db.sql


####################################################
# Create WP config file

cat <<EOT >wp-config.php
<?php
// ** MySQL settings ** //
define('DB_NAME', '$thedb1');    // The name of the database
define('DB_USER', '$thedbacct');     // Your MySQL username
define('DB_PASSWORD', '$dbpass'); // ...and password
define('DB_HOST', 'localhost');    // 99% chance you won't need to change this value
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Change SECRET_KEY to a unique phrase.  You won't have to remember it later,
// so make it long and complicated.  You can visit https://www.grc.com/passwords.htm
// to get a phrase generated for you, or just make something up.
define('SECRET_KEY', '$email $thedb1 $owner $thedbacct'); // Unique set of strings to create key

// You can have multiple installations in one database if you give each a unique prefix
\$table_prefix  = 'wp_';   // Only numbers, letters, and underscores please!

// Change this to localize WordPress.  A corresponding MO file for the
// chosen language must be installed to wp-content/languages.
// For example, install de.mo to wp-content/languages and set WPLANG to 'de'
// to enable German language support.
define ('WPLANG', '');

/* That's all, stop editing! Happy blogging. */

define('ABSPATH', dirname(__FILE__).'/');
require_once(ABSPATH.'wp-settings.php');
?>
EOT

####################################################
# Create upload dir and set filesystem permissions.
# Note that perms are set for phpsuexec systems - this 
# will need to be tweaked if not using phpsuexec.
mkdir -p wp-content/uploads
chown -R $owner:$owner *
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

####################################################
# Report
echo
echo "Installation complete. Please visit http://$url to complete setup."
echo
echo "Add this line to wp-sites.sh:"
echo "\"$install_path|$url|$email|$owner\""
echo

