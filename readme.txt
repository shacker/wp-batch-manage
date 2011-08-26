WP-Mass-Tools v1.2.1
Scot Hacker (shacker@birdhouse.org)
http://birdhouse.org/software

*** These tools must be run by root - they are not for users of standard hosting accounts. ***

WP-Mass-Tools is a collection of tools (bash shell scripts) for managing lots of disparate WordPress installations on a single server. The system assumes you're working on a cPanel-based server, but it can be easily modified to work on other systems instead. All installations are  checked out via subversion, and their locations listed in a file. When upgrade time comes, a script is run to iterate through all registered sites, back up their databases just in case, and upgrade (svn sw) them to the new version. 

HOW TO USE WP-MASS-TOOLS

Unzip the package to a directory somewhere safe on the server (such as /root/scripts/wp-mass-tools/*)

Edit a couple of variables at the top of wp-mass-plugins.sh and wp-mass-upgrade.sh, setting the path to where the tools are kept, the path to svn on your server, and the path to the "mail" binary on your server. You'll also be putting the server's root db password in some of these - PROTECT THE WHOLE DIRECTORY WITH CHMOD 700!!!

TO INSTALL NEW WORDPRESS SITES:


sh /path/to/scripts/wp-create.sh

Simply follow the prompts. When it's done, it will spit out a new line, to be added to the bottom of wp-sites.sh. You must add the line to wp-sites.sh manually - it's not done automatically. 

IMPORTANT FOR CPANEL ADMINISTRATORS: Because cPanel has changed the database creation API, this script no longer creates databases on cPanel systems. You'll need to create the database manually through cPanel, then run this script with matching credentials. If you can help modify this system to utilize the new cPanel APIs, please contribute code!


CHECK FOR PLUGIN COMPATIBILITY
If a major WP release has been made and you're worried about plugins breaking, you can use wp-mass-plugins.sh to spit out a list of all active plugins on all sites on the server. You can then compare the list to lists of known incompatible plugins on the internet. 

Usage:

sh /path/to/scripts/wp-mass-plugins.sh > plugin_report.txt


UPGRADING EXISTING SITES:

To upgrade sites, first edit the file email.txt - the contents of this file will be sent to all users listed in wp-sites.sh! The script will ask you to confirm that you've edited the file so you don't embarrass yourself by sending out an old one (which has never happened to me, of course ;)

Take a look in wp-sites.sh and make sure you really do want to upgrade everything listed there. If you want to skip a site, simply comment it out for now. Then:

sh /path/to/scripts/wp-mass-upgrade.sh | tee wpuplog.txt

and follow the prompts. You'll see the output live, but will also have a complete record of the process in wpuplog.txt, which you should page through later to make sure there aren't any unexpected errors (e.g. sometimes customers will move their directories around and you'll need to update the paths in your site array).


VERSION NOTES:

1.1 Updated to use array of sites in a separate file

1.2 No longer attempts to create the database on cPanel systems. Changes permissions modification to work on phpsuexec servers. In other words, it no longer changes ownership to user:nobody, but to user:user. Added protection against a situation - a bug - where if the array of sites had a blank line at the end, it would cd to / and start changing permissions!


