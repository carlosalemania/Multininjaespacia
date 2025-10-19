// ============================================================================
// IRenderer - Interfaz abstracta de Renderer
// ============================================================================
// Abstracción sobre APIs de renderizado (OpenGL, Vulkan, etc.)
// Sigue el patrón Adapter de la Arquitectura Hexagonal
// ============================================================================

#pragma once

#include <glm/glm.hpp>
#include <string>
#include <memory>

namespace MultiNinjaEspacial::Infrastructure::Rendering {

/**
 * @brief Interfaz abstracta para renderizado
 *
 * Esta interfaz permite cambiar entre diferentes backends de renderizado
 * sin modificar el código del juego.
 *
 * Implementaciones:
 * - OpenGLRenderer (Fase 1)
 * - VulkanRenderer (Fase 4)
 * - MockRenderer (para tests)
 *
 * Ejemplo de uso:
 * ```cpp
 * std::unique_ptr<IRenderer> renderer;
 *
 * #ifdef USE_VULKAN
 *     renderer = std::make_unique<VulkanRenderer>();
 * #else
 *     renderer = std::make_unique<OpenGLRenderer>();
 * #endif
 *
 * renderer->Initialize(800, 600);
 * renderer->Clear({0.0f, 0.0f, 0.0f, 1.0f});
 * // ... drawing ...
 * renderer->Present();
 * ```
 */
class IRenderer {
public:
    virtual ~IRenderer() = default;

    /**
     * @brief Inicializa el renderer
     * @param width Ancho de la ventana
     * @param height Alto de la ventana
     * @return true si inicialización exitosa
     */
    virtual bool Initialize(int width, int height) = 0;

    /**
     * @brief Limpia recursos del renderer
     */
    virtual void Shutdown() = 0;

    /**
     * @brief Limpia el framebuffer con un color
     * @param color Color de limpieza (RGBA, 0.0-1.0)
     */
    virtual void Clear(const glm::vec4& color) = 0;

    /**
     * @brief Presenta el frame en pantalla (swap buffers)
     */
    virtual void Present() = 0;

    /**
     * @brief Establece el viewport de renderizado
     * @param x Coordenada X
     * @param y Coordenada Y
     * @param width Ancho
     * @param height Alto
     */
    virtual void SetViewport(int x, int y, int width, int height) = 0;

    /**
     * @brief Dibuja un sprite en 2D
     * @param textureId ID de textura
     * @param position Posición en pantalla
     * @param size Tamaño del sprite
     * @param rotation Rotación en grados
     * @param color Tint de color (RGBA)
     */
    virtual void DrawSprite(
        const std::string& textureId,
        const glm::vec2& position,
        const glm::vec2& size,
        float rotation,
        const glm::vec4& color
    ) = 0;

    /**
     * @brief Carga una textura desde archivo
     * @param id ID único para la textura
     * @param filepath Path al archivo de imagen
     * @return true si carga exitosa
     */
    virtual bool LoadTexture(const std::string& id, const std::string& filepath) = 0;

    /**
     * @brief Descarga una textura de memoria
     * @param id ID de la textura
     */
    virtual void UnloadTexture(const std::string& id) = 0;

    /**
     * @brief Obtiene el nombre del backend de renderizado
     * @return Nombre (ej: "OpenGL 3.3", "Vulkan 1.3")
     */
    [[nodiscard]] virtual std::string GetName() const = 0;

    /**
     * @brief Obtiene estadísticas de renderizado
     * @return Struct con métricas (draw calls, triángulos, etc.)
     */
    struct RenderStats {
        uint32_t drawCalls{0};
        uint32_t triangles{0};
        uint32_t vertices{0};
        float frameTime{0.0f}; // en milisegundos
    };

    [[nodiscard]] virtual RenderStats GetStats() const = 0;

    /**
     * @brief Resetea estadísticas de renderizado (llamar cada frame)
     */
    virtual void ResetStats() = 0;
};

} // namespace MultiNinjaEspacial::Infrastructure::Rendering
