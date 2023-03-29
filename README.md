# dev-tools-config
A backup solution for my development configuration that is easy to install in a new environment.

### how to use?
I recommend forking this repo and using it to keep your own settings in sync.

to get sym links for supported applications: run ./setup.ps1 as administrator
to get other configs: use backed up settings files to seed settings into your cloud account

### how to add new settings?
add a line to the links.config file to have the setup.ps1 create a sym link for your new application.

### supported configs
rider: settings backed up, sync'ed in cloud
vscode: settings backed up, sync'ed in cloud
outlook: settings backed up, no sync
git: settings sync'ed in repo
ahk: settings sync'ed in repo
cmder: settings sync'ed in repo