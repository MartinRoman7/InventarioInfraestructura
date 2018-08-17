#!/bin/bash

############################# Main variables #############################
BASE_DIR=/Users/ctin/Desktop/Ansible_pruebas
########################## End Main variables ############################

while getopts ":b:" opt; do
case "${opt}" in

	b)
        BASE_DIR="${OPTARG}"
    ;;

    *)
        echo "Usage: ${0} [options]"
        echo "Options:"
        echo " -b"
        echo "	Specify the directory path"
        exit 1
    ;;
esac
done
shift $((OPTIND-1))

BASE_DIR_FACTS=${BASE_DIR}/Facts
BASE_DIR_OUTPUTS=${BASE_DIR}/CustomFacts
BASE_DIR_FACTS_POST=${BASE_DIR}/Facts_output

rm ${BASE_DIR}/.DS_Store
rm ${BASE_DIR_FACTS}/.DS_Store

#############################################################################
#	Copy the content of Facts directory to another because we need to		# 
#	modificate the files and we prefer use another directory to save the	#
#	original directory.														#
#############################################################################

mkdir ${BASE_DIR_FACTS_POST}

cd ${BASE_DIR_FACTS}
for i in $( ls ); do
	cp -r ${i} ${BASE_DIR_FACTS_POST}
done

#############################################################################
#	In the new directory we modify the content of the files using sed. 		#
#############################################################################

cd ${BASE_DIR_FACTS_POST}
for i in $( ls ); do
    sed -i '' -e 's/{//' /${BASE_DIR_FACTS_POST}/${i}/*
	sed -i '' -e 's/.$//' /${BASE_DIR_FACTS_POST}/${i}/*
	sed -i '' -e 's/$/,/' /${BASE_DIR_FACTS_POST}/${i}/*
done

#############################################################################
#	We create a new directory where the new otuputs will stay there			#
#	Using the values of files.txt and directiry.txt files we join the 		#
#	content of each file that have the same name in diferent directories.	#
#############################################################################

mkdir ${BASE_DIR_OUTPUTS}
cd ${BASE_DIR_FACTS}
for i in $( ls -t | head -1 ); do
    for k in $( ls ${BASE_DIR_FACTS}/${i} ); do
        for j in $( ls ); do
            cat ${BASE_DIR_FACTS_POST}/${j}/${k} >> ${BASE_DIR_OUTPUTS}/${k}
        done
    done
done

#############################################################################
#	Remove line breaks in the files											#
#	Remove the last character (,)											#
#	Put the name of the key (custom_facts)									#
#	Close the file with double (})											#	
#############################################################################

for i in $( ls ${BASE_DIR_OUTPUTS} ); do
    tr -d '\n' < ${BASE_DIR_OUTPUTS}/${i} > ${BASE_DIR_OUTPUTS}/clear_${i}
    mv ${BASE_DIR_OUTPUTS}/clear_${i} ${BASE_DIR_OUTPUTS}/${i}
done

for i in $( ls ${BASE_DIR_OUTPUTS} ); do
    sed -e 's/.$//' ${BASE_DIR_OUTPUTS}/${i} > ${BASE_DIR_OUTPUTS}/clear_${i}
    mv ${BASE_DIR_OUTPUTS}/clear_${i} ${BASE_DIR_OUTPUTS}/${i}
done

for i in $( ls ${BASE_DIR_OUTPUTS} ); do
    sed -e 's/^/{"custom_facts":{/' ${BASE_DIR_OUTPUTS}/${i} > ${BASE_DIR_OUTPUTS}/json_${i}
    mv ${BASE_DIR_OUTPUTS}/json_${i} ${BASE_DIR_OUTPUTS}/${i}
done

for i in $( ls ${BASE_DIR_OUTPUTS} ); do
    sed -e 's/$/}}/' ${BASE_DIR_OUTPUTS}/${i} > ${BASE_DIR_OUTPUTS}/json_${i}
    mv ${BASE_DIR_OUTPUTS}/json_${i} ${BASE_DIR_OUTPUTS}/${i}
done

mkdir ${BASE_DIR}/Final_facts
cp -r ${BASE_DIR}/AnsibleFacts ${BASE_DIR}/Final_facts/
cp -r ${BASE_DIR_OUTPUTS} ${BASE_DIR}/Final_facts/
rm -r ${BASE_DIR_FACTS_POST}
rm -r ${BASE_DIR}/AnsibleFacts
rm -r ${BASE_DIR}/Facts
rm -r ${BASE_DIR_OUTPUTS}

echo "==== JSON Completed ===="