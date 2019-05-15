#!/bin/sh
set -e

echo "Generating random testsuite for uClibc"
tmp_file=$(mktemp)
if [ "$JOB_TYPE" == "DAILY" ]; then
	COUNT=10
else
	COUNT=1
fi

input_file=${BUILD_DIR}/uclibc-ng-test-*/test/uclibcng-testrunner.in
# Generate a random testsuite file
for i in $(seq 1 ${COUNT})
do
	# Use original file
	shuf ${input_file} >> $tmp_file
done

cp $tmp_file ${TARGET_DIR}/usr/lib/uclibc-ng-test/test/uclibcng-testrunner.in
rm $tmp_file
