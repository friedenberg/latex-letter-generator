# Build a reproducible latex document based on 
# https://github.com/Leixb/latex-template

{ pkgs
# Document source
, src ? ./.

# Name of the final pdf file
, name ? "document.pdf"

# texlive packages needed to build the document
# you can also include other packages as a list.
, texlive ? pkgs.texlive.combined.scheme-basic

# Add system fonts
# you can specify one font directly with: pkgs.fira-code
# of join multiple fonts using symlinJoin:
#   pkgs.symlinkJoin { name = "fonts"; paths = with pkgs; [ fira-code souce-code-pro ]; }
, fonts ? null
}:

let 
  lib = pkgs.lib;
in

pkgs.stdenvNoCC.mkDerivation rec {
  inherit src name;

  buildInputs = [ texlive pkgs.git ];

  TEXMFHOME = "./cache";
  TEXMFVAR = "./cache/var";

  OSFONTDIR = lib.optionalString (fonts != null) "${fonts}/share/fonts";

  buildPhase = ''
  runHook preBuild

	pdflatex \
		-halt-on-error \
		-interaction=batchmode \
    letter.latex

  runHook postBuild
  '';

  installPhase = ''
  runHook preInstall

  install -m644 -D *.pdf $out/${name}

  runHook postInstall
  '';
}
