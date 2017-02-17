#!/bin/bash
#
# aurup
# Simple updater for the Arch Users Repository (AUR)
# https://aur.archlinux.org
# Note: This probably won't work right on your machine unmodified.
# It is just my personal project.
#
source $HOME/.auruprc

echo "Authorise Sudo:"
sudo echo "Thanks."

# Error in case that files doesn't exist.
if [[ -z $aurDir ]]; then
	echo "Create an ~/.auruprc file with"
	echo 'aurDir="/path/to/your/aur/directory"'
	echo "No trailing slash."
	exit
fi

## For loop looks in every directory within the aur directory.
for aurPkg in $aurDir/* ; do
	# Exclude files in the aur directory.
	if [[ ! -d $aurPkg ]]; then
		continue
	# Exclude directories that are not git repos.
	elif [[ ! -d $aurPkg/.git ]]; then
		continue
	fi
	
	# Enter the directory.
	pushd "$aurPkg" >/dev/null 2<&1
	
	# Extract the last bit of the path to get just the project name.
	aurName="$(echo "$aurPkg" | awk -F \/ '{ print $NF }')"

	# Output for whoever is watching.
	echo -ne "Working on $aurName\033[0K\r"

	# Update from remote
	git remote update >/dev/null 2<&1
	# Compare local and remote
	gitLocal=$(git rev-parse @)
	gitRemote=$(git rev-parse @{u})
	# If an update is not needed, continue. 
	# Otherwise, add the name to the list of repos that need an update.
	if [ $gitLocal = $gitRemote ] ; then
		continue
	else
		if [[ -z "$gitUpdate" ]]; then
			aurPath=($aurPkg)
			gitUpdate=($aurName)
			gitCount=1
		else
			aurPath+=($aurPkg)
			gitUpdate+=($aurName)
			gitCount=$[gitCount+1]
		fi
	fi
	popd >/dev/null 2<&1
done

# Check if there are any packages that need to be updated.
if [[ $gitCount ]]; then
	# Display packages requiring updates and then check if Pacman is running.
	echo "==> Found $gitCount Package Update(s)"
	echo "${gitUpdate[@]}"

	# If Pacman is already running, display number of updates required and exit
	if [[ -e /var/lib/pacman/db.lck ]]; then
		echo "ERROR: Pacman is currently running!"
		echo "Re-run Aurup once Pacman has completed."
		exit
	else
	# If Pacman isn't running, display packages to update and proceed to the update process
		echo "==> Upgrading $gitCount Package(s)"
		echo "${gitUpdate[@]}"
	fi
# If no packages need updating, display message and exit.
else
	echo "==> All AUR packages up-to-date!"
	exit
fi

for aurUpdating in ${aurPath[@]}; do
	# Enter directory
	pushd "$aurUpdating" >/dev/null 2<&1

	# Clean any previous build files
	if [[ -d src ]]; then
		rm -rf src >/dev/null 2<&1
	fi
	git clean -df >/dev/null 2<&1
	git pull >/dev/null 2<&1
	
	echo "Authorise Sudo:"
	sudo echo "Thanks."
	makepkg -si --noconfirm	
	
	if [[ -e .aurconfig ]] ; then
		sh .aurconfig
	fi
	popd >/dev/null 2<&1
done
