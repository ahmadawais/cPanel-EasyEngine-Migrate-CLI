#! /usr/bin/env bash
# Migrate CLI
#
# Migrates cPanel websites to EasyEngine based VPS.
#
# Version: 1.0.1
#
# @param $BACKUP_URL URL to publically downloadable .tar.gz cPanel Backup file.
# @param $BACKUP_FOLDER Backup is downloaded in this folder.
# @param $SITE_URL The old site URL we are migrating.
# @param $db_name Database name for the db that we need to import.

function cem_cli_init() {
	clear
	# Backup file name that gets downloaded.
	backup_file=b.tar.gz

	# $BACKUP_URL URL to publically downloadable .tar.gz cPanel Backup file.
	echo "——————————————————————————————————"
	echo "👉  Enter PATH to a publically downloadable cPanel backup [E.g. http://URL.com/backup.tar.gz]:"
	echo "——————————————————————————————————"
	read -r BACKUP_URL

	# $SITE_URL The old site we are migrating.
	echo "——————————————————————————————————"
	echo "👉  Enter the SITE URL for the site are migrating in this format → [E.g. siteurl.com]:"
	echo "——————————————————————————————————"
	read -r SITE_URL
	BACKUP_FOLDER=$SITE_URL

	# $db_name Database name for the db that we need to import.
	echo "——————————————————————————————————"
	echo "👉  Enter the DATABASE name for the db that we need to import → [E.g. site_db]:"
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

		# Add the backup content.
		rsync -avz --info=progress2 --progress --stats --human-readable --exclude 'wp-config.php' --exclude 'wp-config-sample.php' "$init_dir"/backup/homedir/public_html/* /var/www/"$SITE_URL"/htdocs/

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
		read -r is_search_replace

		if [[ "$is_search_replace" == "y" ]]; then
			# $search_query The query of search.
			echo "——————————————————————————————————"
			echo "👉  Enter what you need to SEARCH? [E.g. https://domain.com ]:"
			echo "——————————————————————————————————"
			read -r search_query

			# $replace_query The query of replace.
			echo "——————————————————————————————————"
			echo "👉  Enter what you need to REPLACE the search with? [E.g. http://domain.com ]:"
			echo "——————————————————————————————————"
			read -r replace_query

			# Search replace new site.
			wp search-replace "$search_query" "$replace_query" --path=/var/www/"$SITE_URL"/htdocs/ --allow-root

			echo "——————————————————————————————————"
			echo "🔥  Search Replace is done."
			echo "——————————————————————————————————"
		fi

		echo "——————————————————————————————————"
		echo "🔥  Your migrated site is ready."
		echo "——————————————————————————————————"
		echo "ℹ️  TIP: Edit your systems' hosts files to add the IP and check if the site you migrated is working fine or not."
		echo "——————————————————————————————————"

	else
		echo "——————————————————————————————————"
		echo "❌  Backup Download Failed 👎"
		echo "——————————————————————————————————"
		echo "ℹ️  TIP: Check if the backup URL you added is a publically downloadable .tar.gz file."
		echo "——————————————————————————————————"

		# Get back to where we were.
		cd ..
		rm -f "$backup_file"
		exit 1;
	fi
}

# Run the CLI.
cem_cli_init
