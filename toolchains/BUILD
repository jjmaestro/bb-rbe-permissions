package(default_visibility = ["//visibility:public"])

platform(
    name = "custom_docker_image_amd64",
    constraint_values = [
        "@bazel_tools//tools/cpp:gcc",
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    exec_properties = {
        "OSFamily": "Linux",
        "container-image": "docker://ghcr.io/jjmaestro/bb-rbe-permissions/debian-rbe@sha256:1f7eb36169deae239f385a6fbabb254f4ede63837b1819df0ac1d1b01020e977",
        "nonroot-workspace": "true",
    },
)

platform(
    name = "custom_docker_image_arm64",
    constraint_values = [
        "@bazel_tools//tools/cpp:gcc",
        "@platforms//os:linux",
        "@platforms//cpu:arm64",
    ],
    exec_properties = {
        "OSFamily": "Linux",
        "container-image": "docker://ghcr.io/jjmaestro/bb-rbe-permissions/debian-rbe@sha256:931db995e1a3d455e877c36da7b543ee6b83821f8ccc3417dd324bdab7ee3de9",
        "nonroot-workspace": "true",
    },
)
