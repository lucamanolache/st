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
              pkg-config
              xorg.libX11
              xorg.libXft
              fontconfig
              harfbuzz
              ncurses
            ];

            installPhase = ''
              # Create the terminfo directory inside the $out path
              mkdir -p $out/share/terminfo
              
              # Set this env var so 'tic' (called by 'make install')
              # writes to the correct directory instead of $HOME
              export TERMINFO=$out/share/terminfo
              
              # Now run the original install command
              make install PREFIX=$out
            '';
          };
          
          default = self.packages.${system}.st;
        });
      
      defaultPackage = forAllSystems (system: self.packages.${system}.default);
    };
}
