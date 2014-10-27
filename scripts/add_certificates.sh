config_file="$1"
pem_files="${@:2}"
echo "" > $config_file
for pem in $pem_files ; do
	echo -e "  - path: /home/core/keys/$(basename $pem)" >> $config_file
	echo -e "    content: |\n" >> $config_file
	echo $pem
	cat $pem
	cat $pem >> $config_file
done
