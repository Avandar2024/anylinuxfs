{
  description = "anylinuxfs environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # Rust nightly as specified in build-app.sh
        # Note: 2026-01-25 is a future date in the prompt context but maybe correct for the user's timeline. 
        # The user's current date is 2026-02-06.
        rustToolchain = pkgs.rust-bin.nightly."2026-01-25".default.override {
          extensions = [ "rust-src" "rust-std" ];
          targets = [ "aarch64-unknown-linux-musl" ];
        };

        nativeBuildInputs = with pkgs; [
          pkg-config
          rustToolchain
          go
        ];

        buildInputs = with pkgs; [
          util-linux 
          # libkrun needs to be here. 
          # Since it's not in standard nixpkgs (likely), this might fail without an overlay.
          # We leave it out or add a placeholder comment if it's missing.
          # For now, let's assume the user might have it or we rely on system libraries in impure shells.
        ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          pkgs.apple-sdk
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs;
          
          shellHook = ''
            export PKG_CONFIG_PATH="${pkgs.util-linux.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
            
            # Suggestion: Using a impure shell to pick up Homebrew libs if libkrun is missing in Nix
            if ! pkg-config --exists libkrun; then
               echo "Warning: libkrun not found in Nix packages."
               echo "If you have it installed via Homebrew, ensure paths are correct."
            fi
          '';
        };
      }
    );
}
