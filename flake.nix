{
  description = "Build LaTeX document with minted";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  {
    templates.document = {
      path = ./.;
      description = "LaTeX document with minted support";
    };

    lib.latexmk = import ./build-document.nix;

    defaultTemplate = self.templates.document;
  } // flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };

  latex-packages = with pkgs; [
    (texlive.combine {
     inherit (texlive)
     scheme-basic
     ragged2e
     ;
     })
  which
  ];

  dev-packages = with pkgs; [
    texlab
      zathura
      wmctrl
  ];
  in
    rec {
      devShell = pkgs.mkShell {
        buildInputs = [ latex-packages dev-packages ];
      };

      packages = flake-utils.lib.flattenTree {
        document = import ./build-document.nix {
          inherit pkgs;
          texlive = latex-packages;
          SOURCE_DATE_EPOCH = toString self.lastModified;
        };
      };

      defaultPackage = packages.document;
    }
  );
}
