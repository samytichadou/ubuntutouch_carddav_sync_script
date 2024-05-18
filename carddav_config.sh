#!/bin/bash

# Auto setup of carddav contacts

# samytichadou@gmail.com
#
# Created by Samy Tichadou (tonton)
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Based on a script by Sebastian Gallehr <sebastian@gallehr.de>
# Thanks to: Sebastian Gallehr <sebastian@gallehr.de>
# Thanks to: Tiago Carrondo <tcarrondo@ubuntu.com>
# Thanks to: Romain Fluttaz <romain@botux.fr>
# Thanks to: Wayne Ward <info@wayneward.co.uk>
# Thanks to: Mitchell Reese <mitchell@curiouslegends.com.au>

### Menu
while [[ True ]];
do
clear
echo "Sync Carddav contacts for Ubuntu Touch Focal"
echo
echo "1 - Create Synchronization"
echo "2 - Remove Synchronization"
echo "3 - Quit"
read -p "Select (1-2-3) : " REPLY

while [[ True ]];
do
    ### Create sync
    if [[ $REPLY == 1 ]]; then

        # Get sync infos
        clear
        echo "Create Synchronization"
        echo
        echo "Get Synchronization informations"
        echo
        read -p "Enter Contacts URL : " CONTACTS_URL
        read -p "Enter Username : " USERNAME
        read -s -p "Enter Password : " PASSWORD
        echo
        read -p "Enter Config Name : " CONTACTS_CONFIG_NAME
        read -p "Enter Contacts Name : " CONTACTS_NAME
        read -p "Enter Contacts Visual Name : " CONTACTS_VISUAL_NAME
        echo
        read -p "Create Manual Sync Icon ? (Y/N) " DESKTOPFILE
        read -p "Create Automatic Systemd Sync ? (Y/N) " SYSTEMD
        while :
        do
        if [[ $SYSTEMD == [yY] ]]; then
            read -p "Automatic Systemd Sync Frequency (1-WEEKLY, 2-DAILY, 3-PRECISE) : " SYSTEMDFREQTYPE
            if [[ $SYSTEMDFREQTYPE != [123] ]]; then
                echo "Invalid Entry"
                continue
            fi
            if [[ $SYSTEMDFREQTYPE == 1 ]]; then
                read -p "Day for the Sync Process to start (Mon, Tue, Wed, Thu, Fri, Sat, Sun) : " SYSTEMDFREQDAY
                #if [[ ${array[@]} =~ $element ]]
                DAYS=("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")
                if ! [[ ${DAYS[@]} =~ $SYSTEMDFREQDAY ]]; then
                    echo "Invalid Entry"
                        continue
                fi
            fi
            if [[ $SYSTEMDFREQTYPE == 3 ]]; then
                read -p "Sync Frequency in Hours (0-999) : " SYSTEMDFREQHOUR
                if ! echo $SYSTEMDFREQHOUR | egrep -q '^[0-9]+$'; then
                    echo "Invalid Entry"
                    continue
                fi
                if ! (($SYSTEMDFREQHOUR >= 0 && $SYSTEMDFREQHOUR <= 999)); then
                    echo "Invalid Entry"
                    continue
                fi
            else
                read -p "Hour for the Sync Process to start (0-23): " SYSTEMDFREQHOUR
                if ! echo $SYSTEMDFREQHOUR | egrep -q '^[0-9]+$'; then
                    echo "Invalid Entry"
                    continue
                fi
                if ! (($SYSTEMDFREQHOUR >= 0 && $SYSTEMDFREQHOUR <= 23)); then
                    echo "Invalid Entry"
                    continue
                fi
            fi
        fi
        break
        done
        echo
        read -p "Process ? (Y/N) : " confirm && [[ $confirm == [yY] ]] || break

        # Process sync
        clear
        echo "Create Synchronization"
        echo
        echo "Creating Synchronization"
        echo
        #Create contact list
        syncevolution --create-database backend=evolution-contacts database=$CONTACTS_VISUAL_NAME
        #Create Peer
        syncevolution --configure --template webdav username=$USERNAME password=$PASSWORD syncURL=$CONTACTS_URL keyring=no target-config@$CONTACTS_CONFIG_NAME
        #Create New Source
        syncevolution --configure backend=evolution-contacts database=$CONTACTS_VISUAL_NAME @default $CONTACTS_NAME
        #Add remote database
        syncevolution --configure database=$CONTACTS_URL backend=carddav target-config@$CONTACTS_CONFIG_NAME $CONTACTS_NAME
        #Connect remote contact list with local databases
        syncevolution --configure --template SyncEvolution_Client Sync=None syncURL=local://@$CONTACTS_CONFIG_NAME $CONTACTS_CONFIG_NAME $CONTACTS_NAME
        #Add local database to the source
        syncevolution --configure sync=two-way backend=evolution-contacts database=$CONTACTS_VISUAL_NAME $CONTACTS_CONFIG_NAME $CONTACTS_NAME
        #First sync
        syncevolution --sync refresh-from-remote $CONTACTS_CONFIG_NAME $CONTACTS_NAME
        echo
        echo "Synchronization of $CONTACTS_VISUAL_NAME Created"

        # Create desktop file
        if [[ $DESKTOPFILE == [yY] ]]; then
            echo
            echo "Creating Desktop File"
            filename="sync.$CONTACTS_VISUAL_NAME.tonton"
            file=/home/phablet/$filename.txt
            echo "[Desktop Entry]" > $file
            echo "Type=Application" >> $file
            echo "Name=Sync $CONTACTS_VISUAL_NAME" >> $file
            echo "Exec=syncevolution --sync two-way $CONTACTS_CONFIG_NAME" >> $file
            echo "Terminal=false" >> $file
            echo "Icon=/usr/share/icons/suru/status/scalable/syncing.svg" >> $file
            mv $file /home/phablet/.local/share/applications/$filename.desktop
            echo "Desktop File Created"
        fi

        # Create system d timer
        if [[ $SYSTEMD == [yY] ]]; then
            echo
            echo "Creating Sync Timer"
            filename="sync_carddav_$CONTACTS_VISUAL_NAME"
            file=/home/phablet/$filename.txt

            # Service file
            echo "[Unit]" > $file
            echo "Description=sync carddav $CONTACTS_CONFIG_NAME" >> $file
            echo "[Service]" >> $file
            echo "Type=oneshot" >> $file
            echo "ExecStart=syncevolution --sync two-way $CONTACTS_CONFIG_NAME" >> $file
            echo "[Install]" >> $file
            echo "WantedBy=default.target" >> $file
            mv $file .config/systemd/user/$filename.service

            # Timer file
            echo "[Unit]" > $file
            echo "Description=sync carddav $CONTACTS_CONFIG_NAME" >> $file
            echo "[Timer]" >> $file
            echo "OnStartupSec=0min" >> $file
            if [[ $SYSTEMDFREQTYPE == 3 ]]; then
                echo "OnUnitActiveSec=${SYSTEMDFREQHOUR}h" >> $file
            elif [[ $SYSTEMDFREQTYPE == 1 ]]; then
                echo "OnCalendar=${SYSTEMDFREQDAY} *-*-* ${SYSTEMDFREQHOUR}:00:00" >> $file
            elif [[ $SYSTEMDFREQTYPE == 2 ]]; then
                echo "OnCalendar=*-*-* ${SYSTEMDFREQHOUR}:00:00" >> $file
            fi
            echo "Persistent=true" >> $file
            echo "[Install]" >> $file
            echo "WantedBy=timers.target" >> $file
            mv $file .config/systemd/user/$filename.timer

            echo "Systemd Timer Files Created"
            echo "Starting Systemd Services"
            systemctl --user daemon-reload
            systemctl --user start $filename.service
            systemctl --user start $filename.timer
            echo "Systemd Services Started"
        fi

        echo
        echo "Synchronization Set"
        echo
        read -n 1 -s -r -p "Press any key to continue"

        break

    ### Remove sync
    elif [[ $REPLY == 2 ]]; then

        # Get sync infos
        clear
        echo "Remove Synchronization"
        echo
        read -p "Name of the Synchronization to remove : " CONTACTS_VISUAL_NAME
        echo
        read -p "Process ? (Y/N) : " confirm && [[ $confirm == [yY] ]] || break

        # Remove sync
        clear
        echo "Remove Synchronization"
        echo
        echo "Removing Synchronization"
        syncevolution --remove-database backend=evolution-contacts database=$CONTACTS_VISUAL_NAME
        echo
        echo "$CONTACTS_VISUAL_NAME Synchronization Removed"

        # Remove desktop file
        echo
        echo "Removing Desktop File"
        file=/home/phablet/.local/share/applications/sync.$CONTACTS_VISUAL_NAME.tonton.desktop
        rm $file
        echo "Desktop File Removed"

        # Remove system d timer
        echo
        echo "Removing Sync Timer"
        echo "Stopping Systemd Services"
        filename="sync_carddav_$CONTACTS_VISUAL_NAME"
        systemctl --user stop $filename.timer
        systemctl --user stop $filename.service
        echo "Systemd Services Stopped"
        echo "Removing Systemd Timer Files"
        rm .config/systemd/user/$filename.service
        rm .config/systemd/user/$filename.timer
        echo "Systemd Timer Files Removed"
        echo "Reloading Systemd Services"
        systemctl --user daemon-reload

        echo
        echo "Synchronization Removed"
        echo
        read -n 1 -s -r -p "Press any key to continue"

        break

    ### Quit
    elif [[ $REPLY == 3 ]]; then
        clear
        exit

    ### Invalid entry
    else
        break

    fi
    done

# echo "cool"
# break
done


