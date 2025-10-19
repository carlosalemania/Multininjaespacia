# 🎮 Multi Ninja Espacial - Especificación del Proyecto

**Versión**: 0.1.0 (MVP - Fase 1)
**Fecha de creación**: 2025-10-18
**Modo Dev Kit**: ROBUST (Enterprise)
**Arquitectura**: Hexagonal + ECS (Entity-Component-System)

---

## 📋 Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Arquitectura](#arquitectura)
3. [Stack Tecnológico](#stack-tecnológico)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Componentes Principales](#componentes-principales)
6. [Roadmap de Desarrollo](#roadmap-de-desarrollo)
7. [Compilación y Ejecución](#compilación-y-ejecución)
8. [Testing](#testing)
9. [ADRs (Decisiones Arquitectónicas)](#adrs)

---

## 🎯 Visión General

### ¿Qué es Multi Ninja Espacial?

Juego multiplataforma (Windows, macOS, Linux) de acción 2D con las siguientes características:

- **Género**: Acción espacial 2D, estilo arcade
- **Plataformas**: Windows, macOS, Linux (multiplataforma gracias a C++ + SDL2)
- **Multijugador**: Red P2P con servidor dedicado opcional
- **Optimizado para Streaming**: Bajo uso de CPU/GPU, 60 FPS estables
- **Escalable**: Desde prototipo simple hasta juego complejo con miles de entidades

### Características Clave

✅ **Implementadas en MVP (Fase 1)**:
- Game loop con fixed timestep
- Sistema ECS (Entity-Component-System) con EnTT
- Renderer OpenGL 3.3 básico
- Ventana y contexto OpenGL con SDL2
- Sistema de movimiento 2D
- Logging con spdlog

🚧 **Planeadas (Fases 2-5)**:
- Multijugador con ENet (Fase 2)
- Optimización para streaming (Fase 3)
- Renderer Vulkan (Fase 4)
- Escalado masivo con optimizaciones (Fase 5)

---

## 🏗️ Arquitectura

### Patrón: Hexagonal (Ports & Adapters)

El proyecto usa **Arquitectura Hexagonal** para separar lógica de negocio de infraestructura.

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Entry Points: main.cpp, GameWindow, GameLoop)             │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────────────┐
│                   APPLICATION LAYER                          │
│  (Use Cases: StartGame, UpdateGame, ConnectToServer)        │
│  Orquesta la lógica del juego                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
┌────────┴─────────┐       ┌─────────┴──────────┐
│   CORE (Domain)  │       │  INFRASTRUCTURE    │
│                  │       │    (Adapters)      │
│  - ECS Registry  │       │  - OpenGLRenderer  │
│  - Components    │       │  - VulkanRenderer  │
│  - Systems       │       │  - ENetAdapter     │
│  - Entities      │       │  - SDLInput        │
│                  │       │  - AudioManager    │
└──────────────────┘       └────────────────────┘
```

### Entity-Component-System (ECS)

Usamos **EnTT**, la biblioteca ECS más rápida para C++.

**Beneficios**:
- Composición sobre herencia
- Cache-friendly (datos contiguos en memoria)
- Escalabilidad: millones de entidades posibles
- Separación total datos/lógica

**Ejemplo**:

```cpp
// Crear entidad
auto player = registry.create();

// Añadir componentes (datos puros)
registry.emplace<Transform>(player, glm::vec2{100, 200});
registry.emplace<Velocity>(player, glm::vec2{50, 0});
registry.emplace<Renderable>(player, "player_sprite");

// Sistema procesa componentes (lógica)
auto view = registry.view<Transform, Velocity>();
for (auto entity : view) {
    auto& transform = view.get<Transform>(entity);
    auto& velocity = view.get<Velocity>(entity);
    transform.position += velocity.linear * deltaTime;
}
```

---

## 🛠️ Stack Tecnológico

### Lenguaje y Estándar

- **C++20**: Características modernas (concepts, ranges, coroutines)
- **CMake 3.20+**: Sistema de build multiplataforma
- **Conan 2.x**: Gestor de paquetes

### Bibliotecas Principales

| Biblioteca | Versión | Propósito | Licencia |
|-----------|---------|-----------|----------|
| **EnTT** | 3.12.2 | Entity-Component-System | MIT |
| **SDL2** | 2.28.5 | Ventana, input, contexto OpenGL | zlib |
| **GLEW** | 2.2.0 | Carga de extensiones OpenGL | BSD |
| **GLM** | 0.9.9.8 | Matemáticas (vectores, matrices) | MIT |
| **ENet** | 1.3.17 | Networking UDP confiable | MIT |
| **spdlog** | 1.12.0 | Logging asíncrono | MIT |
| **Catch2** | 3.4.0 | Testing framework | BSL-1.0 |

### APIs de Rendering

- **Fase 1-3**: OpenGL 3.3 Core Profile
- **Fase 4+**: Vulkan 1.3 (opcional, mejor rendimiento)

---

## 📂 Estructura del Proyecto

```
multininjaespacial/
├── .spec/                          # Especificaciones y ADRs
│   ├── project.md                  # Este archivo
│   └── adr/                        # Architecture Decision Records
│       ├── 001-cpp20.md
│       ├── 002-ecs-entt.md
│       ├── 003-renderer-abstraction.md
│       ├── 004-networking-enet.md
│       └── 005-development-phases.md
│
├── src/                            # Código fuente
│   ├── core/                       # Dominio (ECS)
│   │   ├── ecs/
│   │   │   ├── Registry.hpp/cpp    # Wrapper sobre EnTT
│   │   │   └── Entity.hpp/cpp      # Wrapper opcional OOP
│   │   ├── components/             # Componentes (datos puros)
│   │   │   ├── Transform.hpp       # Posición, rotación, escala
│   │   │   ├── Velocity.hpp        # Velocidad lineal y angular
│   │   │   ├── Renderable.hpp      # Info de renderizado
│   │   │   ├── Health.hpp          # Puntos de vida
│   │   │   └── NetworkEntity.hpp   # Sincronización red
│   │   └── systems/                # Sistemas (lógica)
│   │       ├── MovementSystem      # Actualiza Transform con Velocity
│   │       ├── RenderSystem        # Dibuja entidades
│   │       ├── CollisionSystem     # Detección de colisiones
│   │       └── NetworkSyncSystem   # Sincroniza red
│   │
│   ├── application/                # Casos de uso
│   │   ├── usecases/
│   │   │   ├── StartGame.cpp
│   │   │   ├── UpdateGame.cpp
│   │   │   ├── ConnectToServer.cpp
│   │   │   └── SpawnPlayer.cpp
│   │   └── services/
│   │       └── GameStateManager.cpp
│   │
│   ├── infrastructure/             # Adaptadores (implementaciones)
│   │   ├── rendering/
│   │   │   ├── IRenderer.hpp       # Interfaz abstracta
│   │   │   ├── opengl/
│   │   │   │   ├── OpenGLRenderer  # Implementación OpenGL 3.3
│   │   │   │   ├── ShaderProgram   # Wrapper de shaders
│   │   │   │   └── VertexBuffer    # Gestión de VBO/VAO
│   │   │   └── vulkan/             # (Fase 4)
│   │   │       └── VulkanRenderer
│   │   ├── networking/
│   │   │   ├── INetworkAdapter.hpp
│   │   │   ├── ENetAdapter.cpp
│   │   │   ├── NetworkClient.cpp
│   │   │   └── NetworkServer.cpp
│   │   ├── input/
│   │   │   ├── InputManager.cpp
│   │   │   └── SDLInputAdapter.cpp
│   │   └── audio/
│   │       └── AudioManager.cpp
│   │
│   ├── presentation/               # Entry points
│   │   ├── main.cpp                # Punto de entrada principal
│   │   ├── GameWindow.hpp/cpp      # Gestión de ventana SDL
│   │   └── GameLoop.hpp/cpp        # Loop principal del juego
│   │
│   └── shared/                     # Utilidades compartidas
│       ├── math/
│       ├── memory/
│       └── utils/
│
├── server/                         # Servidor dedicado (Fase 2)
│   ├── src/
│   │   ├── main.cpp
│   │   ├── DedicatedServer.cpp
│   │   └── ServerGameLoop.cpp
│   └── include/
│
├── tests/                          # Tests
│   ├── unit/                       # Tests unitarios (Catch2)
│   │   ├── test_ecs.cpp
│   │   ├── test_components.cpp
│   │   ├── test_systems.cpp
│   │   └── test_math.cpp
│   ├── integration/                # Tests de integración
│   │   ├── test_rendering.cpp
│   │   ├── test_networking.cpp
│   │   └── test_game_loop.cpp
│   └── performance/                # Benchmarks
│
├── assets/                         # Recursos del juego
│   ├── sprites/
│   ├── sounds/
│   ├── fonts/
│   └── shaders/
│
├── tools/                          # Herramientas de desarrollo
├── cmake/                          # Módulos de CMake
│   └── modules/
│       ├── CompilerWarnings.cmake
│       └── StaticAnalyzers.cmake
│
├── docs/                           # Documentación adicional
│
├── CMakeLists.txt                  # Build system principal
├── conanfile.txt                   # Dependencias
└── README.md                       # Readme público
```

---

## 🧩 Componentes Principales

### 1. Core (Dominio)

#### Components (Componentes)

Los componentes son **datos puros** sin lógica.

| Componente | Propósito | Campos Principales |
|------------|-----------|-------------------|
| `Transform` | Posición, rotación, escala | `position`, `rotation`, `scale` |
| `Velocity` | Velocidad lineal y angular | `linear`, `angular` |
| `Renderable` | Información de renderizado | `textureId`, `color`, `layer` |
| `Health` | Puntos de vida | `current`, `maximum` |
| `NetworkEntity` | Sincronización red | `networkId`, `ownerId`, `hasAuthority` |

#### Systems (Sistemas)

Los sistemas contienen **lógica pura** que opera sobre componentes.

| Sistema | Procesa | Función |
|---------|---------|---------|
| `MovementSystem` | `Transform + Velocity` | Actualiza posición con velocidad |
| `RenderSystem` | `Transform + Renderable` | Dibuja sprites en pantalla |
| `CollisionSystem` | `Transform + Collider` | Detecta colisiones |
| `NetworkSyncSystem` | `NetworkEntity + Transform` | Sincroniza estado por red |

---

### 2. Infrastructure (Adaptadores)

#### Renderer

**Interfaz**: `IRenderer` (abstracción)
**Implementaciones**:
- `OpenGLRenderer` (Fase 1-3)
- `VulkanRenderer` (Fase 4+)

**Métodos principales**:
```cpp
Initialize(width, height)
Clear(color)
DrawSprite(textureId, position, size, rotation, color)
Present()
LoadTexture(id, filepath)
```

#### Networking

**Interfaz**: `INetworkAdapter`
**Implementación**: `ENetAdapter` (UDP confiable)

**Características**:
- Client-server con servidor dedicado opcional
- Sincronización de entidades con interpolación
- Compresión de datos (Fase 3)

---

### 3. Game Loop

**Patrón**: "Fix Your Timestep" (Glenn Fiedler)

**Características**:
- **Fixed timestep** para física (60 Hz)
- **Variable timestep** para rendering
- Acumulador para evitar "spiral of death"
- Frame limiting opcional

**Pseudocódigo**:
```cpp
while (running) {
    float deltaTime = CalculateDeltaTime();
    accumulator += deltaTime;

    // Fixed timestep para física
    while (accumulator >= FIXED_TIMESTEP) {
        Update(FIXED_TIMESTEP);
        accumulator -= FIXED_TIMESTEP;
    }

    // Rendering
    Render();
    SwapBuffers();
}
```

---

## 🗺️ Roadmap de Desarrollo

### Fase 1: MVP Básico (ACTUAL) ✅

**Duración**: 2 semanas
**Objetivo**: Ventana funcional con rendering básico

**Entregables**:
- ✅ CMakeLists.txt configurado
- ✅ Conan dependencies instaladas
- ✅ Ventana SDL2 con contexto OpenGL
- ✅ Renderer OpenGL básico (shaders, quads)
- ✅ ECS setup con EnTT
- ✅ Game loop con fixed timestep
- ✅ Sistema de movimiento
- ✅ 2 entidades de prueba moviéndose

**Compilar y ejecutar**:
```bash
cd multininjaespacial
mkdir build && cd build
conan install .. --build=missing
cmake ..
cmake --build .
./multininjaespacial
```

---

### Fase 2: Multijugador Básico (Siguiente)

**Duración**: 3 semanas
**Objetivo**: 2 jugadores en red local

**Tareas**:
- [ ] Implementar `ENetAdapter`
- [ ] `NetworkClient` y `NetworkServer`
- [ ] `NetworkSyncSystem` para sincronizar `Transform`
- [ ] Input handling (teclado/gamepad)
- [ ] Servidor dedicado básico
- [ ] Tests de latencia

**Entregables**:
- Partida 2 jugadores en LAN
- Sincronización de posición
- Latencia < 50ms en LAN

---

### Fase 3: Optimización para Streaming

**Duración**: 2 semanas
**Objetivo**: 60 FPS estables en streaming

**Tareas**:
- [ ] Batch rendering (reducir draw calls)
- [ ] Frustum culling
- [ ] Object pooling
- [ ] Compresión de datos de red
- [ ] Profiling con Tracy

**Métricas objetivo**:
- CPU: < 15% en streaming
- GPU: < 30% en streaming
- RAM: < 200 MB

---

### Fase 4: Renderer Vulkan

**Duración**: 4 semanas
**Objetivo**: Renderer Vulkan para mejor rendimiento

**Tareas**:
- [ ] `VulkanRenderer` implementación
- [ ] Render graph
- [ ] Multithreading de rendering
- [ ] Comparativa OpenGL vs Vulkan

**Mejora esperada**:
- +30% FPS vs OpenGL
- +50% entidades renderizadas

---

### Fase 5: Escalado Masivo

**Duración**: 4 semanas
**Objetivo**: 10,000+ entidades a 60 FPS

**Tareas**:
- [ ] Spatial hashing para colisiones
- [ ] Octree/Quadtree para rendering
- [ ] Job system multithreading
- [ ] Servidor dedicado escalado

**Métricas objetivo**:
- 10,000 entidades @ 60 FPS
- 100 jugadores simultáneos
- Latencia < 100ms intercontinental

---

## 🔨 Compilación y Ejecución

### Requisitos Previos

- **C++ Compiler**: GCC 10+, Clang 12+, MSVC 2022+
- **CMake**: 3.20+
- **Conan**: 2.x
- **OpenGL**: 3.3+ (drivers actualizados)

### Instalación de Dependencias

#### macOS
```bash
brew install cmake conan
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt install cmake g++ libgl1-mesa-dev
pip install conan
```

#### Windows
```
Descargar CMake: https://cmake.org/download/
Descargar Conan: pip install conan
Instalar Visual Studio 2022 con C++ tools
```

---

### Compilar el Proyecto

#### 1. Clonar repositorio
```bash
cd ~/Desktop/Proyectos/C++
cd multininjaespacial
```

#### 2. Instalar dependencias con Conan
```bash
mkdir build && cd build
conan install .. --build=missing
```

#### 3. Configurar con CMake
```bash
cmake ..
# O para Release:
cmake -DCMAKE_BUILD_TYPE=Release ..
```

#### 4. Compilar
```bash
cmake --build .
# O con make:
make -j8
```

#### 5. Ejecutar
```bash
./multininjaespacial
```

---

### Opciones de CMake

```bash
# Build con tests
cmake -DBUILD_TESTS=ON ..

# Build con servidor dedicado
cmake -DBUILD_SERVER=ON ..

# Habilitar Vulkan (Fase 4)
cmake -DENABLE_VULKAN=ON ..

# Habilitar profiling
cmake -DENABLE_PROFILING=ON ..

# Build Release optimizado
cmake -DCMAKE_BUILD_TYPE=Release ..
```

---

## 🧪 Testing

### Ejecutar Tests

```bash
cd build

# Tests unitarios
./unit_tests

# Tests de integración
./integration_tests

# Todos los tests con CTest
ctest --verbose
```

### Coverage (Fase 2+)

```bash
cmake -DCMAKE_BUILD_TYPE=Coverage ..
make coverage
# Ver reporte en build/coverage/index.html
```

### Benchmarks (Fase 3+)

```bash
./performance_tests --benchmark
```

---

## 📜 ADRs (Architecture Decision Records)

### ADR-001: C++20

**Decisión**: Usar C++20 como estándar mínimo
**Razón**: Necesitamos concepts, ranges y coroutines para networking asíncrono
**Consecuencias**: Requiere compiladores modernos (GCC 10+, Clang 12+)
**Ver**: [.spec/adr/001-cpp20.md](.spec/adr/001-cpp20.md)

---

### ADR-002: ECS con EnTT

**Decisión**: Usar EnTT para Entity-Component-System
**Razón**: Mejor rendimiento (cache-friendly), header-only, C++20
**Alternativas**: flecs, EntityX
**Ver**: [.spec/adr/002-ecs-entt.md](.spec/adr/002-ecs-entt.md)

---

### ADR-003: Renderer Abstraction

**Decisión**: Interfaz `IRenderer` con múltiples backends
**Razón**: Poder cambiar entre OpenGL y Vulkan sin modificar lógica
**Ver**: [.spec/adr/003-renderer-abstraction.md](.spec/adr/003-renderer-abstraction.md)

---

### ADR-004: ENet para Networking

**Decisión**: Usar ENet (UDP confiable)
**Razón**: Mejor latencia que TCP, confiabilidad selectiva
**Alternativas**: RakNet, Steam Networking, raw UDP
**Ver**: [.spec/adr/004-networking-enet.md](.spec/adr/004-networking-enet.md)

---

### ADR-005: 5 Fases de Desarrollo

**Decisión**: Desarrollo incremental en 5 fases
**Razón**: Entrega temprana de valor, feedback rápido
**Ver**: [.spec/adr/005-development-phases.md](.spec/adr/005-development-phases.md)

---

## 📚 Recursos y Referencias

### Documentación Técnica

- [EnTT Documentation](https://github.com/skypjack/entt)
- [SDL2 Wiki](https://wiki.libsdl.org/)
- [OpenGL Tutorial](https://learnopengl.com/)
- [Vulkan Guide](https://vkguide.dev/)
- [Fix Your Timestep](https://gafferongames.com/post/fix_your_timestep/)

### Arquitectura

- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)
- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Game Programming Patterns](https://gameprogrammingpatterns.com/)

---

## 👥 Contribuciones

**Modo ROBUST activo**: Estándares máximos aplicados

### Checklist antes de commit

- [ ] Código compila sin warnings
- [ ] Tests pasan (>90% coverage en lógica de negocio)
- [ ] Comentarios en español explicando lógica compleja
- [ ] Documentación actualizada si cambió interfaz pública
- [ ] ADR creado si decisión arquitectónica nueva

### Code Review

Todo código pasa por revisión exhaustiva:
- Arquitectura Hexagonal respetada
- ECS patterns correctos
- Sin memory leaks (valgrind/sanitizers)
- Performance aceptable (profiling)

---

## 📝 Licencia

**Pendiente de definir**
(MIT, GPL, propietaria, etc.)

---

## 📞 Contacto

**Desarrollador principal**: [Tu nombre]
**Email**: [Tu email]
**GitHub**: [Tu repo]

---

**Última actualización**: 2025-10-18
**Versión del documento**: 1.0.0
