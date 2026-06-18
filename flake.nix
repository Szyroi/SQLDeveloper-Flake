{
  description = "SQL Developer package";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    sqldeveloper = pkgs.callPackage ./default.nix {};
  in {
    packages = {
      ${system} = {
        default = sqldeveloper;
        sqldeveloper = sqldeveloper;
      };
    };
  };
}
