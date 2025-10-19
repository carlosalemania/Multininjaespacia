// ============================================================================
// Game Loop - Implementación
// ============================================================================

#include "GameLoop.hpp"
#include "../core/systems/MovementSystem.hpp"
#include <spdlog/spdlog.h>
#include <thread>

namespace MultiNinjaEspacial::Presentation {

GameLoop::GameLoop() {
    spdlog::info("GameLoop creado");
}

GameLoop::~GameLoop() {
    Shutdown();
}

bool GameLoop::Initialize(
    GameWindow* window,
    Infrastructure::Rendering::IRenderer* renderer,
    Core::ECS::Registry* registry
) {
    if (!window || !renderer || !registry) {
        spdlog::error("GameLoop::Initialize - Parámetros nulos");
        return false;
    }

    m_Window = window;
    m_Renderer = renderer;
    m_Registry = registry;

    m_LastFrameTime = Clock::now();
    m_LastFPSUpdate = Clock::now();

    m_Initialized = true;

    spdlog::info("GameLoop inicializado");
    return true;
}

void GameLoop::Run() {
    if (!m_Initialized) {
        spdlog::error("GameLoop::Run - No inicializado");
        return;
    }

    spdlog::info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    spdlog::info("Iniciando Game Loop");
    spdlog::info("Target FPS: {}", m_TargetFPS);
    spdlog::info("Fixed Timestep: {:.6f}s ({} Hz)", FIXED_TIMESTEP, static_cast<int>(1.0f / FIXED_TIMESTEP));
    spdlog::info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    m_Running = true;
    m_LastFrameTime = Clock::now();

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MAIN GAME LOOP
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    while (m_Running && m_Window->IsOpen()) {
        // ─────────────────────────────────────────────────────────────────
        // 1. Calcular Delta Time
        // ─────────────────────────────────────────────────────────────────
        TimePoint currentTime = Clock::now();
        Duration elapsed = currentTime - m_LastFrameTime;
        m_DeltaTime = elapsed.count();
        m_LastFrameTime = currentTime;

        // Limitar delta time para evitar "spiral of death"
        // Si el juego se congela, no acumulamos más de 0.25s
        if (m_DeltaTime > 0.25f) {
            m_DeltaTime = 0.25f;
        }

        // ─────────────────────────────────────────────────────────────────
        // 2. Procesar Input
        // ─────────────────────────────────────────────────────────────────
        ProcessInput();

        // ─────────────────────────────────────────────────────────────────
        // 3. Actualizar Lógica (Fixed Timestep)
        // ─────────────────────────────────────────────────────────────────
        // Acumular tiempo
        m_Accumulator += m_DeltaTime;

        // Ejecutar updates a timestep fijo
        // Esto garantiza física determinista y estable
        while (m_Accumulator >= FIXED_TIMESTEP) {
            Update(FIXED_TIMESTEP);
            m_Accumulator -= FIXED_TIMESTEP;
        }

        // ─────────────────────────────────────────────────────────────────
        // 4. Renderizar
        // ─────────────────────────────────────────────────────────────────
        Render();

        // ─────────────────────────────────────────────────────────────────
        // 5. Swap Buffers y Present
        // ─────────────────────────────────────────────────────────────────
        m_Window->SwapBuffers();

        // ─────────────────────────────────────────────────────────────────
        // 6. Frame Limiting (si no hay VSync)
        // ─────────────────────────────────────────────────────────────────
        if (m_TargetFPS > 0) {
            TimePoint frameEnd = Clock::now();
            Duration frameDuration = frameEnd - currentTime;
            float frameTime = frameDuration.count();

            // Si el frame terminó antes del target, esperar
            if (frameTime < m_TargetFrameTime) {
                float sleepTime = m_TargetFrameTime - frameTime;
                std::this_thread::sleep_for(
                    std::chrono::duration<float>(sleepTime)
                );
            }
        }

        // ─────────────────────────────────────────────────────────────────
        // 7. Calcular FPS
        // ─────────────────────────────────────────────────────────────────
        CalculateFPS();
    }

    spdlog::info("Game Loop terminado");
}

void GameLoop::Shutdown() {
    m_Running = false;
    m_Initialized = false;
    spdlog::info("GameLoop cerrado");
}

void GameLoop::SetTargetFPS(int targetFPS) {
    m_TargetFPS = targetFPS;
    if (targetFPS > 0) {
        m_TargetFrameTime = 1.0f / static_cast<float>(targetFPS);
    }
    spdlog::info("Target FPS configurado a {}", targetFPS);
}

void GameLoop::ProcessInput() {
    // Procesar eventos de SDL
    m_Window->PollEvents();

    // TODO: Distribuir eventos a InputManager
    // TODO: Actualizar estado de input (teclado, mouse, gamepads)
}

void GameLoop::Update(float deltaTime) {
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ACTUALIZACIÓN DE SISTEMAS (en orden de dependencias)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    auto& registry = m_Registry->GetNative();

    // 1. Sistema de Movimiento (actualiza Transform basándose en Velocity)
    Core::Systems::MovementSystem::Update(registry, deltaTime);

    // TODO: 2. Sistema de Colisiones
    // TODO: 3. Sistema de IA
    // TODO: 4. Sistema de Networking (sincronización)
    // TODO: 5. Sistema de Audio
    // TODO: 6. Sistema de Partículas

    // NOTA: RenderSystem NO va aquí, va en Render()
}

void GameLoop::Render() {
    // Limpiar pantalla
    m_Renderer->Clear(glm::vec4{0.1f, 0.1f, 0.15f, 1.0f});

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // RENDERIZADO DE ENTIDADES
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    // TODO: Implementar RenderSystem
    // TODO: Ordenar entidades por layer
    // TODO: Frustum culling (solo dibujar lo visible)
    // TODO: Batch rendering (agrupar draws)

    // Por ahora, ejemplo básico:
    // auto view = m_Registry->GetNative().view<Core::Components::Transform, Core::Components::Renderable>();
    // for (auto entity : view) {
    //     auto& transform = view.get<Core::Components::Transform>(entity);
    //     auto& renderable = view.get<Core::Components::Renderable>(entity);
    //
    //     if (renderable.visible) {
    //         m_Renderer->DrawSprite(
    //             renderable.textureId,
    //             transform.position,
    //             {64, 64},  // size (hardcoded por ahora)
    //             transform.rotation,
    //             renderable.color
    //         );
    //     }
    // }

    // Presentar frame
    m_Renderer->Present();
}

void GameLoop::CalculateFPS() {
    m_FrameCount++;

    TimePoint now = Clock::now();
    Duration elapsed = now - m_LastFPSUpdate;

    // Actualizar FPS cada segundo
    if (elapsed.count() >= 1.0f) {
        m_FPS = static_cast<float>(m_FrameCount) / elapsed.count();
        m_FrameCount = 0;
        m_LastFPSUpdate = now;

        // Log FPS cada 5 segundos (para no spamear)
        static int fpsLogCounter = 0;
        fpsLogCounter++;
        if (fpsLogCounter >= 5) {
            auto stats = m_Renderer->GetStats();
            spdlog::debug("FPS: {:.1f} | Draw Calls: {} | Tris: {} | DT: {:.3f}ms",
                         m_FPS, stats.drawCalls, stats.triangles, m_DeltaTime * 1000.0f);
            fpsLogCounter = 0;
        }
    }
}

} // namespace MultiNinjaEspacial::Presentation
