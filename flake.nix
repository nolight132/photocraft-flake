{
  description = "PhotoCraft, packaged from the upstream release binaries";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        photocraft = pkgs.callPackage ./package.nix { };
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.photocraft;
      });

      overlays.default = final: _prev: {
        photocraft = final.callPackage ./package.nix { };
      };

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
