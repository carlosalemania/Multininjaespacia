// ============================================================================
// Game Window - Gestión de ventana con SDL2
// ============================================================================
// Crea y gestiona la ventana del juego y el contexto OpenGL
// ============================================================================

#pragma once

#include <SDL2/SDL.h>
#include <string>
#include <memory>

namespace MultiNinjaEspacial::Presentation {

/**
 * @brief Gestiona la ventana del juego usando SDL2
 *
 * Responsabilidades:
 * - Crear ventana SDL
 * - Crear contexto OpenGL
 * - Gestionar eventos de ventana (resize, close, etc.)
 * - Swap buffers
 *
 * Ejemplo de uso:
 * ```cpp
 * GameWindow window;
 * window.Create("Mi Juego", 800, 600);
 *
 * while (window.IsOpen()) {
 *     window.PollEvents();
 *     // ... renderizar ...
 *     window.SwapBuffers();
 * }
 *
 * window.Destroy();
 * ```
 */
class GameWindow {
public:
    GameWindow();
    ~GameWindow();

    /**
     * @brief Crea la ventana y el contexto OpenGL
     * @param title Título de la ventana
     * @param width Ancho inicial
     * @param height Alto inicial
     * @param fullscreen Si crear en pantalla completa
     * @return true si creación exitosa
     */
    bool Create(const std::string& title, int width, int height, bool fullscreen = false);

    /**
     * @brief Destruye la ventana y libera recursos
     */
    void Destroy();

    /**
     * @brief Procesa eventos de SDL (input, resize, close, etc.)
     *
     * Llama esto cada frame en el game loop.
     * Los eventos se distribuyen a InputManager.
     */
    void PollEvents();

    /**
     * @brief Swap buffers (presenta el frame)
     */
    void SwapBuffers();

    /**
     * @brief Verifica si la ventana sigue abierta
     * @return true si no se ha solicitado cerrar
     */
    [[nodiscard]] bool IsOpen() const { return m_IsOpen; }

    /**
     * @brief Obtiene ancho actual de la ventana
     */
    [[nodiscard]] int GetWidth() const { return m_Width; }

    /**
     * @brief Obtiene alto actual de la ventana
     */
    [[nodiscard]] int GetHeight() const { return m_Height; }

    /**
     * @brief Obtiene la ventana SDL nativa
     */
    [[nodiscard]] SDL_Window* GetSDLWindow() const { return m_Window; }

    /**
     * @brief Obtiene el contexto OpenGL
     */
    [[nodiscard]] SDL_GLContext GetGLContext() const { return m_GLContext; }

    /**
     * @brief Activa/desactiva VSync
     * @param enabled true para activar VSync
     */
    void SetVSync(bool enabled);

    /**
     * @brief Cambia entre fullscreen y windowed
     * @param fullscreen true para fullscreen
     */
    void SetFullscreen(bool fullscreen);

    /**
     * @brief Obtiene el aspect ratio de la ventana
     * @return width / height
     */
    [[nodiscard]] float GetAspectRatio() const;

private:
    /**
     * @brief Maneja evento de redimensionamiento
     * @param newWidth Nuevo ancho
     * @param newHeight Nuevo alto
     */
    void OnResize(int newWidth, int newHeight);

    // Ventana SDL
    SDL_Window* m_Window{nullptr};

    // Contexto OpenGL
    SDL_GLContext m_GLContext{nullptr};

    // Dimensiones
    int m_Width{0};
    int m_Height{0};

    // Estado
    bool m_IsOpen{false};
    bool m_IsFullscreen{false};
    bool m_VSync{true};
};

} // namespace MultiNinjaEspacial::Presentation
