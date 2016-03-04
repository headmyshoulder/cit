set -x
set -e

if [ -n "$GCC_VERSION" ];
then
    export GCOV=/usr/bin/gcov-$GCC_VERSION
fi

cd $THIRD_PARTY_ROOT
if [[ "${TRAVIS_OS_NAME}" == "linux" ]]; then
  CMAKE_URL="http://www.cmake.org/files/v3.3/cmake-3.3.2-Linux-x86_64.tar.gz"
  mkdir cmake && wget --no-check-certificate --quiet -O - ${CMAKE_URL} | tar --strip-components=1 -xz -C cmake
  export PATH=${THIRD_PARTY_ROOT}/cmake/bin:${PATH}
else
  brew install cmake
fi



if [ "$LIBCXX" == "on" ]; then

    cd $THIRD_PARTY_ROOT

    if   [ "${CXX}" == "clang++-3.5" ]; then LLVM_VERSION="3.5.2"
    elif [ "${CXX}" == "clang++-3.6" ]; then LLVM_VERSION="3.6.2";
    elif [ "${CXX}" == "clang++-3.7" ]; then LLVM_VERSION="3.7.0";
    else                                     LLVM_VERSION="trunk"; fi
    
    if [ "${LLVM_VERSION}" != "trunk" ]; then
        LLVM_URL="http://llvm.org/releases/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz"
        LIBCXX_URL="http://llvm.org/releases/${LLVM_VERSION}/libcxx-${LLVM_VERSION}.src.tar.xz"
        LIBCXXABI_URL="http://llvm.org/releases/${LLVM_VERSION}/libcxxabi-${LLVM_VERSION}.src.tar.xz"
        TAR_FLAGS="-xJ"
    else
        LLVM_URL="https://github.com/llvm-mirror/llvm/archive/master.tar.gz"
        LIBCXX_URL="https://github.com/llvm-mirror/libcxx/archive/master.tar.gz"
        LIBCXXABI_URL="https://github.com/llvm-mirror/libcxxabi/archive/master.tar.gz"
        TAR_FLAGS="-xz"
    fi

    mkdir -p llvm llvm/build llvm/projects/libcxx llvm/projects/libcxxabi
    wget --quiet -O - ${LLVM_URL} | tar --strip-components=1 ${TAR_FLAGS} -C llvm
    wget --quiet -O - ${LIBCXX_URL} | tar --strip-components=1 ${TAR_FLAGS} -C llvm/projects/libcxx
    wget --quiet -O - ${LIBCXXABI_URL} | tar --strip-components=1 ${TAR_FLAGS} -C llvm/projects/libcxxabi
    (cd llvm/build && cmake .. -DCMAKE_INSTALL_PREFIX=${DEPS_DIR}/llvm/install -DCMAKE_CXX_COMPILER=clang++)
    (cd llvm/build/projects/libcxx && make install -j2)
    (cd llvm/build/projects/libcxxabi && make install -j2)
fi


if [ -n "$COVERALLS_BUILD" ];
then

    # gcc 4.9 does not work with lcov 1.10, we need to install lcov 1.11
    cd $THIRD_PARTY_ROOT
    curl http://ftp.uk.debian.org/debian/pool/main/l/lcov/lcov_1.11.orig.tar.gz -O
    tar xfz lcov_1.11.orig.tar.gz
    mkdir -p lcov && make -C lcov-1.11/ install PREFIX=$THIRD_PARTY_ROOT/lcov
    export PATH="${THIRD_PARTY_ROOT}/lcov/usr/bin:${PATH}"
    rm -Rf lcov-1.11/ lcov_1.11.orig.tar.gz
    
    gem install coveralls-lcov

    lcov --version
fi

