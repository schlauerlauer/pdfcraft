{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          pdfcraft-cli = pkgs.rustPlatform.buildRustPackage {
            pname = "pdfcraft-cli";
            version = "0.7.1";
            src = self;
            cargoLock = {
              lockFile = ./Cargo.lock;
              outputHashes."craft-print-0.1.0" = "sha256-J/EJJeDDWXc+QQtpUqnAKKA4piOdPRbH3uG1ms2BRgY=";
              outputHashes."craft-ui-0.1.0" = "sha256-VhLeT7VLdZAIz6gR9PdFI34IJxHsGF8NE0uzFCN2vIU=";
            };
            cargoBuildFlags = [ "-p" "pdfcraft-cli" ];
            doCheck = false;
            installPhase = ''
              runHook preInstall
              install -Dm755 target/${pkgs.stdenv.hostPlatform.rust.rustcTarget}/release/pdfcraft-cli $out/bin/pdfcraft-cli
              runHook postInstall
            '';
          };
          default = self.packages.${system}.pdfcraft-cli;
        });

    };
}
