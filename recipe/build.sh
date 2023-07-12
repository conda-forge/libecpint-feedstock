if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
    ARCH_ARGS="-Dgenecpint_DIR=${PWD}/build_native"
else
    ARCH_ARGS=""
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
    # ecpint has a compiled executable, `generate`, that writes source files.
    #   generate has to run on native osx-64, not target osx-arm64, thus this extra cmake invocation.
    env -u SDKROOT -u CONDA_BUILD_SYSROOT -u CMAKE_PREFIX_PATH \
        -u CXXFLAGS -u CPPFLAGS -u CFLAGS -u LDFLAGS \
    cmake \
      -S ${SRC_DIR} \
      -B build_native \
      -G Ninja \
      -D CMAKE_C_COMPILER=${CC_FOR_BUILD} \
      -D CMAKE_CXX_COMPILER=${CXX_FOR_BUILD} \
      -D CMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,$BUILD_PREFIX/lib" \
      -D LIBECPINT_USE_PUGIXML=OFF \
      -D LIBECPINT_BUILD_TESTS=ON \
      -D LIBECPINT_BUILD_DOCS=OFF

    cmake --build build_native --target generate
fi

cmake ${CMAKE_ARGS} ${ARCH_ARGS} \
  -S ${SRC_DIR} \
  -B build \
  -G Ninja \
  -D CMAKE_INSTALL_PREFIX=${PREFIX} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_C_COMPILER=${CC} \
  -D CMAKE_CXX_COMPILER=${CXX} \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D BUILD_SHARED_LIBS=ON \
  -D LIBECPINT_USE_PUGIXML=ON \
  -D CMAKE_REQUIRE_FIND_PACKAGE_pugixml=ON \
  -D LIBECPINT_BUILD_TESTS=ON \
  -D LIBECPINT_BUILD_DOCS=OFF \
  -D Python_EXECUTABLE="${BUILD_PREFIX}/bin/python" \
  -D CMAKE_PREFIX_PATH="${PREFIX}"

  #-D Python_EXECUTABLE="${BUILD_PREFIX}/bin/python" \
  #-D Python_EXECUTABLE="${PREFIX}/bin/python" \

cmake --build build --target install -j${CPU_COUNT}

cd build
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --rerun-failed --output-on-failure -j${CPU_COUNT}
fi
