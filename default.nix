with import <nixpkgs> {};

stdenv.mkDerivation {
    name = "elixir-gitlab";

    buildInputs = [
        elixir_1_8
    ];
}
