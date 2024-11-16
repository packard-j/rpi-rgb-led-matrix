{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
    let
      # Systems supported
      allSystems = [
        "aarch64-linux" # 64-bit ARM Linux
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ pkgs }: {
        default =
          let
            cppDependencies = with pkgs; [ gcc ];
          in
          pkgs.stdenv.mkDerivation {
            name = "rpi-rgb-led-matrix";
            src = ./.;
            buildInputs = cppDependencies;
            buildPhase = "make";
            # Only building the library and demo executable to get started.
            installPhase = ''
              mkdir -p $out/lib
              mkdir -p $out/examples-api-use
              cp lib/*.{a,so} $out/lib
              cp examples-api-use/demo $out/rpi-rgb-led-matrix
            '';
          };
      });
    };
}
