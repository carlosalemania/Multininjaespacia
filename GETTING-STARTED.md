# 🚀 Getting Started - Multi Ninja Espacial

> Guía de inicio rápido para compilar y ejecutar el proyecto

**Última actualización**: 2025-10-18
**Versión**: 0.1.0 (MVP - Fase 1)

---

## ✅ Estado del Proyecto

**Implementación completada**:

- ✅ Arquitectura Hexagonal + ECS definida
- ✅ Estructura de carpetas completa
- ✅ CMake configurado con Conan
- ✅ Core ECS con EnTT (Registry, Components, Systems)
- ✅ Renderer OpenGL 3.3 básico
- ✅ Game Loop con fixed timestep
- ✅ Ventana SDL2 con contexto OpenGL
- ✅ Sistema de movimiento funcional
- ✅ Tests unitarios básicos
- ✅ Documentación exhaustiva

---

## 📋 Prerequisitos

### macOS

```bash
# Instalar Homebrew si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar dependencias
brew install cmake conan

# Verificar instalación
cmake --version   # Debe ser 3.20+
conan --version   # Debe ser 2.x
```

### Linux (Ubuntu/Debian)

```bash
# Actualizar repositorios
sudo apt update

# Instalar dependencias
sudo apt install -y cmake g++ libgl1-mesa-dev python3-pip

# Instalar Conan
pip3 install conan

# Verificar instalación
cmake --version
conan --version
g++ --version     # Debe ser GCC 10+
```

### Windows

1. **Instalar Visual Studio 2022**:
   - Descargar desde https://visualstudio.microsoft.com/
   - Seleccionar "Desktop development with C++"

2. **Instalar CMake**:
   - Descargar desde https://cmake.org/download/
   - Añadir al PATH durante instalación

3. **Instalar Conan**:
   ```cmd
   pip install conan
   ```

---

## 🔨 Compilación

### Paso 1: Navegar al proyecto

```bash
cd ~/Desktop/Proyectos/C++/multininjaespacial
```

### Paso 2: Crear directorio de build

```bash
mkdir build
cd build
```

### Paso 3: Instalar dependencias con Conan

```bash
conan install .. --build=missing
```

**Nota**: La primera vez tardará varios minutos porque descarga y compila:
- SDL2
- GLEW
- GLM
- EnTT
- ENet
- spdlog
- Catch2

**Si aparece error "Unknown compiler"**, configura Conan:

```bash
conan profile detect --force
```

### Paso 4: Configurar con CMake

```bash
cmake ..
```

**Opciones adicionales**:

```bash
# Build Release (optimizado)
cmake -DCMAKE_BUILD_TYPE=Release ..

# Build con tests
cmake -DBUILD_TESTS=ON ..

# Build con servidor dedicado
cmake -DBUILD_SERVER=ON ..

# Build todo
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=ON -DBUILD_SERVER=ON ..
```

### Paso 5: Compilar

```bash
# macOS/Linux
cmake --build .

# O con make directo
make -j8  # -j8 usa 8 cores

# Windows
cmake --build . --config Release
```

---

## ▶️ Ejecutar

### Ejecutar el juego

```bash
# Desde build/
./multininjaespacial
```

**Esperado**:
- Ventana 800x600 con título "Multi Ninja Espacial - v0.1.0 MVP"
- Fondo azul oscuro
- Consola mostrando logs (FPS, sistema inicializado, etc.)
- Presiona **ESC** para cerrar

### Ejecutar tests

```bash
# Tests unitarios
./unit_tests

# Tests de integración
./integration_tests

# Todos los tests con CTest
ctest --verbose
```

---

## 🐛 Troubleshooting

### Error: "Could not find SDL2"

**Solución**:
```bash
# Borrar build y reinstalar
cd ..
rm -rf build
mkdir build && cd build
conan install .. --build=missing
cmake ..
cmake --build .
```

### Error: "GLEW init failed"

**Problema**: Drivers de OpenGL desactualizados

**Solución macOS**:
```bash
# Actualizar macOS a última versión
# OpenGL viene con el sistema
```

**Solución Linux**:
```bash
# Actualizar drivers de GPU
sudo apt install mesa-utils
glxinfo | grep "OpenGL version"  # Debe ser 3.3+
```

**Solución Windows**:
- Actualizar drivers de NVIDIA/AMD desde su web oficial

### Error: "entt/entt.hpp not found"

**Solución**:
```bash
# Conan no instaló correctamente
cd build
rm -rf *
conan install .. --build=missing --update
cmake ..
```

### Warning: "clang-tidy not found"

**Ignorar**: Es opcional, solo para análisis estático

Para instalarlo:
```bash
brew install llvm  # macOS
sudo apt install clang-tidy  # Linux
```

---

## 📊 Verificar que funciona

### Checklist

Ejecuta `./multininjaespacial` y verifica:

- [ ] Ventana se abre correctamente
- [ ] No hay errores en consola
- [ ] FPS muestra ~60 (o el de tu monitor si VSync está activo)
- [ ] Logs muestran "OpenGL Version: 3.3.x" o superior
- [ ] ESC cierra la aplicación limpiamente

### Logs esperados

```
[HH:MM:SS] [info] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[HH:MM:SS] [info]        MULTI NINJA ESPACIAL - v0.1.0
[HH:MM:SS] [info] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[HH:MM:SS] [info] Registry inicializado
[HH:MM:SS] [info] GameWindow creado
[HH:MM:SS] [info] Creando ventana: Multi Ninja Espacial - v0.1.0 MVP (800x600)
[HH:MM:SS] [info] OpenGL Version: 3.3.x
[HH:MM:SS] [info] Renderer: OpenGL 3.3.x
[HH:MM:SS] [info] Creando entidades de prueba...
[HH:MM:SS] [info] GameLoop inicializado
[HH:MM:SS] [info] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[HH:MM:SS] [info] Iniciando Game Loop
[HH:MM:SS] [info] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🎯 Próximos Pasos

### Fase 1.1 (Siguiente sprint - 1 semana)

**Tareas pendientes**:

1. **Implementar carga de texturas real** (actualmente usa textura dummy blanca)
   - Añadir stb_image a Conan
   - Implementar TextureManager
   - Cargar sprites de prueba

2. **Implementar RenderSystem completo**
   - Ordenar entidades por layer
   - Batch rendering
   - Frustum culling básico

3. **Implementar InputManager**
   - Mapeo de teclas
   - Estado de input (KeyDown, KeyPressed, KeyUp)
   - Soporte para gamepad básico

4. **Añadir CollisionSystem básico**
   - AABB collision detection
   - Componente Collider
   - Resolución de colisiones

5. **Gameplay básico**
   - Controlar jugador con teclado
   - Enemigos que se mueven
   - Colisiones funcionales

### Fase 2 (3 semanas)

- Networking con ENet
- Multijugador 2 jugadores
- Servidor dedicado

### Abrir en CLion

```bash
# Desde terminal
cd ~/Desktop/Proyectos/C++/multininjaespacial
clion .

# O desde CLion:
# File → Open → Seleccionar carpeta multininjaespacial
```

Ver [IDE-SETUP-CLION.md](docs/IDE-SETUP-CLION.md) para configuración completa.

---

## 📚 Documentación

- **[README.md](README.md)**: Overview del proyecto
- **[.spec/project.md](.spec/project.md)**: Especificación técnica completa
- **[docs/IDE-SETUP-CLION.md](docs/IDE-SETUP-CLION.md)**: Configuración de CLion
- **[.spec/adr/](.spec/adr/)**: Decisiones arquitectónicas (ADRs)

---

## 🤝 Contribuir

Este proyecto usa **modo ROBUST** (estándares enterprise):

### Antes de commit:

```bash
# Compilar sin warnings
cmake --build . 2>&1 | grep warning

# Ejecutar tests
ctest

# Formatear código (si tienes clang-format)
clang-format -i src/**/*.cpp src/**/*.hpp
```

### Convenciones:

- **Comentarios**: En español, explicando el "por qué"
- **Nombres**: Descriptivos, camelCase para funciones, PascalCase para clases
- **Tests**: >90% coverage en lógica de negocio
- **ADRs**: Documentar decisiones arquitectónicas importantes

---

## ❓ Ayuda

### ¿Algo no funciona?

1. **Revisa [Troubleshooting](#troubleshooting)**
2. **Verifica logs** en consola
3. **Limpia build** y recompila:
   ```bash
   rm -rf build
   mkdir build && cd build
   conan install .. --build=missing
   cmake ..
   cmake --build .
   ```

### ¿Quieres añadir una feature?

1. Lee [.spec/project.md](.spec/project.md) para entender arquitectura
2. Verifica que la feature esté en el roadmap de la fase actual
3. Sigue el patrón Hexagonal:
   - **Core**: Lógica de negocio (ECS)
   - **Infrastructure**: Implementaciones (OpenGL, SDL, etc.)
   - **Application**: Casos de uso
   - **Presentation**: Entry points

---

## 🎉 ¡Felicidades!

Si llegaste hasta aquí y el juego compila, **¡lo lograste!**

Tienes un proyecto C++20 moderno con:
- ✅ Arquitectura Hexagonal
- ✅ ECS con EnTT
- ✅ Renderer OpenGL
- ✅ Game Loop profesional
- ✅ Tests unitarios
- ✅ Documentación exhaustiva

**Siguiente paso**: Implementa Fase 1.1 (input + texturas + gameplay)

---

**¿Dudas?** Revisa la [documentación completa](.spec/project.md) o consulta los ADRs en `.spec/adr/`.

**¡Happy coding!** 🚀👾
