# Raylib OCaml Demo

Um template/projeto estruturado para desenvolvimento de jogos e simulações 2D em **OCaml** utilizando os bindings para a biblioteca **[Raylib](https://www.raylib.com/)** e gerenciamento de build com **Dune**.

---

## 🏛️ Arquitetura do Projeto

O código-fonte é organizado de forma modular dentro do diretório `lib/`, separando dados, estado, física e renderização (seguindo um fluxo funcional / tipo Elm Architecture / Game Loop desacoplado):

```text
raylib-ocaml-project/
├── bin/
│   ├── dune
│   └── main.ml           # Ponto de entrada (inicialização da janela e loop principal)
├── lib/
│   ├── config.ml         # Configurações globais (resolução, FPS, constantes)
│   ├── dune              # Definição da biblioteca interna
│   ├── input.ml          # Captura e mapeamento de entradas do teclado/mouse
│   ├── physics.ml        # Cálculos de colisão, vetores e física
│   ├── types.ml          # Modelagem de dados, tipos de estado do jogo e entidades
│   ├── update.ml         # Lógica de transição de estado por frame (tick)
│   └── view.ml           # Renderização e desenho na tela via Raylib
├── test/
│   ├── dune
│   └── test_raylib_ocaml_demo.ml # Testes unitários
├── dune-project          # Metadados do projeto Dune
└── raylib_ocaml_demo.opam # Especificação de dependências do OPAM

```

---

## 🛠️ Pré-requisitos

Certifique-se de possuir instalado:

* **OCaml** (>= 4.14 ou 5.x)
* **OPAM** (OCaml Package Manager)
* **Dune** (>= 3.0)
* Dependências de sistema para o Raylib (ex: `libgl1-mesa-dev`, `libx11-dev`, `libxcursor-dev`, `libxi-dev`, etc., caso esteja no Linux)

---

## 📦 Instalação das Dependências

Crie ou utilize um switch OPAM local/global e instale as dependências declaradas no `.opam`:

```bash
# Opcional: criar um switch local
opam switch create . 5.1.1 --deps-only -y

# Instalar dependências e ferramentas de desenvolvimento
opam install . --deps-only --with-test -y
opam install ocaml-lsp-server ocamlformat -y

```

> **Nota:** Certifique-se de que a biblioteca `raylib` para OCaml foi instalada corretamente (`opam install raylib`).

---

## 🚀 Como Executar

Para compilar e executar o projeto:

```bash
dune exec bin/main.exe

```

Durante o desenvolvimento com recarregamento automático (watch mode):

```bash
dune exec bin/main.exe -w

```

---

## 🧪 Testes e Formatação

Para rodar os testes unitários:

```bash
dune runtest

```

Para formatar o código com o `ocamlformat`:

```bash
dune fmt

```

---

## 📄 Licença

Uso pessoal / educacional. Todos os direitos reservados (a definir).
