{
  description = "compression example";

  inputs = {
    pkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    zig_overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zig_overlay, ... } @ inputs: 
    let
      # system version (you may need to change this)
      system = "x86_64-linux";

      # the server only compiles on one Zig version 
      zigVersion = "0.15.2";

      # selected Zig package
      zig = zig_overlay.packages.${system}.${zigVersion};

      # add the Zig overlay pkgs
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ zig_overlay.overlays.default ];
      };
    in {
      # Nix shell (dependencies)
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          # brotli dependency 
          pkgs.brotli.dev
          # Zig overlay
          zig
        ]; 
      };
    };
}
