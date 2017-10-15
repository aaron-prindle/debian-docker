load("//rules:dockerfile_build.bzl", "dockerfile_build")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

pkg_tar(
    name = "context",
    srcs = glob(["foo/**/*"]),
    package_dir = "/",
    strip_prefix = "foo/",
)

dockerfile_build(
    name = "ubuntu_build",
    base = "//reproducible:ubuntu.tar",
    context = ":context.tar",
    dockerfile = ":Dockerfile",
)
