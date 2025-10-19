// ============================================================================
// OpenGL Renderer - Implementación
// ============================================================================

#include "OpenGLRenderer.hpp"
#include "ShaderProgram.hpp"
#include <spdlog/spdlog.h>
#include <glm/gtc/matrix_transform.hpp>
#include <stdexcept>

// TODO: Añadir biblioteca de carga de imágenes (stb_image) en Fase 1.1
// Por ahora, LoadTexture es un stub

namespace MultiNinjaEspacial::Infrastructure::Rendering {

OpenGLRenderer::OpenGLRenderer() {
    spdlog::info("OpenGLRenderer creado");
}

OpenGLRenderer::~OpenGLRenderer() {
    Shutdown();
}

bool OpenGLRenderer::Initialize(int width, int height) {
    m_Width = width;
    m_Height = height;

    spdlog::info("Inicializando OpenGLRenderer ({}x{})", width, height);

    // Inicializar GLEW (carga extensiones de OpenGL)
    GLenum err = glewInit();
    if (err != GLEW_OK) {
        spdlog::error("GLEW Init failed: {}", reinterpret_cast<const char*>(glewGetErrorString(err)));
        return false;
    }

    // Verificar versión de OpenGL
    const GLubyte* version = glGetString(GL_VERSION);
    spdlog::info("OpenGL Version: {}", reinterpret_cast<const char*>(version));

    // Verificar que tengamos al menos OpenGL 3.3
    if (!GLEW_VERSION_3_3) {
        spdlog::error("OpenGL 3.3+ requerido");
        return false;
    }

    // Configurar estados de OpenGL
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // Deshabilitar depth test (2D)
    glDisable(GL_DEPTH_TEST);

    // Deshabilitar face culling (2D)
    glDisable(GL_CULL_FACE);

    // Crear projection matrix ortográfica
    // Coordenadas: (0, 0) = top-left, (width, height) = bottom-right
    m_ProjectionMatrix = glm::ortho(
        0.0f, static_cast<float>(width),
        static_cast<float>(height), 0.0f,
        -1.0f, 1.0f
    );

    // Inicializar shaders
    if (!InitializeShaders()) {
        spdlog::error("Fallo al inicializar shaders");
        return false;
    }

    // Inicializar buffers
    if (!InitializeBuffers()) {
        spdlog::error("Fallo al inicializar buffers");
        return false;
    }

    spdlog::info("OpenGLRenderer inicializado correctamente");
    return true;
}

void OpenGLRenderer::Shutdown() {
    spdlog::info("Cerrando OpenGLRenderer");

    // Liberar texturas
    for (auto& [id, handle] : m_Textures) {
        glDeleteTextures(1, &handle);
    }
    m_Textures.clear();

    // Liberar buffers
    if (m_QuadVBO != 0) {
        glDeleteBuffers(1, &m_QuadVBO);
        m_QuadVBO = 0;
    }
    if (m_QuadVAO != 0) {
        glDeleteVertexArrays(1, &m_QuadVAO);
        m_QuadVAO = 0;
    }

    // Shader se libera automáticamente (unique_ptr)
    m_SpriteShader.reset();
}

void OpenGLRenderer::Clear(const glm::vec4& color) {
    glClearColor(color.r, color.g, color.b, color.a);
    glClear(GL_COLOR_BUFFER_BIT);
}

void OpenGLRenderer::Present() {
    // El swap de buffers se hace en GameWindow (SDL_GL_SwapWindow)
    // Aquí solo reseteamos stats
    ResetStats();
}

void OpenGLRenderer::SetViewport(int x, int y, int width, int height) {
    glViewport(x, y, width, height);
    m_Width = width;
    m_Height = height;

    // Actualizar projection matrix
    m_ProjectionMatrix = glm::ortho(
        0.0f, static_cast<float>(width),
        static_cast<float>(height), 0.0f,
        -1.0f, 1.0f
    );
}

void OpenGLRenderer::DrawSprite(
    const std::string& textureId,
    const glm::vec2& position,
    const glm::vec2& size,
    float rotation,
    const glm::vec4& color
) {
    // Buscar textura
    auto it = m_Textures.find(textureId);
    GLuint textureHandle = (it != m_Textures.end()) ? it->second : 0;

    // Activar shader
    m_SpriteShader->Use();

    // Construir model matrix (Transform + Rotate + Scale)
    glm::mat4 model = glm::mat4(1.0f);
    model = glm::translate(model, glm::vec3(position, 0.0f));
    model = glm::translate(model, glm::vec3(0.5f * size.x, 0.5f * size.y, 0.0f)); // Rotar desde centro
    model = glm::rotate(model, glm::radians(rotation), glm::vec3(0.0f, 0.0f, 1.0f));
    model = glm::translate(model, glm::vec3(-0.5f * size.x, -0.5f * size.y, 0.0f));
    model = glm::scale(model, glm::vec3(size, 1.0f));

    // Enviar uniforms al shader
    m_SpriteShader->SetMatrix4("uProjection", m_ProjectionMatrix);
    m_SpriteShader->SetMatrix4("uModel", model);
    m_SpriteShader->SetVector4f("uColor", color);

    // Bind texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    m_SpriteShader->SetInteger("uTexture", 0);

    // Dibujar quad
    glBindVertexArray(m_QuadVAO);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArray(0);

    // Actualizar stats
    m_Stats.drawCalls++;
    m_Stats.triangles += 2;
    m_Stats.vertices += 6;
}

bool OpenGLRenderer::LoadTexture(const std::string& id, const std::string& filepath) {
    // TODO: Implementar carga de imágenes con stb_image
    // Por ahora, crear textura dummy blanca

    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);

    // Textura blanca 1x1
    unsigned char whitePixel[] = {255, 255, 255, 255};
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE, whitePixel);

    // Configurar parámetros de textura
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    m_Textures[id] = texture;

    spdlog::info("Textura cargada (dummy): {} → {}", id, filepath);
    return true;
}

void OpenGLRenderer::UnloadTexture(const std::string& id) {
    auto it = m_Textures.find(id);
    if (it != m_Textures.end()) {
        glDeleteTextures(1, &it->second);
        m_Textures.erase(it);
        spdlog::info("Textura descargada: {}", id);
    }
}

std::string OpenGLRenderer::GetName() const {
    const GLubyte* version = glGetString(GL_VERSION);
    return std::string("OpenGL ") + reinterpret_cast<const char*>(version);
}

IRenderer::RenderStats OpenGLRenderer::GetStats() const {
    return m_Stats;
}

void OpenGLRenderer::ResetStats() {
    m_Stats = RenderStats{};
}

bool OpenGLRenderer::InitializeShaders() {
    // Vertex shader simple para sprites 2D
    const char* vertexShaderSrc = R"(
        #version 330 core
        layout (location = 0) in vec2 aPosition;
        layout (location = 1) in vec2 aTexCoord;

        out vec2 vTexCoord;

        uniform mat4 uProjection;
        uniform mat4 uModel;

        void main() {
            vTexCoord = aTexCoord;
            gl_Position = uProjection * uModel * vec4(aPosition, 0.0, 1.0);
        }
    )";

    // Fragment shader simple para sprites 2D
    const char* fragmentShaderSrc = R"(
        #version 330 core
        in vec2 vTexCoord;
        out vec4 FragColor;

        uniform sampler2D uTexture;
        uniform vec4 uColor;

        void main() {
            FragColor = texture(uTexture, vTexCoord) * uColor;
        }
    )";

    m_SpriteShader = std::make_unique<ShaderProgram>();
    return m_SpriteShader->CompileFromSource(vertexShaderSrc, fragmentShaderSrc);
}

bool OpenGLRenderer::InitializeBuffers() {
    CreateQuadGeometry();
    return true;
}

void OpenGLRenderer::CreateQuadGeometry() {
    // Vértices de un quad (2 triángulos)
    // Formato: {posX, posY, texU, texV}
    float vertices[] = {
        // Triángulo 1
        0.0f, 0.0f,  0.0f, 0.0f, // Top-left
        1.0f, 0.0f,  1.0f, 0.0f, // Top-right
        1.0f, 1.0f,  1.0f, 1.0f, // Bottom-right

        // Triángulo 2
        1.0f, 1.0f,  1.0f, 1.0f, // Bottom-right
        0.0f, 1.0f,  0.0f, 1.0f, // Bottom-left
        0.0f, 0.0f,  0.0f, 0.0f  // Top-left
    };

    // Crear VAO y VBO
    glGenVertexArrays(1, &m_QuadVAO);
    glGenBuffers(1, &m_QuadVBO);

    glBindVertexArray(m_QuadVAO);
    glBindBuffer(GL_ARRAY_BUFFER, m_QuadVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // Atributo 0: Position (vec2)
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)0);

    // Atributo 1: TexCoord (vec2)
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), (void*)(2 * sizeof(float)));

    glBindVertexArray(0);

    spdlog::debug("Geometría de quad creada (VAO: {}, VBO: {})", m_QuadVAO, m_QuadVBO);
}

} // namespace MultiNinjaEspacial::Infrastructure::Rendering
