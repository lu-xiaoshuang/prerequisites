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

THIS_SCRIPT="$(basename "$(readlink -f "$0")")"

WORKING_DIRECTORY="$(dirname "$(readlink -f "$0")")"

source "${WORKING_DIRECTORY}/../auxiliaries.sh"

source "${WORKING_DIRECTORY}/../PATH.text"

export PATH

source "${WORKING_DIRECTORY}/../LD_LIBRARY_PATH.text"

export LD_LIBRARY_PATH

run \
    check_variables \
    THIS_SCRIPT \
    WORKING_DIRECTORY \
    PROJECT_VERSION \
    BUILD_MODE \
    BUILD_NUMBER \
    PARALLELISM \
    PREFIX \
    MPC_VERSION

if [[ "x${BUILD_MODE}" == "xdebug" ]]
then
    CFLAGS_VALUE="-m64 -fPIC -g3 -O0"
    CXXFLAGS_VALUE="-m64 -fPIC -g3 -O0"
elif [[ "x${BUILD_MODE}" == "xrelease" ]]
then
    CFLAGS_VALUE="-m64 -fPIC -g0 -O3"
    CXXFLAGS_VALUE="-m64 -fPIC -g0 -O3"
else
    echo "Invalid build mode. (debug, release)"
    exit -1
fi

run which gcc
run gcc -v
run which g++
run g++ -v

# build

run cd "${WORKING_DIRECTORY}"

run rm -rf mpc*

run wget -q -c https://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz

run tar -zxf mpc-${MPC_VERSION}.tar.gz

run cd mpc-${MPC_VERSION}

run \
    check_exist \
    "${PREFIX}/gmp-${GMP_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    "${PREFIX}/mpfr-${MPFR_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}"

run ./configure --help

run \
    ./configure \
    --prefix="${PREFIX}/mpc-${MPC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    --with-gmp="${PREFIX}/gmp-${GMP_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    --with-mpfr="${PREFIX}/mpfr-${MPFR_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    --enable-shared=yes \
    --enable-static=yes \
    CFLAGS="${CFLAGS_VALUE}" \
    CXXFLAGS="${CXXFLAGS_VALUE}"

run make -j ${PARALLELISM}

run make check -j ${PARALLELISM}

run make install

echo "LD_LIBRARY_PATH=\"${PREFIX}/mpc-${MPC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/lib:\${LD_LIBRARY_PATH}\"" >> "${WORKING_DIRECTORY}/../LD_LIBRARY_PATH.text"

echo "LD_LIBRARY_PATH=\"\${PREFIX}/mpc-${MPC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/lib:\${LD_LIBRARY_PATH}\"" >> "${PREFIX}/LD_LIBRARY_PATH.text"

echo "HEADER_SEARCH_OPTIONS=\"-I \\\"${PREFIX}/mpc-${MPC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/include\\\" \${HEADER_SEARCH_OPTIONS}\"" >> "${WORKING_DIRECTORY}/../HEADER_SEARCH_OPTIONS.text"

echo "HEADER_SEARCH_OPTIONS=\"-I \\\"\${PREFIX}/mpc-${MPC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/include\\\" \${HEADER_SEARCH_OPTIONS}\"" >> "${PREFIX}/HEADER_SEARCH_OPTIONS.text"

echo "LIBRARY_SEARCH_OPTIONS=\"-L\\\"${PREFIX}/mpc-${MPC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/lib\\\" \${LIBRARY_SEARCH_OPTIONS}\"" >> "${WORKING_DIRECTORY}/../LIBRARY_SEARCH_OPTIONS.text"

echo "LIBRARY_SEARCH_OPTIONS=\"-L\\\"\${PREFIX}/mpc-${MPC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/lib\\\" \${LIBRARY_SEARCH_OPTIONS}\"" >> "${PREFIX}/LIBRARY_SEARCH_OPTIONS.text"

set +o errexit
