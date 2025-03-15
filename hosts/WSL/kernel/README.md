A kernel build for WSL2 to enable newer features. Nixos-WSL does not have a kernel, it's provided by WSL. By default it is `5.15` (LTS), but we can replace it with `6.6.y`.

Build the kernel;

```sh
nix-build --expr 'with import <nixpkgs> {}; callPackage ./. {}'
```

Copy result over to windows;

```sh
cp result/bzImage2 ~/windows/.wslkernel
```

Following must be set within `.wslconfig`;

```ini
[wsl2]
kernel=`C:\\path\\to\\.wslkernel
```

For more info, read [here](https://learn.microsoft.com/en-us/community/content/wsl-user-msft-kernel-v6).
