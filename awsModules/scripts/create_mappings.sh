#!/bin/bash
set -e

echo "Enter path of variables.tf"
read variable_file_name

echo "Enter path for mappings.json"
read mappings_file_name

variable_list_filename="variables_list.txt"

echo "generate variable list"
cat $variable_file_name | grep "variable" | cut -d " " -f2 > $variable_list_filename

echo "generating mappings.json"
echo "[" > $mappings_file_name
while IFS= read -r line
do
template=$(cat <<-EOF
[ \n
"variableName": $line, \n
"mappingFieldName": "", \n
"isReferenceVariable": false, \n
"isRootModuleEnabled": true \n
], \n
EOF
)
echo -e $template >> $mappings_file_name
done < "$variable_list_filename"
echo "]" >> $mappings_file_name
rm -f $variable_list_filename
