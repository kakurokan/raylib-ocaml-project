(lang dune 3.14)

(name raylib_ocaml_demo)

(generate_opam_files true)

(source
 (github Kakurokan/meu_jogo))

(authors "Kakurokan")
(maintainers "Kakurokan")
(license MIT)

(package
 (name raylib_ocaml_demo)
 (synopsis "Um jogo 2D feito em OCaml usando Raylib")
 (description
  "Jogo arcade de estilingue 2D com simulador de inercia e fisica implementado usando raylib-ocaml.")
 (depends
  (ocaml (>= 4.14.0))
  (dune (>= 3.14))
  (raylib (>= 0.0.1))
  odoc))