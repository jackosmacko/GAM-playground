# Takes an email as argument e.g johnny.cage@example.com.
# Removes domain read permissions (ie "Share with anyone from example.com") from all shared files / folders owned by user.


# Catch empty argument
if [ -z $1 ];
then
	echo "You need to provide a users email (e.g johnny.cage@example.com)."
	exit 1
fi


// Default install location of GAM. Change as needed.
gam=~/bin/gam/gam


# Gets a list of shared files owned by the user, then outputs the list into a file to be processed.
# Translate the spaces between file ID's to newlines and save the list of file outputs to filelist_email.txt.
list=$($gam user $1 show filelist id shared | grep True | cut -d, -f2)
echo $list | tr " " "\n" > sharelist_$1.txt

# Loop through the newly created list. Use internal field seperator to separate file ID's by newline.
while IFS= read -r line; do
	
	# Match the permission ID for domain read.
	permid=$($gam user $1 show drivefileacl $line | grep -B 2 "type: domain" | head -1)
	
	# If domain sharing wasn't present.
	if [ -z $permid ]; 
		then echo "No changes made to: "$line  
	else 
	# Remove the domain read permission. 
			$gam user $1 delete drivefileacl $line id:$permid;
	fi
	# Take a short break to avoid hitting G Suite API quotas. 
	sleep 0.1
done < sharelist_$1.txt
