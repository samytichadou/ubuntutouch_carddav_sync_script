#!/bin/bash

clear

#read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1

echo "Sync Carddav contacts for Ubuntu Touch Focal"
echo

### Main Menu
options=("Create Synchronization" "Remove Synchronization")
PS3="Select an option : "
# TODO when back here, show options again
select opt in "${options[@]}" "Quit"; do
    case "$REPLY" in
    1) clear
    echo "$opt";;
    2) clear
    echo "$opt";;
    $((${#options[@]}+1))) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one.";continue;;
    esac

while [[ True ]];
do
    ### Create sync
    if [[ $REPLY == 1 ]]; then

        # Get sync infos
        echo
        echo "Get Synchronization informations"
        echo
        read -p "Enter Contacts URL :" CONTACTS_URL
        read -p "Enter Username :" USERNAME
        read -s -p "Enter Password :" PASSWORD
        echo
        read -p "Enter Config Name :" CONTACTS_CONFIG_NAME
        read -p "Enter Contacts Name :" CONTACTS_NAME
        read -p "Enter Contacts Visual Name :" CONTACTS_VISUAL_NAME

        # Get Confirmation
        clear
        echo "Check Synchronization informations :"
        echo
        echo "Contacts URL :"$CONTACTS_URL
        echo "Username :"$USERNAME
        echo "Config Name :"$CONTACTS_CONFIG_NAME
        echo "Contacts Name :"$CONTACTS_NAME
        echo "Contacts Visual Name :"$CONTACTS_VISUAL_NAME
        echo
        read -p "Process ? (Y/N): " confirm && [[ $confirm == [yY] ]] || break

        # Process sync
        clear
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

        # Create system d timer

        break

    ### Remove sync
    elif [[ $REPLY == 2 ]]; then

        # Get sync infos
        echo
        read -p "Name of the Synchronization to remove : " CONTACTS_VISUAL_NAME

        # Confirmation
        clear
        read -p "Remove $CONTACTS_VISUAL_NAME ? (Y/N): " confirm && [[ $confirm == [yY] ]] || break

        # Remove sync
        clear
        echo "Removing Synchronization"
        syncevolution --remove-database backend=evolution-contacts database=$CONTACTS_VISUAL_NAME
        echo
        echo "Removal of $CONTACTS_VISUAL_NAME Synchronization Done"

        # Remove desktop file

        # Remove system d timer

        break

    fi
    done

# echo "cool"
# break
done


