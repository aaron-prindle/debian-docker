package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build")

ubuntu_16_0_4_ENV = {
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

NODEJS_ENV = {
    "PORT": "8080",
    "NODE_ENV": "production",
}

# 'ubuntu_16_0_4_vanilla' is docker image derived from a snapshot ubuntu_16_0_4 rootfs
docker_build(
    name = "ubuntu_16_0_4_vanilla",
    cmd = "/bin/bash",
    env = ubuntu_16_0_4_ENV,
    tars = ["@ubuntu_16_0_4_tar_download//file"],
)

# 'ubuntu_16_0_4' is a ubuntu_16_0_4 rootfs w/ ca-certificates, curl, and netbase
docker_build(
    name = "ubuntu_16_0_4",
    base = "//dockerfile_build:ubuntu_16_0_4.tar",
)

# 'ubuntu_16_0_4_build' is the 'ubuntu_16_0_4' image w/ build-essential and python2.7
docker_build(
    name = "ubuntu_16_0_4_build",
    base = "//dockerfile_build:ubuntu_16_0_4_build.tar",
)

NODE_VERSIONS = [
    "8_5_0",
]

sh_binary(
    name = "node_gen_tar",
    srcs = ["node_gen_tar.sh"],
    data = [
        "mknodeimage.sh",
        "//dockerfile_build:ubuntu_16_0_4_build.tar",
    ],
)

# node_%s_ubuntu_16_0_4 is a docker image that is a nodejs install compiled from src
# on top of a vanilla ubuntu_16_0_4 release
[docker_build(
    name = "node_%s_ubuntu" % version,
    base = "//dockerfile_build:ubuntu_16_0_4",
    env = NODEJS_ENV,
    ports = ["8080"],
    tars = [
        "node_v%s_compiled.tar.gz" % version.replace("_", "."),
    ],
) for version in NODE_VERSIONS]

# node_%s_ubuntu_16_0_4_build is a docker image that is a nodejs install compiled from
# src on top of a vanilla ubuntu_16_0_4 release + build_essential/python2.7
[docker_build(
    name = "node_%s_ubuntu_build" % version,
    base = ":ubuntu_16_0_4_build",
    env = NODEJS_ENV,
    tars = [
        "node_v%s_compiled.tar.gz" % version.replace("_", "."),
    ],
) for version in NODE_VERSIONS]
