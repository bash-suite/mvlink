#!/bin/bash
DIR="$(cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"

# remove all tests
rm -rf "$DIR/.tmp"
mkdir -p "$DIR/.tmp" && cd "$DIR/.tmp" || exit
ln -s "$DIR/mvlink.sh" mvlink
chmod +x mvlink

# helper functions
assert_link() {
    if [ ! -L "$1" ]; then echo "ERROR ${2:-}: $1 is not a symbolic link"; exit 2; fi
}
assert_folder() {
    if [ ! -d "$1" ]; then echo "ERROR ${2:-}: $1 is not a folder"; exit 3; fi
}
assert_file() {
    if [ ! -f "$1" ]; then echo "ERROR ${2:-}: $1 is not a file"; exit 4; fi
}
valid() {
    if [ "$1" -eq 0 ]; then echo "$2: OK"; else echo "$2: ERROR $1"; fi
}

# DEBUG mode
export DEBUG=1

#
# Test 1:
#
#   ORIGIN: folder1 without files at creation
#   DEST: 
#
TEST=test1
mkdir -p $TEST/folder1
./mvlink $TEST/folder1 $TEST/folder2
assert_link $TEST/folder1 $TEST
assert_folder $TEST/folder2 $TEST
touch $TEST/folder1/file1
assert_file $TEST/folder1/file1 $TEST
assert_file $TEST/folder2/file1 $TEST
touch $TEST/folder2/file2
assert_file $TEST/folder1/file2 $TEST
assert_file $TEST/folder2/file2 $TEST
valid $? $TEST

#
# Test 2:
#
#   ORIGIN: folder1 with files
#   DEST: 
#
TEST=test2
mkdir -p $TEST/folder1
touch $TEST/folder1/file1
./mvlink $TEST/folder1 $TEST/folder2
assert_link $TEST/folder1 $TEST
assert_folder $TEST/folder2 $TEST
touch $TEST/folder2/file2
assert_file $TEST/folder1/file1 $TEST
assert_file $TEST/folder1/file2 $TEST
assert_file $TEST/folder2/file1 $TEST
assert_file $TEST/folder2/file2 $TEST
valid $? $TEST

#
# Test 3:
#
#   ORIGIN: folder1 without files
#   DEST: folder2 without files
#
TEST=test3
mkdir -p $TEST/folder1
mkdir -p $TEST/folder2
./mvlink $TEST/folder1 $TEST/folder2
assert_link $TEST/folder1 $TEST
assert_folder $TEST/folder2 $TEST
touch $TEST/folder1/file1
assert_file $TEST/folder1/file1 $TEST
assert_file $TEST/folder2/file1 $TEST
touch $TEST/folder2/file2
assert_file $TEST/folder1/file2 $TEST
assert_file $TEST/folder2/file2 $TEST
valid $? $TEST

#
# Test 4:
#
#   ORIGIN: folder1 with files
#   DEST: folder2 with files
#
TEST=test4
mkdir -p $TEST/folder1
touch $TEST/folder1/file1
mkdir -p $TEST/folder2
touch $TEST/folder2/file2
./mvlink $TEST/folder1 $TEST/folder2
assert_link $TEST/folder1 $TEST
assert_folder $TEST/folder2 $TEST
assert_file $TEST/folder1/file1 $TEST
assert_file $TEST/folder2/file1 $TEST
assert_file $TEST/folder1/file2 $TEST
assert_file $TEST/folder2/file2 $TEST
valid $? $TEST

# Test 5:
#
#   ORIGIN: folder1 link to folder2
#   DEST: folder2
#
TEST=test5
mkdir -p $TEST/folder1
./mvlink $TEST/folder1 $TEST/folder2
assert_link $TEST/folder1 $TEST
assert_folder $TEST/folder2 $TEST
./mvlink $TEST/folder1 $TEST/folder2
assert_link $TEST/folder1 $TEST
assert_folder $TEST/folder2 $TEST
valid $? $TEST

#
# Test 6:
#
#   ORIGIN: file1
#   DEST:
#
TEST=test6
mkdir -p $TEST
echo 'file1' > $TEST/file1
./mvlink $TEST/file1 $TEST/file2
assert_link $TEST/file1 $TEST
assert_file $TEST/file2 $TEST
valid $? $TEST

#
# Test 7:
#
#   ORIGIN: file1
#   DEST: file2
#
TEST=test7
mkdir -p $TEST
echo 'file1' > $TEST/file1
echo 'file2' > $TEST/file2
./mvlink $TEST/file1 $TEST/file2
assert_link $TEST/file1 $TEST
assert_file $TEST/file2 $TEST
valid $? $TEST

#
# Test 8:
#
#   ORIGIN: file1 linked to file2
#   DEST: file2
#
TEST=test8
mkdir -p $TEST
echo 'file1' > $TEST/file1
echo 'file2' > $TEST/file2
./mvlink $TEST/file1 $TEST/file2
assert_link $TEST/file1 $TEST
assert_file $TEST/file2 $TEST
./mvlink $TEST/file1 $TEST/file2
assert_link $TEST/file1 $TEST
assert_file $TEST/file2 $TEST
valid $? $TEST

#
# Test 9:
#
#   ORIGIN: file1 in folder1
#   DEST: file2 in folder2
#
TEST=test9
mkdir -p $TEST/folder1
echo 'file1' > $TEST/folder1/file1
./mvlink $TEST/folder1/file1 $TEST/folder2/file2
assert_link $TEST/folder1/file1 $TEST
assert_file $TEST/folder2/file2 $TEST
valid $? $TEST

#
# Test 10:
#
#   ORIGIN: Structure of folders and files
#   DEST: new folder
#
TEST=test10
mkdir -p $TEST/folder1/config
mkdir -p $TEST/folder1/logs
echo 'Config file' > $TEST/folder1/config/test.conf
echo 'Log file' > $TEST/folder1/logs/test.log
echo 'first file' > $TEST/folder1/file1
echo 'second file' > $TEST/folder1/file2
mkdir -p $TEST/folder2
echo 'exisiting file' > $TEST/folder2/my_file
./mvlink $TEST/folder1 $TEST/folder2
assert_link $TEST/folder1 $TEST
assert_folder $TEST/folder2 $TEST
assert_folder $TEST/folder1/config $TEST
assert_folder $TEST/folder2/config $TEST
assert_folder $TEST/folder1/logs $TEST
assert_folder $TEST/folder2/logs $TEST
assert_file $TEST/folder1/config/test.conf $TEST
assert_file $TEST/folder2/config/test.conf $TEST
assert_file $TEST/folder1/logs/test.log $TEST
assert_file $TEST/folder2/logs/test.log $TEST
assert_file $TEST/folder1/file1 $TEST
assert_file $TEST/folder2/file1 $TEST
assert_file $TEST/folder1/file2 $TEST
assert_file $TEST/folder2/file2 $TEST
assert_file $TEST/folder1/my_file $TEST
assert_file $TEST/folder2/my_file $TEST
valid $? $TEST

