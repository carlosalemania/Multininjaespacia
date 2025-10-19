// ============================================================================
// Game Loop - Loop principal del juego
// ============================================================================
// Implementa el patrón de game loop clásico con fixed timestep
// ============================================================================

#pragma once

#include "../core/ecs/Registry.hpp"
#include "../infrastructure/rendering/IRenderer.hpp"
#include "GameWindow.hpp"
#include <memory>
#include <chrono>

namespace MultiNinjaEspacial::Presentation {

/**
 * @brief Game Loop principal del juego
 *
 * Implementa:
 * - Fixed timestep para física
 * - Variable timestep para rendering
 * - Frame limiting (60 FPS target)
 * - Delta time calculation
 *
 * Patrón usado: "Fix Your Timestep" de Glenn Fiedler
 * https://gafferongames.com/post/fix_your_timestep/
 *
 * Ejemplo de uso:
 * ```cpp
 * GameLoop loop;
 * loop.Initialize(window, renderer, registry);
 *
 * loop.Run();  // Ejecuta hasta que se cierre la ventana
 *
 * loop.Shutdown();
 * ```
 */
class GameLoop {
public:
    GameLoop();
    ~GameLoop();

    /**
     * @brief Inicializa el game loop
     * @param window Ventana del juego
     * @param renderer Renderer
     * @param registry ECS Registry
     * @return true si inicialización exitosa
     */
    bool Initialize(
        GameWindow* window,
        Infrastructure::Rendering::IRenderer* renderer,
        Core::ECS::Registry* registry
    );

    /**
     * @brief Ejecuta el game loop (bloqueante hasta que se cierre)
     */
    void Run();

    /**
     * @brief Limpia recursos del loop
     */
    void Shutdown();

    /**
     * @brief Solicita detener el loop
     */
    void Stop() { m_Running = false; }

    /**
     * @brief Obtiene FPS actual
     */
    [[nodiscard]] float GetFPS() const { return m_FPS; }

    /**
     * @brief Obtiene delta time del último frame (en segundos)
     */
    [[nodiscard]] float GetDeltaTime() const { return m_DeltaTime; }

    /**
     * @brief Configura target FPS (por defecto 60)
     * @param targetFPS FPS objetivo
     */
    void SetTargetFPS(int targetFPS);

private:
    /**
     * @brief Procesa input
     */
    void ProcessInput();

    /**
     * @brief Actualiza lógica del juego (fixed timestep)
     * @param deltaTime Delta time en segundos
     */
    void Update(float deltaTime);

    /**
     * @brief Renderiza el frame actual
     */
    void Render();

    /**
     * @brief Calcula FPS actual
     */
    void CalculateFPS();

    // Referencias a componentes del juego
    GameWindow* m_Window{nullptr};
    Infrastructure::Rendering::IRenderer* m_Renderer{nullptr};
    Core::ECS::Registry* m_Registry{nullptr};

    // Control del loop
    bool m_Running{false};
    bool m_Initialized{false};

    // Timing
    using Clock = std::chrono::high_resolution_clock;
    using TimePoint = std::chrono::time_point<Clock>;
    using Duration = std::chrono::duration<float>;

    TimePoint m_LastFrameTime;
    float m_DeltaTime{0.0f};
    float m_Accumulator{0.0f};

    // Fixed timestep (60 FPS = 0.016666... segundos)
    static constexpr float FIXED_TIMESTEP = 1.0f / 60.0f;

    // FPS tracking
    float m_FPS{0.0f};
    int m_FrameCount{0};
    TimePoint m_LastFPSUpdate;

    // Target FPS (0 = sin límite)
    int m_TargetFPS{60};
    float m_TargetFrameTime{1.0f / 60.0f};
};

} // namespace MultiNinjaEspacial::Presentation
