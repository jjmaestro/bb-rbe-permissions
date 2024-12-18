# `bb-rbe-permissions`

Example Bazel repo to debug BuildBuddy's RBE with a custom Docker image.

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
