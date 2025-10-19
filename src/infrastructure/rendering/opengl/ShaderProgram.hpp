// ============================================================================
// Shader Program - Wrapper sobre OpenGL Shaders
// ============================================================================
// Facilita compilación y uso de shaders
// ============================================================================

#pragma once

#include <GL/glew.h>
#include <glm/glm.hpp>
#include <string>
#include <unordered_map>

namespace MultiNinjaEspacial::Infrastructure::Rendering {

/**
 * @brief Wrapper sobre OpenGL shader program
 *
 * Facilita:
 * - Compilación de shaders
 * - Linkeo de program
 * - Seteo de uniforms con cache
 *
 * Ejemplo de uso:
 * ```cpp
 * ShaderProgram shader;
 * shader.CompileFromSource(vertexSrc, fragmentSrc);
 *
 * shader.Use();
 * shader.SetMatrix4("uProjection", projMatrix);
 * shader.SetVector4f("uColor", {1, 0, 0, 1});
 * ```
 */
class ShaderProgram {
public:
    ShaderProgram();
    ~ShaderProgram();

    /**
     * @brief Compila shaders desde source code
     * @param vertexSrc Código del vertex shader
     * @param fragmentSrc Código del fragment shader
     * @return true si compilación exitosa
     */
    bool CompileFromSource(const char* vertexSrc, const char* fragmentSrc);

    /**
     * @brief Compila shaders desde archivos
     * @param vertexPath Path al vertex shader
     * @param fragmentPath Path al fragment shader
     * @return true si compilación exitosa
     */
    bool CompileFromFiles(const std::string& vertexPath, const std::string& fragmentPath);

    /**
     * @brief Activa este shader program
     */
    void Use() const;

    /**
     * @brief Obtiene el ID del program
     * @return OpenGL program handle
     */
    [[nodiscard]] GLuint GetID() const { return m_ProgramID; }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Setters de Uniforms
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    void SetInteger(const std::string& name, int value);
    void SetFloat(const std::string& name, float value);
    void SetVector2f(const std::string& name, const glm::vec2& value);
    void SetVector3f(const std::string& name, const glm::vec3& value);
    void SetVector4f(const std::string& name, const glm::vec4& value);
    void SetMatrix4(const std::string& name, const glm::mat4& value);

private:
    /**
     * @brief Obtiene location de un uniform (con cache)
     * @param name Nombre del uniform
     * @return Location de OpenGL
     */
    GLint GetUniformLocation(const std::string& name);

    /**
     * @brief Compila un shader individual
     * @param type GL_VERTEX_SHADER o GL_FRAGMENT_SHADER
     * @param source Código fuente
     * @return Shader handle (0 si fallo)
     */
    GLuint CompileShader(GLenum type, const char* source);

    /**
     * @brief Verifica errores de compilación
     * @param shader Shader handle
     * @param type Tipo de shader (para logging)
     * @return true si sin errores
     */
    bool CheckCompileErrors(GLuint shader, const std::string& type);

    // OpenGL program handle
    GLuint m_ProgramID{0};

    // Cache de uniform locations
    std::unordered_map<std::string, GLint> m_UniformLocationCache;
};

} // namespace MultiNinjaEspacial::Infrastructure::Rendering
