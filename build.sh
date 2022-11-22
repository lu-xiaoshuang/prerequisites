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

source ./auxiliaries.sh

run \
    check_variables \
    THIS_SCRIPT \
    WORKING_DIRECTORY \
    PROJECT_VERSION \
    BUILD_MODE \
    BUILD_SYSTEM \
    BUILD_NUMBER \
    PARALLELISM \
    PREFIX

run echo "PROJECT_VERSION=${PROJECT_VERSION}"
run echo "BUILD_MODE=${BUILD_MODE}"
run echo "BUILD_SYSTEM=${BUILD_SYSTEM}"
run echo "BUILD_NUMBER=${BUILD_NUMBER}"
run echo "PREFIX=${PREFIX}"

run rm -rf PATH.text

run touch PATH.text

run rm -rf LD_LIBRARY_PATH.text

run touch LD_LIBRARY_PATH.text

run rm -rf HEADER_SEARCH_OPTIONS.text

run touch HEADER_SEARCH_OPTIONS.text

run rm -rf LIBRARY_SEARCH_OPTIONS.text

run touch LIBRARY_SEARCH_OPTIONS.text

run mkdir -p "${PREFIX}"

echo "prerequisites-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}-${BUILD_NUMBER}" > "${PREFIX}/VERSION"

run rm -rf "${PREFIX}/PATH.text"

run touch "${PREFIX}/PATH.text"

run rm -rf "${PREFIX}/LD_LIBRARY_PATH.text"

run touch "${PREFIX}/LD_LIBRARY_PATH.text"

run rm -rf "${PREFIX}/HEADER_SEARCH_OPTIONS.text"

run touch "${PREFIX}/HEADER_SEARCH_OPTIONS.text"

run rm -rf "${PREFIX}/LIBRARY_SEARCH_OPTIONS.text"

run touch "${PREFIX}/LIBRARY_SEARCH_OPTIONS.text"

export AUTOCONF_VERSION=2.72
export AUTOMAKE_VERSION=1.17
export BINUTILS_VERSION=2.43.1
export BISON_VERSION=3.8.2
export CLOOG_VERSION=0.21.1
export FLEX_VERSION=2.6.4
export GCC_VERSION=14.2.0
export GMP_VERSION=6.3.0
export GPERFTOOLS_VERSION=2.15
export ISL_VERSION=0.26
export JSONCPP_VERSION=1.9.5
export LIBTOOL_VERSION=2.4.7
export LIBUNWIND_VERSION=1.8.1
export LIBUV_VERSION=1.48.0
export MPC_VERSION=1.3.1
export MPFR_VERSION=4.2.1
export OPENSSL_VERSION=3.3.1
export ZLIB_VERSION=1.3.1

# autoconf automake gmp isl mpfr mpc binutils gcc bison flex jsoncpp libuv openssl zlib

for MODULE in $@
do
    run echo "Building ${MODULE}..."

    #
    #   Too many threads may cause out of memory error.
    #

    run \
        sh \
        "${WORKING_DIRECTORY}/${MODULE}/build.sh" \
        --project-version="${PROJECT_VERSION}" \
        --build-mode="${BUILD_MODE}" \
        --build-system="${BUILD_SYSTEM}" \
        --build-number="${BUILD_NUMBER}" \
        --parallelism="${PARALLELISM}" \
        --prefix="${PREFIX}"

    run echo "Building ${MODULE}... SUCCESS"
done

run sort -o "${PREFIX}/PATH.text" "${PREFIX}/PATH.text"

echo "" >> "${PREFIX}/PATH.text"

echo "export PATH" >> "${PREFIX}/PATH.text"

run sort -o "${PREFIX}/LD_LIBRARY_PATH.text" "${PREFIX}/LD_LIBRARY_PATH.text"

echo "" >> "${PREFIX}/LD_LIBRARY_PATH.text"

echo "export LD_LIBRARY_PATH" >> "${PREFIX}/LD_LIBRARY_PATH.text"

run sort -o "${PREFIX}/HEADER_SEARCH_OPTIONS.text" "${PREFIX}/HEADER_SEARCH_OPTIONS.text"

echo "" >> "${PREFIX}/HEADER_SEARCH_OPTIONS.text"

echo "export HEADER_SEARCH_OPTIONS" >> "${PREFIX}/HEADER_SEARCH_OPTIONS.text"

run sort -o "${PREFIX}/LIBRARY_SEARCH_OPTIONS.text" "${PREFIX}/LIBRARY_SEARCH_OPTIONS.text"

echo "" >> "${PREFIX}/LIBRARY_SEARCH_OPTIONS.text"

echo "export LIBRARY_SEARCH_OPTIONS" >> "${PREFIX}/LIBRARY_SEARCH_OPTIONS.text"

run rm -rf "prerequisites-"*

run mkdir "prerequisites-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}"

run cp -r "${PREFIX}/"* "prerequisites-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}"

run tar -cjf "prerequisites-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}-${BUILD_NUMBER}.tar.bz2" "prerequisites-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}"

# archive

#run ftp -inv ${address} << EOF
#user ${username} ${passowrd}
#binary
#put "prerequisites-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}-${BUILD_NUMBER}.tar.bz2" "prerequisites/rhel/${BUILD_MODE}/prerequisites-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}-${BUILD_NUMBER}.tar.bz2"
#put "prerequisites-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}-${BUILD_NUMBER}.tar.bz2" "prerequisites/rhel/${BUILD_MODE}/prerequisites-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}-latest.tar.bz2"
#bye
#EOF

set +o errexit
