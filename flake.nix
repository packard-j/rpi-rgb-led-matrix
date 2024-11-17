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
    rec {
      apps = forAllSystems ({ pkgs }: {
        default = let
          demo = pkgs.writeShellApplication {
            name = "rpi-rgb-led-demo";
            runtimeInputs = [packages.rpi-rgb-led-matrix];
            text = ''
              rpi-rgb-led-matrix -D0 --led-gpio-mapping=adafruit-hat --led-rows=64 --led-cols=64 --led-slowdown-gpio=2
            '';
          };
        in {
          type = "app";
          program = "${demo}/bin/rpi-rgb-led-demo";
        };
      });
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
              mkdir -p $out/bin
              cp lib/*.{a,so} $out/lib
              cp examples-api-use/demo $out/bin/rpi-rgb-led-matrix
            '';
          };
      });
    };
}
