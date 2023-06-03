#!/bin/bash

echo PREFIX
find ${PREFIX} -name "*python*"
echo BUILD_PREFIX
find ${BUILD_PREFIX} -name "*python*"


cmake ${CMAKE_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D BUILD_SHARED_LIBS=ON \
  -D LIBECPINT_USE_PUGIXML=ON \
  -D LIBECPINT_BUILD_TESTS=ON \
  -D LIBECPINT_BUILD_DOCS=OFF \
  -D Python_EXECUTABLE="${BUILD_PREFIX}/bin/python" \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

cmake --build build --target install -j${CPU_COUNT}

cd build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --rerun-failed --output-on-failure -j${CPU_COUNT}
fi
