// ============================================================================
// Multi Ninja Espacial - Punto de Entrada Principal
// ============================================================================
// Inicializa todos los sistemas y ejecuta el game loop
// ============================================================================

#include "GameWindow.hpp"
#include "GameLoop.hpp"
#include "../core/ecs/Registry.hpp"
#include "../core/components/Transform.hpp"
#include "../core/components/Velocity.hpp"
#include "../core/components/Renderable.hpp"
#include "../infrastructure/rendering/opengl/OpenGLRenderer.hpp"
#include <spdlog/spdlog.h>
#include <memory>

using namespace MultiNinjaEspacial;

/**
 * @brief Configura el sistema de logging
 */
void SetupLogging() {
    // Configurar nivel de log (DEBUG para desarrollo, INFO para producción)
    #ifdef NDEBUG
    spdlog::set_level(spdlog::level::info);
    #else
    spdlog::set_level(spdlog::level::debug);
    #endif

    // Formato: [hora] [nivel] mensaje
    spdlog::set_pattern("[%H:%M:%S] [%^%l%$] %v");

    spdlog::info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    spdlog::info("       MULTI NINJA ESPACIAL - v0.1.0");
    spdlog::info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
}

/**
 * @brief Crea entidades de prueba para el MVP
 * @param registry ECS Registry
 */
void CreateTestEntities(Core::ECS::Registry& registry) {
    spdlog::info("Creando entidades de prueba...");

    // Crear jugador de ejemplo
    auto player = registry.CreateEntity("player");
    registry.AddComponent<Core::Components::Transform>(
        player,
        glm::vec2{400.0f, 300.0f},  // Posición: centro de pantalla 800x600
        0.0f,                        // Sin rotación
        glm::vec2{1.0f, 1.0f}        // Escala normal
    );

    registry.AddComponent<Core::Components::Velocity>(
        player,
        glm::vec2{50.0f, 30.0f},    // Velocidad: 50 px/s derecha, 30 px/s abajo
        0.0f                         // Sin rotación
    );

    registry.AddComponent<Core::Components::Renderable>(
        player,
        "player_sprite",                      // ID de textura
        glm::vec4{0.2f, 0.8f, 1.0f, 1.0f},   // Color azul claro
        10                                    // Layer 10
    );

    spdlog::info("  ✓ Jugador creado en (400, 300)");

    // Crear enemigo de ejemplo
    auto enemy = registry.CreateEntity("enemy");
    registry.AddComponent<Core::Components::Transform>(
        enemy,
        glm::vec2{100.0f, 100.0f},
        0.0f,
        glm::vec2{1.0f, 1.0f}
    );

    registry.AddComponent<Core::Components::Velocity>(
        enemy,
        glm::vec2{20.0f, 15.0f},
        45.0f  // Rotar a 45 grados/seg
    );

    registry.AddComponent<Core::Components::Renderable>(
        enemy,
        "enemy_sprite",
        glm::vec4{1.0f, 0.2f, 0.2f, 1.0f},  // Color rojo
        10
    );

    spdlog::info("  ✓ Enemigo creado en (100, 100)");

    spdlog::info("Entidades de prueba creadas: {}", registry.GetEntityCount());
}

/**
 * @brief Punto de entrada principal
 */
int main(int argc, char* argv[]) {
    // Evitar warning de parámetros no usados
    (void)argc;
    (void)argv;

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 1. CONFIGURAR LOGGING
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    SetupLogging();

    try {
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 2. CREAR VENTANA
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Presentation::GameWindow window;
        if (!window.Create("Multi Ninja Espacial - v0.1.0 MVP", 800, 600, false)) {
            spdlog::error("Fallo al crear ventana");
            return 1;
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 3. CREAR RENDERER
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        auto renderer = std::make_unique<Infrastructure::Rendering::OpenGLRenderer>();
        if (!renderer->Initialize(800, 600)) {
            spdlog::error("Fallo al inicializar renderer");
            return 1;
        }

        spdlog::info("Renderer: {}", renderer->GetName());

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 4. CREAR REGISTRY (ECS)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Core::ECS::Registry registry;

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 5. CREAR ENTIDADES DE PRUEBA (MVP)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        CreateTestEntities(registry);

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 6. CREAR Y EJECUTAR GAME LOOP
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Presentation::GameLoop loop;
        if (!loop.Initialize(&window, renderer.get(), &registry)) {
            spdlog::error("Fallo al inicializar game loop");
            return 1;
        }

        // Configurar 60 FPS
        loop.SetTargetFPS(60);

        // Ejecutar loop (bloqueante hasta que se cierre la ventana)
        loop.Run();

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 7. LIMPIEZA
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        spdlog::info("Cerrando aplicación...");

        loop.Shutdown();
        registry.Clear();
        renderer->Shutdown();
        window.Destroy();

        spdlog::info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        spdlog::info("Aplicación cerrada correctamente");
        spdlog::info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        return 0;

    } catch (const std::exception& e) {
        spdlog::critical("Excepción no manejada: {}", e.what());
        return 1;
    } catch (...) {
        spdlog::critical("Excepción desconocida");
        return 1;
    }
}
