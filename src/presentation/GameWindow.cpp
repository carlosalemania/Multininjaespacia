// ============================================================================
// Game Window - Implementación
// ============================================================================

#include "GameWindow.hpp"
#include <spdlog/spdlog.h>
#include <stdexcept>

namespace MultiNinjaEspacial::Presentation {

GameWindow::GameWindow() {
    spdlog::info("GameWindow creado");
}

GameWindow::~GameWindow() {
    Destroy();
}

bool GameWindow::Create(const std::string& title, int width, int height, bool fullscreen) {
    m_Width = width;
    m_Height = height;
    m_IsFullscreen = fullscreen;

    spdlog::info("Creando ventana: {} ({}x{})", title, width, height);

    // Inicializar SDL (solo video)
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        spdlog::error("SDL Init failed: {}", SDL_GetError());
        return false;
    }

    // Configurar atributos de OpenGL ANTES de crear la ventana
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    // Doble buffer
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

    // Depth buffer (aunque no lo usemos en 2D, no hace daño)
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

    // macOS específico: Forward compatibility
    #ifdef __APPLE__
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
    #endif

    // Flags de la ventana
    Uint32 windowFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN;
    if (fullscreen) {
        windowFlags |= SDL_WINDOW_FULLSCREEN;
    } else {
        windowFlags |= SDL_WINDOW_RESIZABLE;
    }

    // Crear ventana
    m_Window = SDL_CreateWindow(
        title.c_str(),
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        width,
        height,
        windowFlags
    );

    if (!m_Window) {
        spdlog::error("SDL_CreateWindow failed: {}", SDL_GetError());
        SDL_Quit();
        return false;
    }

    // Crear contexto OpenGL
    m_GLContext = SDL_GL_CreateContext(m_Window);
    if (!m_GLContext) {
        spdlog::error("SDL_GL_CreateContext failed: {}", SDL_GetError());
        SDL_DestroyWindow(m_Window);
        SDL_Quit();
        return false;
    }

    // Activar VSync por defecto
    SetVSync(true);

    m_IsOpen = true;

    spdlog::info("Ventana creada exitosamente");
    return true;
}

void GameWindow::Destroy() {
    if (m_GLContext) {
        SDL_GL_DeleteContext(m_GLContext);
        m_GLContext = nullptr;
    }

    if (m_Window) {
        SDL_DestroyWindow(m_Window);
        m_Window = nullptr;
    }

    SDL_Quit();

    m_IsOpen = false;
    spdlog::info("Ventana destruida");
}

void GameWindow::PollEvents() {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        switch (event.type) {
            case SDL_QUIT:
                m_IsOpen = false;
                spdlog::info("Evento SDL_QUIT recibido");
                break;

            case SDL_WINDOWEVENT:
                if (event.window.event == SDL_WINDOWEVENT_RESIZED) {
                    OnResize(event.window.data1, event.window.data2);
                }
                break;

            case SDL_KEYDOWN:
                // Escape cierra la ventana
                if (event.key.keysym.sym == SDLK_ESCAPE) {
                    m_IsOpen = false;
                }
                break;

            // TODO: Distribuir eventos a InputManager
            default:
                break;
        }
    }
}

void GameWindow::SwapBuffers() {
    SDL_GL_SwapWindow(m_Window);
}

void GameWindow::SetVSync(bool enabled) {
    m_VSync = enabled;

    // 1 = VSync on, 0 = VSync off
    // -1 = Adaptive VSync (si está disponible)
    int result = SDL_GL_SetSwapInterval(enabled ? 1 : 0);

    if (result == 0) {
        spdlog::info("VSync {}", enabled ? "activado" : "desactivado");
    } else {
        spdlog::warn("No se pudo cambiar VSync: {}", SDL_GetError());
    }
}

void GameWindow::SetFullscreen(bool fullscreen) {
    m_IsFullscreen = fullscreen;

    Uint32 flags = fullscreen ? SDL_WINDOW_FULLSCREEN : 0;
    int result = SDL_SetWindowFullscreen(m_Window, flags);

    if (result == 0) {
        spdlog::info("Fullscreen {}", fullscreen ? "activado" : "desactivado");
    } else {
        spdlog::error("SDL_SetWindowFullscreen failed: {}", SDL_GetError());
    }
}

float GameWindow::GetAspectRatio() const {
    if (m_Height == 0) return 1.0f;
    return static_cast<float>(m_Width) / static_cast<float>(m_Height);
}

void GameWindow::OnResize(int newWidth, int newHeight) {
    m_Width = newWidth;
    m_Height = newHeight;

    spdlog::info("Ventana redimensionada: {}x{}", newWidth, newHeight);

    // TODO: Notificar al Renderer para actualizar viewport
}

} // namespace MultiNinjaEspacial::Presentation
