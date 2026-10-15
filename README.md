# photocraft-flake

A Nix flake for [PhotoCraft](https://github.com/storytold/photocraft). It repackages the upstream Linux release tarball for `x86_64-linux` and `aarch64-linux`, and nothing is built from source. Only the latest release is tracked. A daily workflow bumps `sources.json` when upstream publishes a new one.

Try it without installing:

```sh
nix run github:nolight132/photocraft-flake
```

Add it to a NixOS or home-manager config:

```nix
{
  inputs.photocraft.url = "github:nolight132/photocraft-flake";

  # NixOS
  environment.systemPackages = [ inputs.photocraft.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # or with the overlay
  nixpkgs.overlays = [ inputs.photocraft.overlays.default ];
  environment.systemPackages = [ pkgs.photocraft ];
}
```

The package installs `photocraft` and `photocraft-cli`, the desktop entry, icons and MIME types. The upstream binaries link only libc and libgcc and load Wayland, X11, EGL, Vulkan and D-Bus at runtime, so both programs run through a wrapper that puts those libraries on `LD_LIBRARY_PATH`.

To bump by hand, run `./update.sh`. It reads the latest release tag and takes the hashes from the release's `SHA256SUMS.txt`.
