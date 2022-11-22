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
    BUILD_SYSTEM \
    BUILD_NUMBER \
    PARALLELISM \
    PREFIX \
    GCC_VERSION

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

run rm -rf gcc*

run wget -q -c "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz"

run tar -Jxf "gcc-${GCC_VERSION}.tar.xz"

run cd "gcc-${GCC_VERSION}"

run \
    check_exist \
    "${PREFIX}/gmp-${GMP_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    "${PREFIX}/isl-${ISL_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    "${PREFIX}/mpfr-${MPFR_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    "${PREFIX}/mpc-${MPC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}"

run sed -i "s/islver=\"0.15\"/islver=\"${ISL_VERSION}\"/g" configure

run ./configure --help

#
#   static libraries are always built.
#
#   $ https://gcc.gnu.org/install/configure.html, --enable-shared[=package[,...]]
#

run \
    ./configure \
    --prefix="${PREFIX}/gcc-${GCC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    --with-gmp="${PREFIX}/gmp-${GMP_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    --with-isl="${PREFIX}/isl-${ISL_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    --with-mpfr="${PREFIX}/mpfr-${MPFR_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    --with-mpc="${PREFIX}/mpc-${MPC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}" \
    --with-bugurl=http://bugzilla.redhat.com/bugzilla \
    --enable-bootstrap \
    --enable-shared \
    --enable-threads=posix \
    --enable-checking=release \
    --with-system-zlib \
    --disable-multilib \
    --enable-__cxa_atexit \
    --disable-libunwind-exceptions \
    --enable-gnu-unique-object \
    --enable-linker-build-id \
    --enable-languages=c,c++ \
    --enable-plugin \
    --with-linker-hash-style=gnu \
    --enable-initfini-array \
    --disable-libgcj \
    --with-tune=generic \
    --with-arch_32=x86-64 \
    --build=x86_64-redhat-linux \
    CFLAGS="${CFLAGS_VALUE}" \
    CXXFLAGS="${CXXFLAGS_VALUE}"

run make -j ${PARALLELISM}

#run make check -j ${PARALLELISM}

run make install

#echo "PATH=\"${PREFIX}/gcc-${GCC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/bin:\${PATH}\"" >> "${WORKING_DIRECTORY}/../PATH.text"

echo "PATH=\"\${PREFIX}/gcc-${GCC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/bin:\${PATH}\"" >> "${PREFIX}/PATH.text"

echo "LD_LIBRARY_PATH=\"${PREFIX}/gcc-${GCC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/lib64:\${LD_LIBRARY_PATH}\"" >> "${WORKING_DIRECTORY}/../LD_LIBRARY_PATH.text"

echo "LD_LIBRARY_PATH=\"\${PREFIX}/gcc-${GCC_VERSION}-${PROJECT_VERSION}-${BUILD_MODE}-${BUILD_SYSTEM}/lib64:\${LD_LIBRARY_PATH}\"" >> "${PREFIX}/LD_LIBRARY_PATH.text"

set +o errexit
