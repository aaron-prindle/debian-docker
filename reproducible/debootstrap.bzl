# Copyright 2017 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Rule for building debootstrap rootfs tarballs."""

def _impl(ctx):
    # Strip off the '.tar'
    image_name = ctx.attr._builder_image.label.name.split('.', 1)[0]
    # docker_build rules always generate an image named 'bazel/$package:$name'.
    builder_image_name = "bazel/%s:%s" % (ctx.attr._builder_image.label.package,
                                          image_name)

    # Generate a shell script to run the build.
    build_contents = """\
#!/bin/bash
set -ex

docker load -i {0}
# Run the builder image.
cid=$(docker run -d --privileged {1} {2} {3})
docker attach $cid
# Copy out the rootfs.
docker cp $cid:/workspace/rootfs.tar.gz {4}

# Cleanup
docker rm $cid
 """.format(ctx.file._builder_image.path,
            builder_image_name,
            ctx.attr.variant,
            ctx.attr.distro,
            ctx.outputs.out.path)
    script = ctx.new_file(ctx.label.name + ".build")
    ctx.file_action(
        output=script,
        content=build_contents
    )

    ctx.actions.run(
        outputs=[ctx.outputs.out],
        inputs=ctx.attr._builder_image.files.to_list() +
        ctx.attr._builder_image.data_runfiles.files.to_list() + ctx.attr._builder_image.default_runfiles.files.to_list(),
        executable=script,
    )

    return struct()

debootstrap = rule(
    attrs = {
        "variant": attr.string(
            default = "minbase",
        ),
        "distro": attr.string(
            default = "jessie",
        ),
        "_builder_image": attr.label(
            default = Label("//reproducible:builder.tar"),
            allow_files = True,
            single_file = True,
        ),
    },
    executable = False,
    outputs = {
        "out": "%{name}.tar.gz",
    },
    implementation = _impl,
)

load(
    "@io_bazel_rules_docker//docker:docker.bzl",
    "docker_build",
)

def debootstrap_image(name, variant="minbase", distro="jessie", overlay_tar="", env=None):
    if not env:
        env = {}
    rootfs = "%s.rootfs" % name
    debootstrap(
        name=rootfs,
        variant=variant,
        distro=distro,
    )
    tars = [rootfs]
    if overlay_tar:
        # The overlay tar has to come first to actuall overwrite existing files.
        tars.insert(0, overlay_tar)
    docker_build(
        name=name,
        tars=tars,
        env=env,
    )

def _ubuntu_impl(ctx):
    # Strip off the '.tar'
    image_name = ctx.attr._builder_image.label.name.split('.', 1)[0]
    # docker_build rules always generate an image named 'bazel/$package:$name'.
    builder_image_name = "bazel/%s:%s" % (ctx.attr._builder_image.label.package,
                                          image_name)

    # Generate a shell script to run the build.
    build_contents = """\
#!/bin/bash
set -ex

# Download the official ubuntu .tar.gz
# TODO(aaron-prindle) remove builder-image dep/input and variable from ubuntu script
# {1} = builder_image_name (bazel/reproducible:builder)
# {2} = variant (base)
# {3} = release (16.04)
# {4} = .tar.gz name/path (bazel-out/local-fastbuild/bin/reproducible/ubuntu.rootfs.tar.gz)
curl -o {4} http://cdimage.ubuntu.com/ubuntu-{2}/releases/{3}/release/ubuntu-{2}-{3}-core-amd64.tar.gz
 """.format(ctx.file._builder_image.path,
            builder_image_name,
            ctx.attr.variant,
            ctx.attr.release,
            ctx.outputs.out.path)
    script = ctx.new_file(ctx.label.name + ".build")
    ctx.file_action(
        output=script,
        content=build_contents
    )

    ctx.actions.run(
        outputs=[ctx.outputs.out],
        inputs=ctx.attr._builder_image.files.to_list() +
        ctx.attr._builder_image.data_runfiles.files.to_list() + ctx.attr._builder_image.default_runfiles.files.to_list(),
        executable=script,
    )

    return struct()

ubuntu_download = rule(
    attrs = {
        "variant": attr.string(
            default = "base",
        ),
        "release": attr.string(
            default = "16.04",
        ),
        "_builder_image": attr.label(
            default = Label("//reproducible:builder.tar"),
            allow_files = True,
            single_file = True,
        ),
    },
    executable = False,
    outputs = {
        "out": "%{name}.tar.gz",
    },
    implementation = _ubuntu_impl,
)

def ubuntu_image(name, variant="base", release="16.04", overlay_tar="", env=None):
    if not env:
        env = {}
    rootfs = "%s.rootfs" % name
    ubuntu_download(
        name=rootfs,
        variant=variant,
        release=release,
    )
    tars = [rootfs]
    if overlay_tar:
        # The overlay tar has to come first to actuall overwrite existing files.
        tars.insert(0, overlay_tar)
    docker_build(
        name=name,
        tars=tars,
        env=env,
    )
