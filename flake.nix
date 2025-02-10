{
  description = "Michael's Commonly Used Development Shells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    pre-commit-hooks
  }: {
    checks = {
        x86_64-linux.pre-commit-check = pre-commit-hooks.lib.x86_64-linux.run {
          src = ./.;
          hooks = {
            deadnix.enable = true;
            detect-private-keys.enable = true;
            typos.enable = true;
            flake-checker.enable = true;
          };
        };
      };

    devShells.x86_64-linux.nixos = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
    pkgs.mkShell {
      inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;
      buildInputs = with pkgs; [
        self.checks.x86_64-linux.pre-commit-check.enabledPackages
        agenix.packages.x86_64-linux.default
        trufflehog
        alejandra
        nil
        git
        tig
        nixd
      ];
    };
  };
}
