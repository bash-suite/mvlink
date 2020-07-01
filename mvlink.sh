#!/usr/bin/env bash

#
# DESCRIPTION: Move ORIGIN (file or folder) to DEST and create a symbolic ORIGIN to DEST
#
# EXAMPLE : mvlink /var/www/html/config /data/config  move content of /var/www/html/config 
#           to data/config and create a symbolic :
#                   /var/www/html/config -> /data/config
#
# EXAMPLE : mvlink /folder1/file1 /folder2/file2 move /folder1/file1 to /folder2 as file2 and create a symbolic 
#           into folder1 named file1 to point to file2 : file1 -> /folder2/file2
#

_mvlinkdir() {

    # ORIGIN and DEST exist
    # but ORIGIN might already be a link
    # Keep ORIGIN as reference
    if [ -d "${_origin}" ] && [ ! -L "${_origin}" ] && [ -d "${_dest}" ]; then
        # Copy data
        cp -prf "${_dest}/." "${_origin}"
        # remove folder
        rm -rf "${_dest}"
    fi

    # ORIGIN exist and DEST does not exist
    if [ -d "${_origin}" ] && [ ! -e "${_dest}" ]; then
        # Create DEST folder
        mkdir -p "${_dest}"
        # Copy data from ORIGIN to DEST
        cp -pr "${_origin}/." "${_dest}"
    fi

    # Create link
    _createlink
}

_mvlinkfile() {

    # ORIGIN and DEST exist
    # but ORIGIN might already be a link
    # Keep ORIGIN as reference
    if [ -f "${_origin}" ] && [ ! -L "${_origin}" ] && [ -f "${_dest}" ]; then
        # Copy file
        cp -pf "${_dest}" "${_origin}"
        # remove folder
        rm -f "${_dest}"
    fi

    # ORIGIN exist and DEST don't
    if [ -f "${_origin}" ] && [ ! -f "${_dest}" ]; then
        # Create DEST parent folder
        mkdir -p "$(dirname "${_dest}")"
        # Copy ORIGIN to DEST
        cp -pr "${_origin}" "${_dest}"
    fi

    # Create link
    _createlink
}

_createlink() {
    # Remove ORIGIN
    rm -rf "${_origin}"
    # Make sure ORIGIN parent folder exist
    mkdir -p "$(dirname "${_origin}")"
    # Recreate the link
    [ -d "${_dest}" ] && ln -rsT "${_dest}/" "${_origin}"
    [ -f "${_dest}" ] && ln -rsT "${_dest}" "${_origin}"

    if [ $DEBUG ]; then echo "Link created: ${_origin} -> ${_dest}"; fi
}

_mvlink() {
    # At least 2 parameters are mandatory
    [ $# -ne 2 ] && { echo "Illegal number of parameters --"; exit 1; }

    # Give a name to thoses parameters
    # and remove trailing /
    _origin=${1%/}
    _dest=${2%/}

    if [ $DEBUG ]; then [ -d "${_origin}" ]   && echo "${_origin} : is a folder"; fi
    if [ $DEBUG ]; then [ -f "${_origin}" ]   && echo "${_origin} : is a file"; fi
    if [ $DEBUG ]; then [ -L "${_origin}" ]   && echo "${_origin} : is symbolic"; fi
    if [ $DEBUG ]; then [ ! -e "${_origin}" ] && echo "${_origin} : does not exist"; fi
    if [ $DEBUG ]; then [ -d "${_dest}" ]     && echo "${_dest} : is a folder"; fi
    if [ $DEBUG ]; then [ -f "${_dest}" ]     && echo "${_dest} : is a file"; fi
    if [ $DEBUG ]; then [ -L "${_dest}" ]     && echo "${_dest} : is symbolic"; fi
    if [ $DEBUG ]; then [ ! -e "${_dest}" ]   && echo "${_dest} : does not exist"; fi
    
    # Check for folder or file
    [ -d "${_origin}" ] && { _mvlinkdir; exit $?; }
    [ -f "${_origin}" ] && { _mvlinkfile; exit $?; }

    # Error
    [ -z "${_origin}" ] && echo "ORIGIN is not of valid type"
    [ -z "${_dest}" ] && echo "DEST is not of valid type"
    exit 1
}

_mvlink "$@"
