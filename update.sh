#!/bin/bash

set -e -u

cd "$(dirname "${0}")"

: "${UPDATE_REPOSITORY:=1}"

if (( UPDATE_REPOSITORY )); then
  rm -rf repository
fi

if [ ! -d repository ]; then
  git clone 'https://github.com/gflags/gflags' repository
fi

pushd repository
cmake .
popd

rm -rf src
mkdir src
cp repository/src/*.h repository/src/*.cc src/
mkdir -p src/include
cp -R repository/include/gflags src/include/

cat << EOM > src/BUILD
licenses(["notice"])

cc_library(
    name = "gflags",
    srcs = glob(["*.cc", "*.h"], exclude = ["windows_*"]),
    hdrs = glob(["gflags/*.h"]),
    visibility = ["//visibility:public"],
    copts = ["-I.", "-Iinclude/gflags"],
    includes = ["include"],
    linkopts = ["-pthread"],
)
EOM

touch src/WORKSPACE
zip -9 archive.zip src/*

rm -rf test
mkdir test

cp -R repository/test/* test/

cat << EOM > test/WORKSPACE
http_archive(
    name = "gflags-archive",
    sha256 = "$(openssl dgst -sha256 archive.zip | cut -d' ' -f2)",
    url = "http://127.0.0.1:8080/archive.zip",
)

bind(
    name = "gflags",
    actual = "@gflags-archive//:gflags",
)
EOM

cat << EOM > test/BUILD
cc_test(
    name = "gflags_unittest",
    srcs = ["gflags_unittest.cc"],
    deps = ["//external:gflags"],
)
EOM
