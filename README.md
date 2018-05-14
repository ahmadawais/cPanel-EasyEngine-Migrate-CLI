# cPanel-EasyEngine-Migrate-CLI (CEM CLI)

[![CEM CLI](https://img.shields.io/badge/Built%20For%20WordPress-%E2%93%A6-lightgrey.svg?style=flat-square)](https://labs.ahmadawais.com/cem-cli/)

cPanel to EasyEngine Migrate CLI (CEM CLI) is a bash script built to help people migrate their sites from a cPanel to a rented VPS with EasyEngine installed on it.

![CEM CLI](https://i.imgur.com/y5BKyPF.png) 

## Pre-requisite
You need to rent a VPS with EasyEngine installed on it. Here's the list.

- Rent a VPS preferably with <kbd>Ubuntu 16.04 x64 OS</kbd> (I recommend Vultr.com | During summer, by using my affiliate link you [get $20 Signup Bonus](http://www.vultr.com/?ref=6942485-3B) or if you prefer [non-affiliate link](http://www.vultr.com/))
- Install [EasyEngine](https://easyengine.io/) just run this command after logging into your VPS with SSH `wget -qO ee rt.cx/ee && sudo bash ee`

## Using CEM CLI
After you have completed the pre-requisite steps, all you need to do is download and run the cPanel-EasyEngine-Migrate-CLI. You can do that by running the following commands.

Download `cPanel-EasyEngine-Migrate-CLI`

```bash
sudo wget -qO cemcli https://git.io/vPO0q && sudo chmod +x ./cemcli && sudo install ./cemcli /usr/local/bin/cemcli
```

Run `cPanel-EasyEngine-Migrate-CLI`

```bash
cemcli
```

To Uninstall `cPanel-EasyEngine-Migrate-CLI`

```bash
rm /usr/local/bin/cemcli
```

Running this CLI will output several questions on your terminal. Each question comes with an example value enclose with square brackets `[]`. Just fill up the answers and you'll be able to automate bits of the complete migration process.

## How To?
Yes, I get that. This script is quite opinionated and in the beta stage. While I have released v1.0.0 it still needs to be tested and I plan to maintain and grow it. If you are wondering how it works, here's a step by step guide.

---

### Step #1: VPS

Rent a VPS preferably with <kbd>Ubuntu 16.04 x64 OS</kbd> (I recommend Vultr.com | During summer, by using my affiliate link you [get $20 Signup Bonus](http://www.vultr.com/?ref=6942485-3B) or if you prefer [non-affiliate link](http://www.vultr.com/))

---

### Step #2: EasyEngine 

Install [EasyEngine](https://easyengine.io/) and run this command after logging into your VPS with SSH `wget -qO ee rt.cx/ee && sudo bash ee`

---

### Step #3: Backup

Take a backup of your cPanel. I prefer taking a complete backup and that's how this script works. 
1. Go to your site's  <kbd>cPanel > Backup Wizard</kbd> 
2. Click <kbd>Backup</kbd>, then <kbd>Full Backup</kbd> and finally click on <kbd>Generate Backup</kbd>
3. Once the backup is generated, go to <kbd>File Manager</kbd>
4. Rename the backup file to something simple like <kbd>bc.tar.gz</kbd>
5. Move the backup file to `/public_html/` folder
6. Set the world read permission so that it can be downloaded via wget

You can watch all these steps in this short video which can be found at the end of these steps.

---

### Step #4: Run CEM CLI

- It's time to run the CEM CLI. Log in to your VPS via SSH.
- Install CEM CLI by running install command as mentioned above command.
- Then run `cemcli` command and start answering the questions as I did in the video below.

---

### Step #5: What you need to know!

While the CLI migrates your site for you, this following things happen. 
- CEM CLI Downloads the backup in a folder you specified (I recommend running CEM CLI from the root i.e. `cd ~`).
- Then CEM CLI extracts the backup inside a folder called backup.
- After that CEM CLI runs EasyEngine to install your site from the scratch (You need to edit [EasyEngine's configuration](https://easyengine.io/docs/config/) file to make sure EasyEngine should ask you for entering the `Database Name`, `Database Username`, `Database Password`, and `Database Prefix`. You should enter all of these values similar to what you have in your `wp-config.php` on your old server. **This is a crucial step.** Otherwise, you won't be able to import your old database).
- Then CEM CLI installs a new WP site for you with only `--wp` parameter set. 
- After that it uses `rsync` to copy/sync your WP Site's files from your backup to the EasyEngine site install location i.e. from `sitefolder/backup/homedir/public_html/` to `/var/www/domain.com/htdocs/`.
- Then CEM CLI uses WP CLI to import your old database into the new sites database with `--allow-root` parameter.
- After that you can get an option to search and replace any string in the DB to go through with the migration. This is also powered by WPCLI and uses `--allow-root` parameter for now.
- Once all of this is done your site sits in the `/var/www/domain.com/` folder. In case you want to use WPCLI to do something else, you can cd to `/var/www/domain.com/htdocs/` path.
- If you edit your systems host files `nano /etc/hosts` and append `XX.XX.XX.XX domain.com www.domain.com` at the end, then you can browse your migrated site to check if everything is running fine. (XX.XX.XX.XX is the IP of your server. I found out that if I flush the DNS cache in my mac then I can avoid the delay for the hosts file edits to take effect. You can flush your DNS cache by running this command on your mac `sudo killall -HUP mDNSResponder`).
- `cemcli` removes the backups both extracted and tar files as soon as it can to save as much space as possible.

---

### Step #6: Watch How It's Done

You can either try to guess how it's done with the GIF below or [Watch a 2 min video on YouTube](https://youtu.be/iTnazXPVplE).

![CEM CLI QUICK GIF](https://i.imgur.com/JnRdWHs.gif)

## What Does Future Hold for CEM CLI?

While CEM CLI is no where near an ideal script, it helps me migrate/stage my sites on self-managed VPS. I plan to improve this script by adding several new routines to it. Following is a list of ideas that I have. 

- [x] Download Backup
- [x] Extract Backup
- [x] Migrated site creation
- [x] WP Files sync
- [x] WP DB import
- [x] Search and Replace
- [ ] SSH transfer
- [ ] Site sync via NCFTP
- [ ] Options to chose how to perform backups
- [ ] Better install and uninstall routines
- [ ] Mold it into EasyEngine's CLI instead of just a migration CLI (Thinking Out Loud)

## Disclaimer (Beta Software)
Make sure to test this CLI on a new server. It is beta and completely new. I have tested it to transfer my cPanel sites to an EasyEngine VPS (based on Ubuntu 16.04  x64) while working on a Mac. Use at your own risk 🤔.

## [Changelog](https://github.com/ahmadawais/cPanel-EasyEngine-Migrate-CLI/blob/master/CHANGELOG.md)

### Version 1.1.1 — 2016-10-09
- Migrate Static sites

### Version 1.1.0 — 2016-10-05
- NEW: Sub domain migration.
- NEW: Detailed documentation.
- NEW: Timely memory and space management.
- FIX: Minor fixes.

### Version 1.0.1 to 1.0.9 — 2016-10-04
- NEW: `cemcli` removes the backups both extracted and tar files as soon as it can to save as much space as possible.
- FIX: Several minor fixes and documentation.

### Version 1.0.1 — 2016-10-04
- NEW: `cemcli` removes the backups both extracted and tar files as soon as it can to save as much space as possible.

### Version 1.0.0 — 2016-09-25
- First version
- NEW: Backup download and extraction
- NEW: Migrated site creation
- NEW: WP Files sync
- NEW: WP DB import
- NEW: Search and Replace


---
### 🙌 [WPCOUPLE PARTNERS](https://WPCouple.com/partners):
This open source project is maintained by the help of awesome businesses listed below. What? [Read more about it →](https://WPCouple.com/partners)

<table width='100%'>
	<tr>
		<td width='333.33'><a target='_blank' href='https://www.gravityforms.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mtrE/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://kinsta.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mu5O/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://wpengine.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mto3/c' /></a></td>
	</tr>
	<tr>
		<td width='333.33'><a target='_blank' href='https://www.sitelock.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mtyZ/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://wp-rocket.me/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mtrv/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://blogvault.net/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mtph/c' /></a></td>
	</tr>
	<tr>
		<td width='333.33'><a target='_blank' href='https://cridio.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mtmy/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://wecobble.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mtrW/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://www.cloudways.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mu0C/c' /></a></td>
	</tr>
	<tr>
		<td width='333.33'><a target='_blank' href='https://www.cozmoslabs.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mu9W/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://wpgeodirectory.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mtwv/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://www.wpsecurityauditlog.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mtkh/c' /></a></td>
	</tr>
	<tr>
		<td width='333.33'><a target='_blank' href='https://mythemeshop.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/n3ug/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://www.liquidweb.com/?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mtnt/c' /></a></td>
		<td width='333.33'><a target='_blank' href='https://WPCouple.com/contact?utm_source=WPCouple&utm_medium=Partner'><img src='https://on.ahmda.ws/mu3F/c' /></a></td>
	</tr>
</table>
