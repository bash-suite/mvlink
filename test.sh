#!/bin/sh
DIR="$(cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"

# remove all tests
rm -rf "$DIR/.tmp" && mkdir -p "$DIR/.tmp" && cd "$DIR/.tmp"
ln -s "$DIR/mvlink.sh" mvlink
chmod +x mvlink

# helper functions
assert_link() {
    if [ ! -L "$1" ]; then echo "\e[31mERROR ${2:-}: \e[32m$1 \e[31mis not a symbolic link\e[0m"; exit 2; fi
}
assert_folder() {
    if [ ! -d "$1" ]; then echo "\e[31mERROR ${2:-}: \e[32m$1 \e[31mis not a folder\e[0m"; exit 3; fi
}
assert_file() {
    if [ ! -f "$1" ]; then echo "\e[31mERROR ${2:-}: \e[32m$1 \e[31mis not a file\e[0m"; exit 4; fi
}
valid() {
    if [ "$1" -eq 0 ]; then echo "\e[92m$2: OK\e[0m"; else echo "\e[92m$2: ERROR $1\e[0m"; fi
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
assert_file $TEST/folder1/file2 $TEST
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
#
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

