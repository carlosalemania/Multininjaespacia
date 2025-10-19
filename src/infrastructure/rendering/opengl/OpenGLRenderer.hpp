// ============================================================================
// OpenGL Renderer - Implementación OpenGL 3.3+
// ============================================================================
// Renderer para Fase 1 (MVP) usando OpenGL 3.3 Core Profile
// ============================================================================

#pragma once

#include "../IRenderer.hpp"
#include <GL/glew.h>
#include <unordered_map>
#include <memory>

namespace MultiNinjaEspacial::Infrastructure::Rendering {

// Forward declaration
class ShaderProgram;
class VertexBuffer;

/**
 * @brief Implementación del renderer usando OpenGL 3.3+
 *
 * Características:
 * - OpenGL 3.3 Core Profile (compatible con macOS/Windows/Linux)
 * - Batch rendering para sprites
 * - Sistema de shaders modular
 * - Gestión de texturas
 *
 * Ejemplo de uso:
 * ```cpp
 * OpenGLRenderer renderer;
 * renderer.Initialize(800, 600);
 *
 * renderer.LoadTexture("player", "assets/sprites/player.png");
 *
 * // En game loop:
 * renderer.Clear({0.1f, 0.1f, 0.15f, 1.0f});
 * renderer.DrawSprite("player", {400, 300}, {64, 64}, 0.0f, {1,1,1,1});
 * renderer.Present();
 * ```
 */
class OpenGLRenderer : public IRenderer {
public:
    OpenGLRenderer();
    ~OpenGLRenderer() override;

    // Implementación de IRenderer
    bool Initialize(int width, int height) override;
    void Shutdown() override;
    void Clear(const glm::vec4& color) override;
    void Present() override;
    void SetViewport(int x, int y, int width, int height) override;

    void DrawSprite(
        const std::string& textureId,
        const glm::vec2& position,
        const glm::vec2& size,
        float rotation,
        const glm::vec4& color
    ) override;

    bool LoadTexture(const std::string& id, const std::string& filepath) override;
    void UnloadTexture(const std::string& id) override;

    [[nodiscard]] std::string GetName() const override;
    [[nodiscard]] RenderStats GetStats() const override;
    void ResetStats() override;

private:
    /**
     * @brief Inicializa shaders por defecto
     * @return true si exitoso
     */
    bool InitializeShaders();

    /**
     * @brief Inicializa buffers de geometría para sprites
     * @return true si exitoso
     */
    bool InitializeBuffers();

    /**
     * @brief Crea la geometría de un quad (2 triángulos para sprite)
     */
    void CreateQuadGeometry();

    // Dimensiones del framebuffer
    int m_Width{0};
    int m_Height{0};

    // Shader program para sprites
    std::unique_ptr<ShaderProgram> m_SpriteShader;

    // VAO y VBO para quad de sprite
    GLuint m_QuadVAO{0};
    GLuint m_QuadVBO{0};

    // Texturas cargadas (ID → OpenGL texture handle)
    std::unordered_map<std::string, GLuint> m_Textures;

    // Estadísticas de renderizado
    RenderStats m_Stats;

    // Projection matrix (ortográfica 2D)
    glm::mat4 m_ProjectionMatrix;
};

} // namespace MultiNinjaEspacial::Infrastructure::Rendering
