# dev-tools-config
A backup solution for my development configuration that is easy to install in a new environment.

### How to use?
I recommend forking this repo and using it to keep your own settings in sync.

* To get sym links for supported applications: run ./setup.ps1 as administrator
* To get other configs: use backed up settings files to seed settings into your cloud account

### How to add new settings?
Add a line to the links.config file to have the setup.ps1 create a sym link for your new application.

### Supported configs
* rider: settings backed up, sync'ed in cloud
* vscode: settings backed up, sync'ed in cloud
* outlook: settings backed up, no sync
* git: settings sync'ed in repo via symlink
* ahk: settings sync'ed in repo via symlink
* cmder: settings sync'ed in repo via symlink
