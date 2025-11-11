{
  description = "My fork of the 'st' terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      pkgsFor = system: import nixpkgs { inherit system; };

    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          st = pkgs.stdenv.mkDerivation rec {
            pname = "st";
            version = "git-flake";

            src = self;

            buildInputs = with pkgs; [
              xorg.libX11
              xorg.libXft
              fontconfig
              harfbuzz
            ];

            installPhase = ''
              make install PREFIX=$out
            '';
          };
          
          default = self.packages.${system}.st;
        });
      
      defaultPackage = forAllSystems (system: self.packages.${system}.default);
    };
}
