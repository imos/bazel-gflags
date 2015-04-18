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
