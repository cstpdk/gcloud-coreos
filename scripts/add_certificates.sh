config_file="$1"
pem_files="${@:2}"
for pem in $pem_files ; do
	echo -e "  - path: /home/core/keys/$(basename $pem)" >> $config_file
	echo -e "    content: |" >> $config_file
	while read line ; do # Indentation is required. I hate yaml
		echo "      ${line}" >> $config_file
	done < $pem
done
