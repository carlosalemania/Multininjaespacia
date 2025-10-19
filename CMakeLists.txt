# ============================================================================
# Multi Ninja Espacial - CMakeLists.txt Principal
# ============================================================================
# Proyecto: Juego multiplataforma, multijugador, optimizado para streaming
# Arquitectura: Hexagonal + ECS
# Estándar: C++20
# ============================================================================

cmake_minimum_required(VERSION 3.20)
project(MultiNinjaEspacial VERSION 0.1.0 LANGUAGES CXX)

# ============================================================================
# CONFIGURACIÓN DE C++20
# ============================================================================
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ============================================================================
# OPCIONES DE COMPILACIÓN
# ============================================================================
option(BUILD_TESTS "Compilar tests unitarios y de integración" ON)
option(BUILD_SERVER "Compilar servidor dedicado" ON)
option(ENABLE_VULKAN "Habilitar soporte Vulkan (Fase 4)" OFF)
option(ENABLE_PROFILING "Habilitar profiling y métricas" ON)

# ============================================================================
# CONFIGURACIÓN DE BUILD TYPES
# ============================================================================
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Tipo de build (Debug, Release, RelWithDebInfo)" FORCE)
endif()

# Flags de compilación por configuración
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -Wall -Wextra -Wpedantic")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -march=native")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")

# ============================================================================
# BUSCAR DEPENDENCIAS CON CONAN
# ============================================================================
list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR})
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})

# Conan integration - genera los archivos find_package
if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    message(STATUS "Descargando conan.cmake desde https://github.com/conan-io/cmake-conan")
    file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/0.18.1/conan.cmake"
                  "${CMAKE_BINARY_DIR}/conan.cmake"
                  TLS_VERIFY ON)
endif()

include(${CMAKE_BINARY_DIR}/conan.cmake)

# Ejecutar conan install automáticamente
conan_cmake_configure(
    REQUIRES
        entt/3.12.2
        sdl/2.28.5
        glew/2.2.0
        glm/0.9.9.8
        enet/1.3.17
        spdlog/1.12.0
        catch2/3.4.0
    GENERATORS cmake_find_package
    OPTIONS
        sdl:shared=True
        glew:shared=True
)

conan_cmake_autodetect(settings)

conan_cmake_install(
    PATH_OR_REFERENCE .
    BUILD missing
    REMOTE conancenter
    SETTINGS ${settings}
)

# ============================================================================
# BUSCAR PAQUETES INSTALADOS POR CONAN
# ============================================================================
find_package(EnTT REQUIRED)
find_package(SDL2 REQUIRED)
find_package(GLEW REQUIRED)
find_package(glm REQUIRED)
find_package(enet REQUIRED)
find_package(spdlog REQUIRED)

# OpenGL (sistema)
find_package(OpenGL REQUIRED)

# Vulkan (opcional, para Fase 4)
if(ENABLE_VULKAN)
    find_package(Vulkan REQUIRED)
    add_compile_definitions(VULKAN_ENABLED)
endif()

# Catch2 (para tests)
if(BUILD_TESTS)
    find_package(Catch2 REQUIRED)
endif()

# ============================================================================
# INCLUIR MÓDULOS PERSONALIZADOS
# ============================================================================
include(cmake/modules/CompilerWarnings.cmake)
include(cmake/modules/StaticAnalyzers.cmake)

# ============================================================================
# CONFIGURAR INCLUDE DIRECTORIES GLOBALES
# ============================================================================
include_directories(
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/src/core
    ${CMAKE_SOURCE_DIR}/src/application
    ${CMAKE_SOURCE_DIR}/src/infrastructure
    ${CMAKE_SOURCE_DIR}/src/presentation
    ${CMAKE_SOURCE_DIR}/src/shared
)

# ============================================================================
# LIBRARY: Core (Dominio - ECS)
# ============================================================================
add_library(core STATIC
    # ECS Core
    src/core/ecs/Registry.cpp
    src/core/ecs/Entity.cpp

    # Components (header-only, pero listamos para IDE)
    src/core/components/Transform.hpp
    src/core/components/Velocity.hpp
    src/core/components/Renderable.hpp
    src/core/components/Health.hpp
    src/core/components/NetworkEntity.hpp

    # Systems
    src/core/systems/MovementSystem.cpp
    src/core/systems/RenderSystem.cpp
    src/core/systems/CollisionSystem.cpp
    src/core/systems/NetworkSyncSystem.cpp
)

target_link_libraries(core PUBLIC
    EnTT::EnTT
    glm::glm
    spdlog::spdlog
)

set_target_properties(core PROPERTIES
    CXX_STANDARD 20
    CXX_STANDARD_REQUIRED ON
)

# ============================================================================
# LIBRARY: Infrastructure (Adaptadores)
# ============================================================================
add_library(infrastructure STATIC
    # Rendering
    src/infrastructure/rendering/IRenderer.hpp
    src/infrastructure/rendering/opengl/OpenGLRenderer.cpp
    src/infrastructure/rendering/opengl/ShaderProgram.cpp
    src/infrastructure/rendering/opengl/VertexBuffer.cpp

    # Networking
    src/infrastructure/networking/INetworkAdapter.hpp
    src/infrastructure/networking/ENetAdapter.cpp
    src/infrastructure/networking/NetworkClient.cpp
    src/infrastructure/networking/NetworkServer.cpp

    # Input
    src/infrastructure/input/InputManager.cpp
    src/infrastructure/input/SDLInputAdapter.cpp

    # Audio (stub para Fase 2)
    src/infrastructure/audio/AudioManager.cpp
)

target_link_libraries(infrastructure PUBLIC
    core
    SDL2::SDL2
    GLEW::GLEW
    OpenGL::GL
    enet::enet
    spdlog::spdlog
)

if(ENABLE_VULKAN)
    target_sources(infrastructure PRIVATE
        src/infrastructure/rendering/vulkan/VulkanRenderer.cpp
        src/infrastructure/rendering/vulkan/VulkanContext.cpp
    )
    target_link_libraries(infrastructure PUBLIC Vulkan::Vulkan)
endif()

# ============================================================================
# LIBRARY: Application (Casos de Uso)
# ============================================================================
add_library(application STATIC
    src/application/usecases/StartGame.cpp
    src/application/usecases/UpdateGame.cpp
    src/application/usecases/ConnectToServer.cpp
    src/application/usecases/SpawnPlayer.cpp
    src/application/services/GameStateManager.cpp
)

target_link_libraries(application PUBLIC
    core
    infrastructure
)

# ============================================================================
# EXECUTABLE: Cliente del Juego
# ============================================================================
add_executable(multininjaespacial
    src/presentation/main.cpp
    src/presentation/GameWindow.cpp
    src/presentation/GameLoop.cpp
)

target_link_libraries(multininjaespacial PRIVATE
    application
    infrastructure
    core
    SDL2::SDL2
    spdlog::spdlog
)

# ============================================================================
# EXECUTABLE: Servidor Dedicado (opcional)
# ============================================================================
if(BUILD_SERVER)
    add_executable(multininjaespacial-server
        server/src/main.cpp
        server/src/DedicatedServer.cpp
        server/src/ServerGameLoop.cpp
    )

    target_link_libraries(multininjaespacial-server PRIVATE
        core
        infrastructure
        enet::enet
        spdlog::spdlog
    )

    target_include_directories(multininjaespacial-server PRIVATE
        ${CMAKE_SOURCE_DIR}/server/include
    )
endif()

# ============================================================================
# TESTS (Catch2)
# ============================================================================
if(BUILD_TESTS)
    enable_testing()

    # Tests unitarios
    add_executable(unit_tests
        tests/unit/test_ecs.cpp
        tests/unit/test_components.cpp
        tests/unit/test_systems.cpp
        tests/unit/test_math.cpp
    )

    target_link_libraries(unit_tests PRIVATE
        core
        Catch2::Catch2WithMain
    )

    # Tests de integración
    add_executable(integration_tests
        tests/integration/test_rendering.cpp
        tests/integration/test_networking.cpp
        tests/integration/test_game_loop.cpp
    )

    target_link_libraries(integration_tests PRIVATE
        application
        infrastructure
        core
        Catch2::Catch2WithMain
    )

    # Registrar tests con CTest
    include(CTest)
    include(Catch)
    catch_discover_tests(unit_tests)
    catch_discover_tests(integration_tests)
endif()

# ============================================================================
# COPIAR ASSETS AL DIRECTORIO DE BUILD
# ============================================================================
add_custom_command(TARGET multininjaespacial POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/assets
        $<TARGET_FILE_DIR:multininjaespacial>/assets
    COMMENT "Copiando assets al directorio de build..."
)

# ============================================================================
# INSTALACIÓN
# ============================================================================
install(TARGETS multininjaespacial
    RUNTIME DESTINATION bin
)

if(BUILD_SERVER)
    install(TARGETS multininjaespacial-server
        RUNTIME DESTINATION bin
    )
endif()

install(DIRECTORY assets
    DESTINATION share/multininjaespacial
)

# ============================================================================
# INFORMACIÓN DE BUILD
# ============================================================================
message(STATUS "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
message(STATUS "Multi Ninja Espacial - Configuración de Build")
message(STATUS "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
message(STATUS "Build Type:        ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ Standard:      C++${CMAKE_CXX_STANDARD}")
message(STATUS "Compiler:          ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Build Tests:       ${BUILD_TESTS}")
message(STATUS "Build Server:      ${BUILD_SERVER}")
message(STATUS "Vulkan Support:    ${ENABLE_VULKAN}")
message(STATUS "Profiling:         ${ENABLE_PROFILING}")
message(STATUS "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
