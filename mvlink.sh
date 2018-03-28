#!/bin/sh

#
# DESCRIPTION: Move ORIGIN (file or folder) to DEST and create a symbolic ORIGIN to DEST
#
# EXAMPLE : mvlink /var/www/html/config /data/config  move content of /var/www/html/config 
#           to data/config and create a symbolic :
#                   var/www/html/config -> /data/config
#
# EXAMPLE : mvlink /folder1/file1 /folder2/file2 move /folder1/file1 to /folder2 as file2 and create a symbolic 
#           into folder1 named file1 to point to file2 : file1 -> /folder2/file2
#

function _mvlinkdir() {

    # ORIGIN and DEST exist
    # but ORIGIN might already be a link
    # Keep ORIGIN as reference
    if [ -d ${_origin} -a ! -L ${_origin} -a -d ${_dest} ]; then
        # Copy data
        cp -prf "${_dest}/." ${_origin}
        # remove folder
        rm -rf ${_dest}
    fi

    # ORIGIN exist and DEST does not exist
    if [ -d ${_origin} -a ! -e ${_dest} ]; then
        # Create DEST folder
        mkdir -p ${_dest}
        # Copy data from ORIGIN to DEST
        cp -pr "${_origin}/." ${_dest}
    fi

    # Create link
    _createlink
}

function _mvlinkfile() {

    # ORIGIN and DEST exist
    # but ORIGIN might already be a link
    # Keep ORIGIN as reference
    if [ -f ${_origin} -a ! -L ${_origin} -a -f ${_dest} ]; then
        # Copy file
        cp -pf ${_dest} ${_origin}
        # remove folder
        rm -f ${_dest}
    fi

    # ORIGIN exist and DEST don't
    if [ -f ${_origin} -a ! -f ${_dest} ]; then
        # Create DEST parent folder
        mkdir -p "$(dirname ${_dest})"
        # Copy ORIGIN to DEST
        cp -pr ${_origin} ${_dest}
    fi

    # Create link
    _createlink
}

function _createlink() {
    # Remove ORIGIN
    rm -rf ${_origin}
    # Make sure ORIGIN parent folder exist
    mkdir -p $(dirname ${_origin})
    # Recreate the link
    [ -d ${_dest} ] && ln -s "${_dest}/" ${_origin}
    [ -f ${_dest} ] && ln -s "${_dest}" ${_origin}
}

function _mvlink() {
    # At least 2 parameters are mandatory
    [ $# -ne 2 ] && { echo "Illegal number of parameters --"; exit 1; }

    # Give a name to thoses parameters
    # and remove trailing /
    _origin=${1%/}
    _dest=${2%/}

    #[ -d ${_origin} ] && echo "${_origin} : is a folder"
    #[ -f ${_origin} ] && echo "${_origin} : is a file"
    #[ -L ${_origin} ] && echo "${_origin} : is symbolic"
    #[ ! -e ${_origin} ] && echo "${_origin} : do not exist"
    #[ -d ${_dest} ] && echo "${_dest} : is a folder"
    #[ -f ${_dest} ] && echo "${_dest} : is a file"
    #[ -L ${_dest} ] && echo "${_dest} : is symbolic"
    #[ ! -e ${_dest} ] && echo "${_dest} : do not exist"
    
    # Check for folder or file
    [ -d ${_origin} -o -d ${_dest} ] && { _mvlinkdir; exit $?; }
    [ -f ${_origin} -o -f ${_dest} ] && { _mvlinkfile; exit $?; }

    # Error
    [ -z ${_origin} ] && echo "ORIGIN is not of valid type"
    [ -z ${_dest} ] && echo "DEST is not of valid type"
    exit 1
}

_mvlink "$@"

unset _origin _dest
unset -f _mvlink _mvlinkdir _mvlinkfile _createlink
exit 0
