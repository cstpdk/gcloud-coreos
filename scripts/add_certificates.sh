config_file="$1"
pem_files="${@:2}"
for pem in $pem_files ; do
	echo -e "  - path: /home/core/keys/$(basename $pem)" >> $config_file
	echo -e "    content: |\n" >> $config_file
	cat $pem >> $config_file
done
