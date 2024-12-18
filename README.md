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
