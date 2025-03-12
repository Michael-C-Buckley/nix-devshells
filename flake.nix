{
  description = "Michael's Commonly Used Development Shells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks
  }: let

    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };

    commonNixBuildInputs = with pkgs; [
      self.checks.x86_64-linux.pre-commit-check.enabledPackages
      ragenix
      trufflehog
      alejandra
      nil
      git
      tig
      nixd
      direnv
    ];

  in {
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

    devShells.x86_64-linux = {
      default = self.devShells.x86_64-linux.nixos;
      nixos = pkgs.mkShell {
        inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;
        buildInputs = commonNixBuildInputs;
        env = {
          TRUFFLEHOG_NO_UPDATE = "1";
        };
      };
      nixosServers = pkgs.mkShell {
        inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;
        buildInputs = with pkgs; [
          ansible
          ansible-lint
          ansible-language-server
          molecule    # Ansible testing framework
        ] ++ commonNixBuildInputs;
      };
    };
  };
}
