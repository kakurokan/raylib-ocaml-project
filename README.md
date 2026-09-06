# Raylib OCaml Demo

A simple graphics and movement demonstration using the [Raylib bindings for OCaml](https://github.com/tjammer/raylib-ocaml) and the [Dune](https://dune.build/) build system.

## 📋 Prerequisites

Ensure you have a working OCaml development environment with the `opam` package manager installed.

### 1. System Dependencies

Because Raylib relies on native windowing and graphics libraries (OpenGL/X11/Wayland), install the required system packages:

**Ubuntu / Pop!_OS / Debian:**
```bash
sudo apt update
sudo apt install libgl1-mesa-dev libglu1-mesa-dev xorg-dev libwayland-dev

```

**Fedora:**

```bash
sudo dnf install mesa-libGL-devel libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel wayland-devel

```

**Arch Linux:**

```bash
sudo pacman -S mesa libx11 libxrandr libxinerama libxcursor libxi wayland

```

**macOS (Homebrew):**

```bash
brew install raylib

```

---

### 2. OCaml Dependencies

Install the `raylib` binding and the `dune` build tool via OPAM:

```bash
opam update
opam install raylib dune

```

*(Optional) Ensure your current OPAM switch environment variables are set:*

```bash
eval $(opam env)

```

---

## 🚀 Getting Started

Clone the repository and build/run the application with Dune:

```bash
# Clone the repository
git clone [https://github.com/YOUR_USERNAME/raylib-ocaml-demo.git](https://github.com/YOUR_USERNAME/raylib-ocaml-demo.git)
cd raylib-ocaml-demo

# Build and execute
dune exec ./bin/main.exe

```

---

## 🛠️ Useful Commands

* **Build only:**
```bash
dune build

```


* **Clean build artifacts (`_build/`):**
```bash
dune clean

```


* **Watch mode (rebuilds automatically on save):**
```bash
dune build -w

```



---

## 🎮 Controls

| Key / Input | Action |
| --- | --- |
| `W`, `A`, `S`, `D` / Arrow Keys | Move player |
| `R` | Reset position |
| `Mouse Scroll` | Adjust target FPS |
| `ESC` / Close Window | Quit application |

---

## 📄 License

Distributed under the [MIT](https://www.google.com/search?q=LICENSE) License.
