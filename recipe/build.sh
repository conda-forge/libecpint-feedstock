#!/bin/bash

cmake ${CMAKE_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_C_COMPILER=${CC} \
  -D CMAKE_C_FLAGS="${CFLAGS}" \
  -D CMAKE_CXX_COMPILER=${CXX} \
  -D CMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D LIBECPINT_BUILD_TESTS=ON \
  -D Python_EXECUTABLE="${BUILD_PREFIX}/bin/python" \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

cmake --build build --target install -j${CPU_COUNT}

cd build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --rerun-failed --output-on-failure -j${CPU_COUNT}
fi
