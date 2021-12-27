#!/bin/bash
/usr/bin/clear 2>/dev/null
##
## oem at oemden dot com
##
## ----------------------------------------------------------------------------------
## Update Repos and Update Local Overrides trust-infos then run Recipes.
## ----------------------------------------------------------------------------------
##
version="0.7" #

##########################################################################################
if [ "$3" == "/" ]; then
    TARGET=""
else
    TARGET="$3"
fi
##########################################################################################

#################### Commands ############################################################
cmd_PlistBuddy="${TARGET}/usr/libexec/PlistBuddy"
cmd_defaults="${TARGET}/usr/bin/defaults"
cmd_autopkg="${TARGET}/usr/local/bin/autopkg"
cmd_echo="${TARGET}/bin/echo"

autopkgupdatetrustinfolog="/Library/Logs/munkijungle/autopkg/autopkg-update-trust-info.log"
#################### variables ###########################################################
RecipeOverridesDir=$( "${cmd_defaults}" read com.github.autopkg RECIPE_OVERRIDE_DIRS )
RecipeReposDir=$( "${cmd_defaults}" read com.github.autopkg RECIPE_REPO_DIR )

#################### functions ###########################################################
function log_it() {
	if [[ ! "${autopkgupdatetrustinfolog}" ]] ; then
		touch "${autopkgupdatetrustinfolog}"
	fi
  	"${cmd_echo}" "${1}" >> "${autopkgupdatetrustinfolog}"
  	"${cmd_echo}" "${1}"
}

function CmdPlistBuddyCheckString() {
	## $1 recipe file
	## $2 Key Name
	"${cmd_PlistBuddy}" -c "print ${2}" "${1}"  2>/dev/null
}

function get_recipes_overrides {
	cd "${RecipeOverridesDir}"
	overrides=(*)
	for override in "${overrides[@]}" ; do
		if [[ "${override}" =~ ".recipe" ]] ; then
			local_override=$( CmdPlistBuddyCheckString "${override}" "Identifier" )
			#echo "local override: $local_override"
			local_overrides+=( "$local_override" )
		fi
	done
}

function check_trust_info() {
	#get_recipes_overrides
  	log_it " Verifying trust info for local recipes overrides"
		for myrecipe in "${local_overrides[@]}" ; do
		 echo " Verifying trust info for ${myrecipe}"
		 check_trust_info=$( "${cmd_autopkg}" verify-trust-info "${myrecipe}" | awk '{print $2}' )
		 if [[ "${check_trust_info}" != "OK" ]] ; then
		  	echo " Updating trust info for ${myrecipe}"
  			 "${cmd_autopkg}" update-trust-info "${myrecipe}"
  			 log_it " Updating trust info for ${myrecipe}"
		 fi
		done
}

function repos_updates() {
  	log_it " Updating recipes repos"
	#reciperepos=( $( ${cmd_defaults} read com.github.autopkg RECIPE_REPOS | grep 'URL' | awk '{print $3}' | sed 's/"//g' | sed 's/;//g' ) )
	reciperepos=( $( "${cmd_autopkg}" repo-list | awk '{print $2}' | sed 's/(//g;s/)//g' ) )
	for myrepo in "${reciperepos[@]}" ; do
		#echo "${myrepo}"
		"${cmd_autopkg}" repo-update "${myrepo}"
	done
}

function run_local_overrides() {
	#get_recipes_overrides
  	log_it " Running local recipes overrides"
		for my_local_override in "${local_overrides[@]}" ; do
			echo " running ${my_local_override}"
		 	"${cmd_autopkg}" run "${my_local_override}" ; echo
		done

		#rebuild catalog
		"${cmd_autopkg}" run com.github.autopkg.munki.makecatalogs
}

function do_it {
	log_it ""
	log_it "$(date '+%Y.%m.%d %H:%M:%S') - autopkg routine "
	repos_updates # update Master repos
	get_recipes_overrides # find local overrides
	check_trust_info # check local overrides trust info
	run_local_overrides # run overrides
}

#################### DO IT ###############################################################
do_it


exit 0

#################### TODOS  ##############################################################
## create log dir and touch log file first - determine if in user or computer library..

