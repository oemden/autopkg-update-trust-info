# autopkg: check and update-trust-info script

This script will Check and Update recipes overrides trust info. 

There's also launchd Agent plist to run it on regular basis.

### `autopkg-update-trust-info.sh` script

Script will get recipes overrides from the com.github.autopkg preferences.

Then check the trust info and update it if needed.

### `com.example.autopkg.update-trust-info.plist` launchd agent

Runs daily at 3 AM. Customize as you wish.

#### TODOs & Notes:

##### `Autopkg run` script

It is an option in the above script but any error is not handled thus this is bad.

For now I use [autopkgr](https://github.com/lindegroup/autopkgr).

I have commented the function and may do to another script just for it if I take time for it. 

- Would be better to quit autopkgr and relaunch it after. 
- Autopkgrun launchd agent
- preventing Autopkgrun errors to stuck the process

--

Find info about launchd agent [here](https://www.launchd.info)
