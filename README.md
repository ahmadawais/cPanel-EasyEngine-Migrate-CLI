# cPanel-EasyEngine-Migrate-CLI
cPanel to EasyEninge Migrate CLI is a bash script built to help people migrate their sites from a cPanel to an rented VPS with EasyEninge installed on it.

## Pre-requisite
You need to rent a VPS with EasyEninge installed on it. Here's the list.

- Rent a VPS preferably with <kbd>Ubuntu 16.04 x64 OS</kbd> (I recommend Vultr.com | During summer, by using my affiliate link you [get $20 Signup Bonus](http://www.vultr.com/?ref=6942485-3B) or if you prefer [non-affiliate link](http://www.vultr.com/))
- Install [EasyEninge](https://easyengine.io/) just run this command after logging into your VPS with SSH `wget -qO ee rt.cx/ee && sudo bash ee`

## Using Migrate CLI
After you have completed the pre-requisite steps, all you need to do is download and run the cPanel-EasyEngine-Migrate-CLI. You can do that by running the following commands.

Download `cPanel-EasyEngine-Migrate-CLI`

```bash
sudo wget -qO cem https://git.io/vixvj && sudo chmod +x ./cem && sudo sudo install ./cem /usr/local/bin/cem
```

Run `cPanel-EasyEngine-Migrate-CLI`

```bash
cem
```

To Uninstall `cPanel-EasyEngine-Migrate-CLI`

```bash
rm /usr/local/bin/cem
```

Running this CLI will output several questions on your terminal, each question comes with an example value enclose with square brackets `[]` just fill up the answers and you'll be able to automate bits of the complete migration process.

## Disclaimer (Beta Software)
Make sure to test this CLI on new server. It is beta and completely new. I have tested it to transfer my cPanel sites to an EasyEninge VPS (based on Ubuntu 16.04  x64) while working on a Mac. Use at your own risk 🤔.

## Changelog

### Version 1.0.0 — 2016-09-25
- First version
- NEW: Backup download and extraction
- NEW: Migrated site creation
- NEW: WP Files sync
- NEW: WP DB import
- NEW: Search and Replace

