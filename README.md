# `bb-rbe-permissions`

Example Bazel repo to debug BuildBuddy's RBE with a custom Docker image.

## FINAL FIXES

I managed to get the example to build using BuildBuddy's official toolchain
with a couple of customizations after [chatting with BB] and adding two PRs
([buildbuddy-toolchain/pull/39] and [buildbuddy-toolchain/pull/40]):
```starlark
bazel_dep(name = "toolchains_buildbuddy", dev_dependency = True)
git_override(
    module_name = "toolchains_buildbuddy",
    # TODO: update hash and remote once PRs #39 and #40 land
    commit = "5d1e2b9687b7093a23e53288300164346361c7a0",
    remote = "https://github.com/jjmaestro/buildbuddy-toolchain",
)

buildbuddy = use_extension("@toolchains_buildbuddy//:extensions.bzl", "buildbuddy", dev_dependency = True)

buildbuddy.platform(
    container_image = "docker://ghcr.io/jjmaestro/bb-rbe-permissions/debian-rbe:latest",
)

buildbuddy.gcc_toolchain(
    gcc_version = "12",
)

use_repo(buildbuddy, "buildbuddy_toolchain")
```

And now, this works:
```
bazel build --config=remote-bb-linux-x86_64 //example

bazel build --config=remote-bb-linux-arm64 //example
```

<details>
<summary>OLD debugging steps</summary>

## Local build: works
Works:
```
bazel build //example
```

## BB RBE with BB toolchain and image:

Works:
```
bazel build \
    --config=remote-bb-linux-x86_64 \
    //example
```

## BB RBE with custom toolchain and image:
FAIL: https://app.buildbuddy.io/invocation/c79e8636-983d-483b-9db6-9e9354159c08
```
bazel build \
    --config=remote-custom-linux-x86_64 \
    //example

(17:33:32) INFO: Invocation ID: a5342e14-b078-4c15-b21c-39221b314497
(17:33:32) INFO: Streaming build results to: https://app.buildbuddy.io/invocation/a5342e14-b078-4c15-b21c-39221b314497
(17:33:32) INFO: Current date is 2024-12-19
(17:33:32) INFO: Analyzed target //example:example (1 packages loaded, 359 targets configured).
(17:33:34) ERROR: /Users/jjmaestro/Work/BAZEL/TESTING/bb-rbe-permissions/example/BUILD:3:10: Compiling example/example.cc failed: (Exit 1): gcc failed: error executing CppCompile command (from target //example:example) /usr/bin/gcc -U_FORTIFY_SOURCE -fstack-protector -Wall -Wunused-but-set-parameter -Wno-free-nonheap-object -fno-omit-frame-pointer '-std=c++17' -MD -MF ... (remaining 24 arguments skipped)
example/example.cc:19:1: fatal error: opening dependency file bazel-out/darwin_arm64-fastbuild/bin/example/_objs/example/example.pic.d: Permission denied
   19 | }
      | ^
compilation terminated.
Target //example:example failed to build
Use --verbose_failures to see the command lines of failed build steps.
(17:33:34) INFO: Elapsed time: 1.804s, Critical Path: 1.67s
(17:33:34) INFO: 2 processes: 2 internal.
(17:33:34) ERROR: Build did NOT complete successfully
(17:33:34) INFO: Streaming build results to: https://app.buildbuddy.io/invocation/a5342e14-b078-4c15-b21c-39221b314497
```

## Fixing permissions:

To fix the permission error I had to set `nonroot-workspace` to `true`:
```diff
diff --git a/toolchains/BUILD b/toolchains/BUILD
index 76791db..30ec585 100644
--- a/toolchains/BUILD
+++ b/toolchains/BUILD
@@ -10,6 +10,7 @@ platform(
     exec_properties = {
         "OSFamily": "Linux",
         "container-image": "docker://ghcr.io/jjmaestro/bb-rbe-permissions/debian-rbe@sha256:1f7eb36169deae239f385a6fbabb254f4ede63837b1819df0ac1d1b01020e977",
+        "nonroot-workspace": "true",
     },
 )
 
@@ -23,5 +24,6 @@ platform(
     exec_properties = {
         "OSFamily": "Linux",
         "container-image": "docker://ghcr.io/jjmaestro/bb-rbe-permissions/debian-rbe@sha256:931db995e1a3d455e877c36da7b543ee6b83821f8ccc3417dd324bdab7ee3de9",
+        "nonroot-workspace": "true",
     },
 )
```

But then, I got yet-another error:
```
bazel build \
    --config=remote-custom-linux-x86_64 \
    //example

(20:04:25) INFO: Invocation ID: 79e4e271-4194-448e-84d7-30fe13676ffc
(20:04:25) INFO: Streaming build results to: https://app.buildbuddy.io/invocation/79e4e271-4194-448e-84d7-30fe13676ffc
(20:04:25) INFO: Current date is 2024-12-19
(20:04:25) INFO: Analyzed target //example:example (1 packages loaded, 359 targets configured).
(20:04:26) ERROR: /Users/jjmaestro/Work/BAZEL/TESTING/bb-rbe-permissions/example/BUILD:3:10: Compiling example/example.cc failed: absolute path inclusion(s) found in rule '//example:example':
the source file 'example/example.cc' includes the following non-builtin files with absolute paths (if these are builtin files, make sure these paths are in your toolchain):
  '/usr/lib/gcc/x86_64-linux-gnu/12/include/stddef.h'
  '/usr/lib/gcc/x86_64-linux-gnu/12/include/stdarg.h'
  '/usr/lib/gcc/x86_64-linux-gnu/12/include/stdint.h'
Target //example:example failed to build
Use --verbose_failures to see the command lines of failed build steps.
(20:04:26) INFO: Elapsed time: 0.404s, Critical Path: 0.29s
(20:04:26) INFO: 5 processes: 5 internal.
(20:04:26) ERROR: Build did NOT complete successfully
(20:04:26) INFO: Streaming build results to: https://app.buildbuddy.io/invocation/79e4e271-4194-448e-84d7-30fe13676ffc
```
</details>

[chatting with BB]: https://buildbuddy.slack.com/archives/CUHBFVATU/p1734626772009149
[buildbuddy-toolchain/pull/39]: https://github.com/buildbuddy-io/buildbuddy-toolchain/pull/39
[buildbuddy-toolchain/pull/40]: https://github.com/buildbuddy-io/buildbuddy-toolchain/pull/40
