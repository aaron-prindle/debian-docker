workspace(name = "debian_docker")

# Docker rules.
git_repository(
    name = "io_bazel_rules_docker",
    commit = "8bbe2a8abd382641e65ff7127a3700a8530f02ce",
    remote = "https://github.com/bazelbuild/rules_docker.git",
)

load(
    "@io_bazel_rules_docker//docker:docker.bzl",
    "docker_repositories",
    "docker_pull",
)
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

docker_repositories()

docker_pull(
    name = "debian_base",
    digest = "sha256:987494b558cc0c9c341b5808b6e259ee449cf70c6f7c7adce4fd8f15eef1dea2",
    registry = "gcr.io",
    repository = "google-appengine/debian8",
)

git_repository(
    name = "distroless",
    commit = "bd16e2028cc0dd6acba3de58448c94b3d2ead21a",
    remote = "https://github.com/GoogleCloudPlatform/distroless.git",
)

load(
    "@distroless//package_manager:package_manager.bzl",
    "package_manager_repositories",
    "dpkg_src",
    "dpkg_list",
)

package_manager_repositories()

# The Debian snapshot datetime to use. See http://snapshot.debian.org/ for more information.
SNAPSHOT = "20171017T102456Z"

dpkg_src(
    name = "debian_jessie",
    arch = "amd64",
    distro = "jessie",
    sha256 = "142cceae78a1343e66a0d27f1b142c406243d7940f626972c2c39ef71499ce61",
    snapshot = SNAPSHOT,
    url = "http://snapshot.debian.org/archive",
)

# These are needed to install debootstrap.
dpkg_list(
    name = "package_bundle",
    packages = [
        "ca-certificates",
        "debootstrap",
        "libffi6",
        "libgmp10",
        "libgnutls-deb0-28",
        "libhogweed2",
        "libicu52",
        "libidn11",
        "libnettle4",
        "libp11-kit0",
        "libpsl0",
        "libtasn1-6",
        "wget",
    ],
    sources = [
        "@debian_jessie//file:Packages.json",
    ],
)

git_repository(
    name = "runtimes_common",
    commit = "f0e627c4fae70c4220636eac0d2cedb83391e930",
    remote = "https://github.com/GoogleCloudPlatform/runtimes-common.git",
)

git_repository(
    name = "io_bazel_rules_go",
    remote = "https://github.com/bazelbuild/rules_go.git",
    tag = "0.5.5",
)

load(
    "@io_bazel_rules_go//go:def.bzl",
    "go_repositories",
)

go_repositories()

http_file(
    name = "ubuntu_16_0_4_tar_download",
    sha256 = "e43f802f876505c0cee1759fbc545f65b2d59c4dd33835e93afea3fa124b5799",
    url = "https://partner-images.canonical.com/core/xenial/20171006/ubuntu-xenial-core-cloudimg-amd64-root.tar.gz",
)
