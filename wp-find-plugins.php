<?php

# Root database password - PROTECT THIS FILE WITH chmod 700 !!!!
$pw = 'dbpass';

/*

PHP command-line shell script to access the WordPress database and print out the list of active plugins.
This script does NOT auto-upgrade plugins - it simply reports on which plugins are in use so you can
compare them to lists of known-incompatible plugins before upgrading sites.
You shouldn't need to call this directly - it gets called from wp-mass-plugins.sh. 
Just configure the db password below.

From http://gist.github.com/506055

ORIGINAL SYNTAX:

   php wp-active-plugins.php $host $db $user $pw

For example:

   php wp-active-plugins.php localhost my_wp_db my_wp_login abc123

By Mike Schinkel (http://mikeschinkel.com/custom-wordpress-plugins/)

Licensed GPLv2

This script has been slightly modified by Scot Hacker. Usage is now simply:
php -f /path/to/wp-find-plugins.php $dbname
*/

list($script,$db) = $_SERVER['argv'];
$host = 'localhost';
$user = 'root';

$link = mysql_connect($host,$user,$pw);
if (!$link) {
    die('Could not connect: ' . mysql_error());
}

$db_selected = mysql_select_db($db, $link);
if (!$db_selected) {
    die ("Can\'t use $db: " . mysql_error());
}

$result = mysql_query("SELECT option_value FROM wp_options WHERE option_name = 'active_plugins'");
if (!$result) {
    die('Invalid query: ' . mysql_error());
}

$row = mysql_fetch_assoc($result);
$plugins = unserialize($row['option_value']);

foreach($plugins as $plugin) 
	echo "$plugin\n";

mysql_free_result($result);

mysql_close($link);
?>