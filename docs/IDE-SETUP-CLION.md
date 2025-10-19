# 🛠️ Configuración de CLion para Multi Ninja Espacial

> Guía completa para configurar CLion como IDE del proyecto

**Última actualización**: 2025-10-18
**CLion versión recomendada**: 2024.1+

---

## 📋 Tabla de Contenidos

1. [¿Por qué CLion?](#por-qué-clion)
2. [Instalación de CLion](#instalación-de-clion)
3. [Configuración Inicial](#configuración-inicial)
4. [Configuración de Conan](#configuración-de-conan)
5. [Configuración de CMake](#configuración-de-cmake)
6. [Debugging](#debugging)
7. [Atajos de Teclado Útiles](#atajos-de-teclado-útiles)
8. [Plugins Recomendados](#plugins-recomendados)

---

## 🎯 ¿Por qué CLion?

CLion es el IDE **recomendado** para este proyecto por:

✅ **CMake nativo**: Integración perfecta con CMake
✅ **Conan support**: Plugin oficial de Conan
✅ **Refactoring avanzado**: Renombrado seguro, extract method, etc.
✅ **Debugger potente**: Integración con GDB/LLDB
✅ **Code analysis**: Inspecciones de código en tiempo real
✅ **C++20 support**: Soporte completo para C++20
✅ **Multiplataforma**: Windows, macOS, Linux

### Alternativas

Si no puedes usar CLion:
- **Visual Studio** (Windows): Excelente debugger
- **Visual Studio Code**: Ligero pero requiere más configuración
- **Vim/Neovim**: Con plugins ccls/clangd

---

## 💾 Instalación de CLion

### Opción 1: Licencia Estudiante (Gratis)

Si eres estudiante, obtén CLion gratis:

1. Ir a https://www.jetbrains.com/student/
2. Registrarse con email institucional (.edu)
3. Descargar CLion desde JetBrains Toolbox

### Opción 2: Trial de 30 días

1. Descargar desde https://www.jetbrains.com/clion/
2. Instalar y usar trial gratuito

### Opción 3: Licencia Comercial

Si es para empresa, comprar licencia en https://www.jetbrains.com/clion/buy/

---

## ⚙️ Configuración Inicial

### 1. Abrir el Proyecto

```bash
# Opción A: Desde terminal
cd ~/Desktop/Proyectos/C++/multininjaespacial
clion .

# Opción B: Desde CLion
File → Open → Seleccionar carpeta multininjaespacial
```

CLion detectará automáticamente `CMakeLists.txt` y cargará el proyecto.

---

### 2. Configurar Toolchain

**macOS**:
```
CLion → Preferences → Build, Execution, Deployment → Toolchains

Toolchain: Default
CMake: /opt/homebrew/bin/cmake (o /usr/local/bin/cmake)
Make: /usr/bin/make
C Compiler: /usr/bin/clang
C++ Compiler: /usr/bin/clang++
Debugger: LLDB (/usr/bin/lldb)
```

**Linux**:
```
CLion → Settings → Build, Execution, Deployment → Toolchains

Toolchain: Default
CMake: /usr/bin/cmake
Make: /usr/bin/make
C Compiler: /usr/bin/gcc
C++ Compiler: /usr/bin/g++
Debugger: GDB (/usr/bin/gdb)
```

**Windows**:
```
CLion → Settings → Build, Execution, Deployment → Toolchains

Toolchain: Visual Studio
CMake: (bundled CLion cmake)
C Compiler: MSVC cl.exe
C++ Compiler: MSVC cl.exe
Debugger: Visual Studio
```

---

## 🐍 Configuración de Conan

### Instalar Plugin de Conan

1. `CLion → Preferences → Plugins`
2. Buscar "Conan"
3. Instalar "Conan Plugin" oficial
4. Reiniciar CLion

### Configurar Conan en CMake

1. `CLion → Preferences → Build, Execution, Deployment → CMake`
2. En "CMake options", añadir:
   ```
   -DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=conan_provider.cmake
   ```

3. O alternativamente, configurar "Before build" step:
   ```bash
   conan install . --build=missing
   ```

---

## 🔧 Configuración de CMake

### Profiles de Build

CLion crea perfiles Debug y Release automáticamente.

**Personalizar perfiles**:

`CLion → Preferences → Build, Execution, Deployment → CMake`

#### Profile: Debug

```
Name: Debug
Build type: Debug
CMake options:
  -DCMAKE_BUILD_TYPE=Debug
  -DBUILD_TESTS=ON
  -DENABLE_PROFILING=ON
Build directory: cmake-build-debug
```

#### Profile: Release

```
Name: Release
Build type: Release
CMake options:
  -DCMAKE_BUILD_TYPE=Release
  -DBUILD_TESTS=OFF
Build directory: cmake-build-release
```

#### Profile: RelWithDebInfo (Recomendado para profiling)

```
Name: RelWithDebInfo
Build type: RelWithDebInfo
CMake options:
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
  -DENABLE_PROFILING=ON
Build directory: cmake-build-relwithdebinfo
```

---

### Reload CMake

Cada vez que cambies `CMakeLists.txt`:

```
Tools → CMake → Reload CMake Project
O presiona: Ctrl+Shift+O (macOS: Cmd+Shift+O)
```

---

## 🐛 Debugging

### Configurar Debugging

1. **Run → Edit Configurations**
2. Añadir nueva configuración:
   - Type: CMake Application
   - Target: multininjaespacial
   - Executable: multininjaespacial
   - Working directory: `$ProjectFileDir$/build`

### Breakpoints

- Click en la línea para añadir breakpoint (o `Cmd+F8`)
- Click derecho en breakpoint → Condition para breakpoint condicional

### Ejecutar con Debugger

```
Run → Debug 'multininjaespacial'
O presiona: Ctrl+D (macOS: Cmd+D)
```

### Watches y Evaluación

Durante debugging:
- `Evaluate Expression`: `Alt+F8` (macOS: `Cmd+Alt+F8`)
- Añadir watch: Click derecho en variable → Add to Watches

### Debugger avanzado

**Pretty printers** (para glm, EnTT):

Crear `.gdbinit` o `.lldbinit` en home:

```bash
# ~/.lldbinit (macOS)
command script import ~/lldb_scripts/glm_pretty_printer.py

# ~/.gdbinit (Linux)
python
import sys
sys.path.insert(0, '/path/to/gdb-printers')
from glm import register_glm_printers
register_glm_printers(None)
end
```

---

## ⌨️ Atajos de Teclado Útiles

### Navegación

| Acción | macOS | Windows/Linux |
|--------|-------|---------------|
| Ir a definición | `Cmd+B` | `Ctrl+B` |
| Ir a declaración | `Cmd+Alt+B` | `Ctrl+Alt+B` |
| Buscar archivo | `Cmd+Shift+O` | `Ctrl+Shift+N` |
| Buscar símbolo | `Cmd+Alt+O` | `Ctrl+Alt+Shift+N` |
| Navegación atrás | `Cmd+[` | `Ctrl+Alt+Left` |
| Navegación adelante | `Cmd+]` | `Ctrl+Alt+Right` |

### Edición

| Acción | macOS | Windows/Linux |
|--------|-------|---------------|
| Auto-complete | `Ctrl+Space` | `Ctrl+Space` |
| Formatear código | `Cmd+Alt+L` | `Ctrl+Alt+L` |
| Refactor/Rename | `Shift+F6` | `Shift+F6` |
| Extract method | `Cmd+Alt+M` | `Ctrl+Alt+M` |
| Generate code | `Cmd+N` | `Alt+Insert` |

### Build y Run

| Acción | macOS | Windows/Linux |
|--------|-------|---------------|
| Build | `Cmd+F9` | `Ctrl+F9` |
| Run | `Ctrl+R` | `Shift+F10` |
| Debug | `Ctrl+D` | `Shift+F9` |
| Stop | `Cmd+F2` | `Ctrl+F2` |

### Debugging

| Acción | macOS | Windows/Linux |
|--------|-------|---------------|
| Toggle breakpoint | `Cmd+F8` | `Ctrl+F8` |
| Step over | `F8` | `F8` |
| Step into | `F7` | `F7` |
| Step out | `Shift+F8` | `Shift+F8` |
| Resume | `Cmd+Alt+R` | `F9` |
| Evaluate | `Cmd+Alt+F8` | `Alt+F8` |

---

## 🔌 Plugins Recomendados

### Esenciales

1. **Conan Plugin** (ya instalado arriba)
   - Integración con Conan package manager

2. **.ignore**
   - Syntax highlighting para .gitignore

3. **Markdown**
   - Preview de archivos .md (ya incluido)

### Opcionales

4. **GitHub Copilot** (si tienes licencia)
   - AI code completion

5. **String Manipulation**
   - Transformaciones de texto útiles

6. **Rainbow Brackets**
   - Colorea paréntesis anidados

7. **Key Promoter X**
   - Aprende shortcuts mostrándolos cuando usas mouse

### Instalación de Plugins

```
CLion → Preferences → Plugins → Marketplace
Buscar plugin → Install → Restart IDE
```

---

## 🎨 Personalización de Código

### Code Style

`CLion → Preferences → Editor → Code Style → C/C++`

**Recomendado para este proyecto**:

```
Scheme: Project
Indentation: 4 spaces
Namespace indentation: None
Function parameters: Align when multiline
```

### File Templates

Crear template para nuevos archivos .cpp/.hpp:

`CLion → Preferences → Editor → File and Code Templates`

**Template Header (.hpp)**:

```cpp
// ============================================================================
// ${NAME} - [Descripción]
// ============================================================================
// [Propósito del archivo]
// ============================================================================

#pragma once

namespace MultiNinjaEspacial {

class ${NAME} {
public:
    ${NAME}();
    ~${NAME}();

private:

};

} // namespace MultiNinjaEspacial
```

---

## 🧪 Configurar Tests

### Ejecutar Tests desde CLion

1. `Run → Edit Configurations`
2. Añadir nueva configuración:
   - Type: CTest
   - Target: All CTest
   - Test: All tests

3. Ejecutar con `Ctrl+R` (o `Cmd+R` en macOS)

### Ver Coverage

1. `Run → Run 'All CTest' with Coverage`
2. Ver reporte en `Run → Show Coverage Data`

---

## 🔍 Static Analysis

### Habilitar CLion Code Inspections

`CLion → Preferences → Editor → Inspections → C/C++`

Habilitar:
- [ ] Clang-Tidy
- [ ] Missing includes
- [ ] Unused code
- [ ] Memory leaks

### Ejecutar Análisis

```
Code → Inspect Code
Seleccionar: Whole project
```

---

## 📊 Profiling

### Integración con Valgrind (Linux)

```
Run → Profile 'multininjaespacial' with Valgrind
```

### Integración con Instruments (macOS)

```
Run → Profile 'multininjaespacial'
Seleccionar: Time Profiler
```

---

## 🚀 Quick Start Checklist

Después de instalar CLion:

- [ ] Abrir proyecto (`File → Open`)
- [ ] Instalar plugin Conan
- [ ] Configurar Toolchain (Preferences → Toolchains)
- [ ] Reload CMake (`Tools → CMake → Reload`)
- [ ] Build proyecto (`Cmd+F9` / `Ctrl+F9`)
- [ ] Run ejecutable (`Ctrl+R` / `Shift+F10`)
- [ ] Poner breakpoint en `main.cpp` línea 100
- [ ] Debug (`Ctrl+D` / `Shift+F9`)
- [ ] Verificar que funciona

---

## 🆘 Troubleshooting

### "CMake Error: Could not find Conan"

**Solución**:
```bash
# Instalar Conan
pip install conan

# Verificar instalación
which conan
conan --version

# Añadir al PATH en CLion
Preferences → Toolchains → Environment Variables
PATH = /usr/local/bin:$PATH
```

---

### "Cannot find -lSDL2"

**Solución**:
```bash
# En terminal, dentro del proyecto
cd build
conan install .. --build=missing
cmake ..

# En CLion: Reload CMake
```

---

### "Debugger doesn't stop at breakpoints"

**Solución**:
1. Verificar que estás en modo Debug (no Release)
2. `Run → Edit Configurations → Build Type: Debug`
3. Rebuild proyecto completo

---

### "Slow IDE / Indexing stuck"

**Solución**:
```
File → Invalidate Caches / Restart
Seleccionar: Invalidate and Restart
```

---

## 📚 Recursos Adicionales

- [CLion Documentation](https://www.jetbrains.com/help/clion/)
- [CMake Tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/)
- [Conan Documentation](https://docs.conan.io/)
- [LLDB Cheat Sheet](https://lldb.llvm.org/use/map.html)

---

## 💡 Tips Pro

1. **Usa Live Templates**: `Settings → Editor → Live Templates`
   - `for` → Tab = auto-complete for loop
   - `if` → Tab = auto-complete if statement

2. **Scratch Files** para experimentar: `Cmd+Shift+N` → Scratch File

3. **TODO comments**: CLion detecta `// TODO: ` y los lista en `View → Tool Windows → TODO`

4. **Multiple Cursors**: `Alt+Shift+Click` para añadir cursor

5. **Recent Files**: `Cmd+E` (macOS) / `Ctrl+E` (Win/Linux)

---

**¡Listo!** Ahora tienes CLion configurado perfectamente para desarrollar Multi Ninja Espacial.

Si tienes problemas, revisa la sección de [Troubleshooting](#troubleshooting) o consulta la [documentación oficial de CLion](https://www.jetbrains.com/help/clion/).

---

**Última actualización**: 2025-10-18
**Mantenedor**: Carlos Garcia
