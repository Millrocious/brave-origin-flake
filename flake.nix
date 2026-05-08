{
  description = "Brave Origin Nightly Binary Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.callPackage ./package.nix { };
          brave-origin = pkgs.callPackage ./package.nix { };
        }
      );

      overlays.default = final: prev: {
        brave-origin = final.callPackage ./package.nix { };
      };
    };
}
