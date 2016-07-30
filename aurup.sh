#!/bin/bash
#
## For loop looks in every directory within the aur directory.
for AurPkg in ~/doc/aur/* ; do
	#unset GitPull
	#unset GitStat
	pushd "$AurPkg" >/dev/null 2<&1
	
	# Work only with git repos
	if [ ! -d .git ]; then
		popd
		continue
	fi

	# Remove src directories and clean any previously created files
	#if [ -d src ] ; then
	#	rm -rf src
	#fi
	#git clean -df >/dev/null 2<&1

	# AurName is the name of the directory
	AurName="$(echo "$AurPkg" | awk -F \/ '{ print $NF }')"
	# Arbitrary spacing character
	SpaceChar=".:."

	GitStat="Null."
	# Do a git pull and store the output in GitPull
	#GitPull=$(git pull)
	# Check if GitPull was up to date or if it pulled something.
	#if [[ $GitPull == "Already up-to-date." ]]; then
	#	GitStat=$GitPull
	#else
	#	GitStat="Updated."
	#fi
	# Print the results
	printf "%30s %s %s\n" "$AurName" "$SpaceChar" "$GitStat"
	popd >/dev/null 2<&1
done
