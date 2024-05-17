#!/bin/bash
# This script is a draft combination of the script found at https://gist.github.com/tcarrondo
# It is more or less to remember what I have done to make it work for my Fairphone 2 with UBports ubuntu touch
# Combined by me: Sebastian Gallehr <sebastian@gallehr.de>
# Thanks to: Tiago Carrondo <tcarrondo@ubuntu.com>
# Thanks to: Romain Fluttaz <romain@botux.fr>
# Thanks to: Wayne Ward <info@wayneward.co.uk>
# Thanks to: Mitchell Reese <mitchell@curiouslegends.com.au>
# --------------- [ Server ] ---------------- #
#CAL_URL="https://framagenda.org/remote.php/dav/calendars/samytichadou/personnel/"      # insert the CalDAV URL here
CONTACTS_URL="https://framagenda.org/remote.php/dav/addressbooks/users/samytichadou/contacts/" # insert the CardDAV URL here
USERNAME="samytichadou@gmail.com"                # your CalDAV/CardDAV username
PASSWORD="Ftonton1389A"                # your CalDAV/CardDAV password

# ----------------- [ Phone ] ----------------- #
#CALENDAR_CONFIG_NAME="framagenda"   # I use "myCloud"
CONTACTS_CONFIG_NAME="framagenda"   # I use "myCloud"

#CALENDAR_NAME="addressbook"          # I use "personalcalendar"
#CALENDAR_VISUAL_NAME="framagenda"   # a nice name to show on the Calendar app like "OwnCalendar"

CONTACTS_NAME="contacts"          # I use "personalcontacts"
CONTACTS_VISUAL_NAME="framagenda"   # a nice name to show on the Contacts app like "OwnContacts"

#CRON_FREQUENCY="hourly"               # Sync frequency, I use "hourly"

#export DBUS_SESSION_BUS_ADDRESS=$(ps -u phablet e | grep -Eo 'dbus-daemon.*address=unix:abstract=/tmp/dbus-[A-Za-z0-9]{10}' | tail -c35)

#Create Calendar
### syncevolution --create-database backend=evolution-calendar database=$CALENDAR_VISUAL_NAME
#Create Peer
### syncevolution --configure --template webdav username=$USERNAME password=$PASSWORD syncURL=$CAL_URL keyring=no target-config@$CALENDAR_CONFIG_NAME
#Create New Source
### syncevolution --configure backend=evolution-calendar database=$CALENDAR_VISUAL_NAME @default $CALENDAR_NAME
#Add remote database
### syncevolution --configure database=$CAL_URL backend=caldav target-config@$CALENDAR_CONFIG_NAME $CALENDAR_NAME
#Connect remote calendars with local databases
### syncevolution --configure --template SyncEvolution_Client syncURL=local://@$CALENDAR_CONFIG_NAME $CALENDAR_CONFIG_NAME $CALENDAR_NAME
#Add local database to the source
### syncevolution --configure sync=two-way database=$CALENDAR_VISUAL_NAME $CALENDAR_CONFIG_NAME $CALENDAR_NAME
#Start first sync
### syncevolution --sync refresh-from-remote $CALENDAR_CONFIG_NAME $CALENDAR_NAME

### FIRST SYNC ONLY
#
# #Create contact list
# syncevolution --create-database backend=evolution-contacts database=$CONTACTS_VISUAL_NAME
# #Create Peer
# syncevolution --configure --template webdav username=$USERNAME password=$PASSWORD syncURL=$CONTACTS_URL keyring=no target-config@$CONTACTS_CONFIG_NAME
# #Create New Source
# syncevolution --configure backend=evolution-contacts database=$CONTACTS_VISUAL_NAME @default $CONTACTS_NAME
# #Add remote database
# syncevolution --configure database=$CONTACTS_URL backend=carddav target-config@$CONTACTS_CONFIG_NAME $CONTACTS_NAME
# #Connect remote contact list with local databases
# syncevolution --configure --template SyncEvolution_Client Sync=None syncURL=local://@$CONTACTS_CONFIG_NAME $CONTACTS_CONFIG_NAME $CONTACTS_NAME
# #Add local database to the source
# syncevolution --configure sync=two-way backend=evolution-contacts database=$CONTACTS_VISUAL_NAME $CONTACTS_CONFIG_NAME $CONTACTS_NAME

#First sync
syncevolution --sync refresh-from-remote $CONTACTS_CONFIG_NAME $CONTACTS_NAME

#Normal sync
#syncevolution --sync two-way $CONTACTS_CONFIG_NAME $CONTACTS_NAME

# #Add Sync Cron job
# sudo mount / -o remount,rw
# COMMAND_LINE="export DISPLAY=:0.0 && export DBUS_SESSION_BUS_ADDRESS=$(ps -u phablet e | grep -Eo 'dbus-daemon.*address=unix:abstract=/tmp/dbus-[A-Za-z0-9]{10}' | tail -c35) && /usr/bin/syncevolution $CONTACTS_NAME"
# ### COMMAND_LINE="export DISPLAY=:0.0 && export DBUS_SESSION_BUS_ADDRESS=$(ps -u phablet e | grep -Eo 'dbus-daemon.*address=unix:abstract=/tmp/dbus-[A-Za-z0-9]{10}' | tail -c35) && /usr/bin/syncevolution $CALENDAR_NAME && /usr/bin/syncevolution $CONTACTS_NAME"
# sudo sh -c "echo '$COMMAND_LINE' > /sbin/sogosync"
# sudo chmod +x /sbin/sogosync
#
# CRON_LINE="@$CRON_FREQUENCY /sbin/sogosync"
# (crontab -u phablet -r;) # only if no other cron jobs already exist in crontab
# (crontab -u phablet -l; echo "$CRON_LINE" ) | crontab -u phablet -
# sudo mount / -o remount,ro
# sudo service cron restart
