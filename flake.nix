{
  description = "Minimal DuckDB flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          name = "duckdb-shell";
          packages = [ pkgs.duckdb ];
        };
        packages = {
          default = pkgs.duckdb;
          duckdb = pkgs.duckdb;
        };
      }
    );
}