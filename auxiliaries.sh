#!/usr/bin/env sh

#
# Copyright (C) 2022 Xiaoshuang LU
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

# If a command fails, then the shell shall immediately exit.
set -o errexit

function run()
{
    # write command itself to standard output
    echo "\$ $@"

    # run
    "$@"

    exit_status_value="$?"

    # check exit status value
    if [ "x$exit_status_value" != "x0" ];
    then
        echo
        echo "FAILURE"
        echo
        exit "$exit_status_value"
    fi
}

function check_variables()
{
    for entry in $@
    do
        entry_value=""
        eval entry_value=\${${entry}}

        if [[ "x${entry_value}" == "x" ]]
        then
            echo "${entry} is not specified."
            exit -1
        fi
    done
}

function check_exist()
{
    for entry in $@
    do
       if [[ ! -d "${entry}" ]]
       then
           echo "${entry} does not exist."
           exit -1
       fi
    done
}

#
#   References
#
#   $ http://stackoverflow.com/questions/402377/using-getopts-in-bash-shell-script-to-get-long-and-short-command-line-options/
#
OPTION_PARSER=$(getopt -o : -l project-version:,build-mode:,build-system:,build-number:,parallelism:,prefix: -- "$@")

eval set -- "$OPTION_PARSER"

while true
do
    case "$1" in
        --project-version)
            PROJECT_VERSION=$2
            shift 2
            ;;

        --build-mode)
            BUILD_MODE=$2
            shift 2
            ;;

        --build-system)
            BUILD_SYSTEM=$2
            shift 2
            ;;

        --build-number)
            BUILD_NUMBER=$2
            shift 2
            ;;

        --parallelism)
            PARALLELISM=$2
            shift 2
            ;;

        --prefix)
            PREFIX=$2
            shift 2
            ;;

        --)
            shift
            break
            ;;
    esac
done

set +o errexit
