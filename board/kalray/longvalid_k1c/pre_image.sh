#!/bin/sh
set -ex

echo "Generating random testsuite for uClibc"
tmp_file=$(mktemp)
check_file=$(mktemp)
if [ "$JOB_TYPE" == "WEEKLY" ]; then
	COUNT=50
elif [ "$JOB_TYPE" == "DAILY" ]; then
	COUNT=10
else
	COUNT=1
fi

script_path=${BR2_EXTERNAL_K1C_PATH}/board/kalray/longvalid_k1c
input_file=${script_path}/uclibcng-testrunner.in
ref_file=${BUILD_DIR}/uclibc-ng-test-*/test/uclibcng-testrunner.in

# First, sort the reference file
sort -t" " ${ref_file} > ${check_file}
cut -d " " -f 2- ${input_file} | sort -t" " | diff - ${check_file}

rm ${check_file}

# Generate a random testsuite file
for i in $(seq 1 ${COUNT})
do
	# Use original file
	shuf ${input_file} >> $tmp_file
done

output_path=${TARGET_DIR}/usr/lib/uclibc-ng-test/test
cp $tmp_file ${output_path}/uclibcng-testrunner.in
cp ${script_path}/uclibcng-testrunner.sh ${output_path}/uclibcng-testrunner.sh
rm $tmp_file
