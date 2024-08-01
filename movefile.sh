#!/bin/bash

source_dir="/home/dileep/Downloads"
target_dir="/opt/tomcat/webapps/"
TOMCAT_HOME="/opt/tomcat"

function filePermissions() {
	echo "################### File Permissions Done ###################"

	find /opt/tomcat/ -type d -exec chmod 777 {} \;

	rm -rf "$TOMCAT_HOME/work/Catalina/localhost/"*
	
	rm -rf "$TOMCAT_HOME/logs/"*
	
	rm -rf "$TOMCAT_HOME/temp/"*

	echo "Cleared work, logs, and temp directories"
}

function showFilesInTargetDirectory() {
	echo "################### File Available In Target-Directory Done ###################"
	cd "$target_dir" || exit
	ls
}

function stopTomcat() {
	cd "$TOMCAT_HOME/bin" || exit
	./shutdown.sh
	echo "################### Tomcat server stopped. ###################"
}

function moveFile() {
	MONTH="$(date +'%d''%b''%Y')"
	local removed_files_dir="$TOMCAT_HOME/removed/$MONTH"

	mkdir -p "$removed_files_dir"

	for source_file in "$source_dir"/*.{war,zip}; do
		if [ -f "$source_file" ]; then
			file_name=$(basename "$source_file")
			particular_file="${file_name%.*}"

			# Source file is a zip
			if [[ "$source_file" == *.zip ]]; then
			
				# Move existing folder to removed_files_dir if it exists
				if [ -d "$target_dir/$particular_file" ]; then
					mv "$target_dir/$particular_file" "$removed_files_dir"
					echo "********** Existing folder $target_dir/$particular_file moved to $removed_files_dir. *************"
				fi

					# Move existing zip file to removed_files_dir if it exists
					if [ -f "$target_dir/$file_name" ]; then
						mv "$target_dir/$file_name" "$removed_files_dir"
						echo "********* Existing zip file $target_dir/$file_name moved to $removed_files_dir. **********"
					fi

				# Copy the zip file to target_dir
				cp "$source_file" "$target_dir"
				echo "************* Zip file copied to $target_dir ********************"

				# Extract the zip file in target_dir
				unzip -o "$target_dir/$file_name" -d "$target_dir"
				echo "************* File extracted to $target_dir ****************"

		                # Move the zip file to removed_files_dir
				mv "$target_dir/$file_name" "$removed_files_dir"
				echo "************** Zip file $target_dir/$file_name moved to $removed_files_dir. ***************"

			else
				# If it's not a zip file
				if [ -f "$target_dir/$file_name" ]; then
					mv "$target_dir/$file_name" "$removed_files_dir"
					echo "*************** Existing file moved from $target_dir to $removed_files_dir. ******************"
				fi

				# Move existing folder to removed_files_dir if it exists
				if [ -d "$target_dir/$particular_file" ]; then
					mv "$target_dir/$particular_file" "$removed_files_dir"
					echo "************** Existing folder $target_dir/$particular_file moved to $removed_files_dir. *****************"
				fi

				# Copy the source file to target_dir
				cp "$source_file" "$target_dir"
				echo "***************** File moved to $target_dir ***************"
			fi
		else
			echo "***************** No files with .war or .zip extension in the source directory. **********************"
		fi
	done
}

function startTomcat() {
	cd "$TOMCAT_HOME/bin" || exit
	./startup.sh
	echo "################### Tomcat server started. ###################"
}

stopTomcat

sleep 10
filePermissions

sleep 10
moveFile

sleep 10
showFilesInTargetDirectory

sleep 30
startTomcat

sleep 5
showFilesInTargetDirectory

