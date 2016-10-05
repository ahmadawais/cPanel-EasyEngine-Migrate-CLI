#! /usr/bin/env bash
# Migrate CLI
#
# Migrates cPanel websites to EasyEngine based VPS.
#
# Version: 1.1.0
#
# @param $BACKUP_URL URL to publically downloadable .tar.gz cPanel Backup file.
# @param $BACKUP_FOLDER Backup is downloaded in this folder.
# @param $SITE_URL The old site URL we are migrating.
# @param $db_name Database name for the db that we need to import.
# @param $IS_SUBDOMAIN Is it a subdomain?
# @param $SUBDOMAIN_FOLDER: The sub domain folder.

function cem_cli_init() {
	clear
	cd ~

	# Backup file name that gets downloaded.
	BACKUP_FILE=b.tar.gz

	# $BACKUP_URL URL to publically downloadable .tar.gz cPanel Backup file.
	echo "——————————————————————————————————"
	echo "-"
	echo " ⚡️ CEM CLI — cPanel to EasyEngine Migration CLI"
	echo "Version 1.1.0"
	echo "Migrates cPanel websites to EasyEngine based self hosted VPS"
	echo "-"
	echo "——————————————————————————————————"

	echo "-"
	echo "——————————————————————————————————"
	echo "-"
	echo " ℹ️  Pre CEM CLI Checklist:"
	echo " ␥  1. Have you installed EasyEngine? If not then do it (INFO: https://easyengine.io/docs/install/)?"
	echo " ␥  2. Did you install WPCLI from EasyEngine Stacks? (INFO: https://easyengine.io/docs/commands/stack/)"
	echo " ␥  3. Do you have a publically downloadable full backup of your cPanel?"
	echo " ␥  4. Do you have your site's DB Name, USER, PASS, and PREFIX? You can find this inside 'wp-config.php' file."
	echo " ␥  5. Have you set EasyEngine to ask for DB Name, USER, PASS, and PREFIX? If not then do that by 'sudo nano /etc/ee/ee.conf' (INFO: https://easyengine.io/docs/config/)"
	echo "-"
	echo " INFO: All the above steps above are required for CEM CLI to work."
	echo "-"
	echo "——————————————————————————————————"
	echo "-"

	echo "-"
	echo "——————————————————————————————————"
	echo "👉  Enter PATH to a publically downloadable cPanel backup [E.g. http://domain.ext/backup.tar.gz]:"
	echo "——————————————————————————————————"
	echo "-"
	echo "NOTES:"
	echo " ␥	1. Backup your site on cPanel via Backup Wizard > Backup > Full Backup > Generate Backup"
	echo " ␥	2. Move the backup to /public_html/ "
	echo " ␥	3. Set the backup file permission 0004"
	echo "-"
	echo "——————————————————————————————————"
	read -r BACKUP_URL

	# $SITE_URL The old site we are migrating.
	echo "——————————————————————————————————"
	echo "👉  Enter the SITE URL for the site you are migrating in eaxaclty this format → [E.g. domain.ext or sub.domain.ext]:"
	echo "——————————————————————————————————"
	echo "-"
	echo "NOTES:"
	echo " ␥	1. Site name entered here will be created as a site with EasyEngine"
	echo " ␥	2. It's a good practice to be in your server root while running CEM CLI."
	echo "-"
	echo "——————————————————————————————————"
	read -r SITE_URL
	BACKUP_FOLDER=$SITE_URL

	# $IS_SUBDOMAIN Is it a subdomain?
	echo "——————————————————————————————————"
	echo "👉  Is this a SUB DOMAIN? Enter [ y | n ]:"
	echo "——————————————————————————————————"
	read -r IS_SUBDOMAIN

	if [[ "y" == $IS_SUBDOMAIN || "Y" == $IS_SUBDOMAIN ]]; then
		# $SUBDOMAIN_FOLDER: The sub domain folder.
		echo "——————————————————————————————————"
		echo "👉  Enter the SubDomain FOLDER NAME → [E.g. subdomain ]:"
		echo "——————————————————————————————————"
		echo "-"
		echo "NOTES:"
		echo " ␥	1. Each subdomain in cPanel has a folder connected to it inside /public_html/."
		echo " ␥	2. That folder name is what you need to enter here."
		echo "-"
		echo "——————————————————————————————————"
		read -r SUBDOMAIN_FOLDER
	fi

	# $db_name Database name for the db that we need to import.
	echo "——————————————————————————————————"
	echo "👉  Enter the DATABASE name for the db that we need to import → [E.g. site_db]:"
	echo "——————————————————————————————————"
	echo "-"
	echo "NOTES:"
	echo " ␥	1. It's important that the database name should be the same as you have on the old host."
	echo " ␥	2. This will be used to search for the database backup inside you downloaded backup."
	echo "-"
	echo "——————————————————————————————————"
	read -r db_name

	# Make the backup dir and cd into it.
	mkdir -p "$BACKUP_FOLDER" && cd "$BACKUP_FOLDER"

	# Save the PWD.
	init_dir=$(pwd)

	echo "——————————————————————————————————"
	echo "⏲  Downloading the backup..."
	echo "——————————————————————————————————"

	if wget "$BACKUP_URL" -O 'b.tar.gz' -q --show-progress  > /dev/null; then
		echo "——————————————————————————————————"
		echo "🔥  Backup Download Successful 💯"
		echo "——————————————————————————————————"
		echo "⏲  Now extracting the backup..."
		echo "——————————————————————————————————"

		# Make new dir
		mkdir backup

		# Un tar the backup,
		# -C To extract an archive to a directory different from the current.
		# --strip-components=1 to remove the root(first level) directory inside the zip.
		tar -xvzf $backup_file -C backup --strip-components=1

		echo "——————————————————————————————————"
		echo "🔥  Backup Extracted to the folder 💯"

		# Delete the backup since you might have lesser space on the server.
		rm -f b.tar.gz

		echo "——————————————————————————————————"
		echo "⏲  Let's create the old site with EasyEninge..."
		echo "——————————————————————————————————"

		# Create the site with EE.
		ee site create "$SITE_URL" --wp

		echo "——————————————————————————————————"
		echo "⏲  Copying backup files where the belong..."
		echo "——————————————————————————————————"

		# Remove new WP content.
		rm -rf /var/www/"$SITE_URL"/htdocs/*

		if [[ "y" == $IS_SUBDOMAIN || "Y" == $IS_SUBDOMAIN ]]; then
			# Add the backup content.
			rsync -avz --info=progress2 --progress --stats --human-readable --exclude 'wp-config.php' --exclude 'wp-config-sample.php' "$init_dir"/backup/homedir/public_html/"$SUBDOMAIN_FOLDER"* /var/www/"$SITE_URL"/htdocs/
		else
			# Add the backup content.
			rsync -avz --info=progress2 --progress --stats --human-readable --exclude 'wp-config.php' --exclude 'wp-config-sample.php' "$init_dir"/backup/homedir/public_html/* /var/www/"$SITE_URL"/htdocs/
		fi

		echo "——————————————————————————————————"
		echo "🔥  Backup files were synced with the migrated site."
		echo "——————————————————————————————————"

		echo "——————————————————————————————————"
		echo "⏲  Now importing the SQL database..."
		echo "——————————————————————————————————"

		# Import the DB of old site to new site.
		wp db import "$init_dir"/backup/mysql/"$db_name".sql --path=/var/www/"$SITE_URL"/htdocs/ --allow-root

		# Delete the backup since you might have lesser space on the server.
		cd ..
		rm -rf $SITE_URL

		# Remove the wp-config.php and sample files.
		rm -f /var/www/$SITE_URL/htdocs/wp-config.php
		rm -f /var/www/$SITE_URL/htdocs/wp-config-sample.php

		# $is_search_replace y if search replace is needed.
		echo "——————————————————————————————————"
		echo "👉  Do you want to search and replace something? [ y/n ]:"
		echo "——————————————————————————————————"
		echo "-"
		echo "NOTES:"
		echo " ␥	1. It will run only once."
		echo " ␥	2. This is powered by WPCLI (INFO: http://wp-cli.org/commands/search-replace/)."
		echo "-"
		echo "——————————————————————————————————"
		read -r is_search_replace

		if [[ "$is_search_replace" == "y" ]]; then
			# $search_query The query of search.
			echo "——————————————————————————————————"
			echo "👉  Enter what you need to SEARCH? [E.g. http://domain.ext ]:"
			echo "——————————————————————————————————"
			echo "-"
			echo "NOTES:"
			echo " ␥	1. WP CLI will search for what you enter here.."
			echo " ␥	2. Enter what you want to be searched and replaced"
			echo " ␥	3. E.g. if you want to change http:// to https:// then enter http://domain.ext here."

			echo "-"
			echo "——————————————————————————————————"
			read -r search_query

			# $replace_query The query of replace.
			echo "——————————————————————————————————"
			echo "👉  Enter what you need to REPLACE the search with? [E.g. http://domain.com ]:"
			echo "——————————————————————————————————"
			echo "-"
			echo "NOTES:"
			echo " ␥	1. WP CLI will replace what you entered before with what you'll enter here."
			echo " ␥	2. Enter what you want to replace your searched query."
			echo " ␥	3. E.g. if you want to change http:// to https:// then enter https://domain.ext here."
			echo "-"
			echo "——————————————————————————————————"
			read -r replace_query

			# Search replace new site.
			wp search-replace "$search_query" "$replace_query" --path=/var/www/"$SITE_URL"/htdocs/ --allow-root

			echo "——————————————————————————————————"
			echo "🔥  Search Replace is done."
			echo "——————————————————————————————————"
		fi

		echo "——————————————————————————————————"
		echo "-"
		echo "🔥  ✔︎✔︎✔︎ MIGRATION completed for site: $SITE_URL. ✔︎✔︎✔︎"
		echo "-"
		echo "——————————————————————————————————"

	else
		echo "——————————————————————————————————"
		echo "❌  Backup Download Failed 👎"
		echo "——————————————————————————————————"
		echo "ℹ️  TIP: Check if the backup URL you added is a publically downloadable .tar.gz file."
		echo "-"
		echo "NOTES:"
		echo " ␥	1. Backup your site on cPanel via Backup Wizard > Backup > Full Backup > Generate Backup"
		echo " ␥	2. Move the backup to /public_html/ "
		echo " ␥	3. Set the backup file permission 0004"
		echo " ␥	4. Start CEM CLI again with command 'cemcli'"
		echo "-"
		echo "——————————————————————————————————"

		# Get back to where we were.
		cd ..
		rm -f "$backup_file"
		exit 1;
	fi
}

# Run the CLI.
cem_cli_init
