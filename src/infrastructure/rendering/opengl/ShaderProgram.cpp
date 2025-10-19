// ============================================================================
// Shader Program - Implementación
// ============================================================================

#include "ShaderProgram.hpp"
#include <spdlog/spdlog.h>
#include <glm/gtc/type_ptr.hpp>
#include <fstream>
#include <sstream>

namespace MultiNinjaEspacial::Infrastructure::Rendering {

ShaderProgram::ShaderProgram() = default;

ShaderProgram::~ShaderProgram() {
    if (m_ProgramID != 0) {
        glDeleteProgram(m_ProgramID);
    }
}

bool ShaderProgram::CompileFromSource(const char* vertexSrc, const char* fragmentSrc) {
    // Compilar vertex shader
    GLuint vertexShader = CompileShader(GL_VERTEX_SHADER, vertexSrc);
    if (vertexShader == 0) {
        return false;
    }

    // Compilar fragment shader
    GLuint fragmentShader = CompileShader(GL_FRAGMENT_SHADER, fragmentSrc);
    if (fragmentShader == 0) {
        glDeleteShader(vertexShader);
        return false;
    }

    // Crear program y linkar
    m_ProgramID = glCreateProgram();
    glAttachShader(m_ProgramID, vertexShader);
    glAttachShader(m_ProgramID, fragmentShader);
    glLinkProgram(m_ProgramID);

    // Verificar linkeo
    GLint success;
    glGetProgramiv(m_ProgramID, GL_LINK_STATUS, &success);
    if (!success) {
        GLchar infoLog[1024];
        glGetProgramInfoLog(m_ProgramID, 1024, nullptr, infoLog);
        spdlog::error("Shader Program link failed: {}", infoLog);

        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        glDeleteProgram(m_ProgramID);
        m_ProgramID = 0;
        return false;
    }

    // Los shaders ya están linkeados, podemos borrarlos
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    spdlog::info("Shader program compilado y linkeado (ID: {})", m_ProgramID);
    return true;
}

bool ShaderProgram::CompileFromFiles(const std::string& vertexPath, const std::string& fragmentPath) {
    // Leer vertex shader
    std::ifstream vFile(vertexPath);
    if (!vFile.is_open()) {
        spdlog::error("No se pudo abrir vertex shader: {}", vertexPath);
        return false;
    }
    std::stringstream vStream;
    vStream << vFile.rdbuf();
    std::string vSrc = vStream.str();

    // Leer fragment shader
    std::ifstream fFile(fragmentPath);
    if (!fFile.is_open()) {
        spdlog::error("No se pudo abrir fragment shader: {}", fragmentPath);
        return false;
    }
    std::stringstream fStream;
    fStream << fFile.rdbuf();
    std::string fSrc = fStream.str();

    return CompileFromSource(vSrc.c_str(), fSrc.c_str());
}

void ShaderProgram::Use() const {
    glUseProgram(m_ProgramID);
}

void ShaderProgram::SetInteger(const std::string& name, int value) {
    glUniform1i(GetUniformLocation(name), value);
}

void ShaderProgram::SetFloat(const std::string& name, float value) {
    glUniform1f(GetUniformLocation(name), value);
}

void ShaderProgram::SetVector2f(const std::string& name, const glm::vec2& value) {
    glUniform2f(GetUniformLocation(name), value.x, value.y);
}

void ShaderProgram::SetVector3f(const std::string& name, const glm::vec3& value) {
    glUniform3f(GetUniformLocation(name), value.x, value.y, value.z);
}

void ShaderProgram::SetVector4f(const std::string& name, const glm::vec4& value) {
    glUniform4f(GetUniformLocation(name), value.x, value.y, value.z, value.w);
}

void ShaderProgram::SetMatrix4(const std::string& name, const glm::mat4& value) {
    glUniformMatrix4fv(GetUniformLocation(name), 1, GL_FALSE, glm::value_ptr(value));
}

GLint ShaderProgram::GetUniformLocation(const std::string& name) {
    // Buscar en cache
    auto it = m_UniformLocationCache.find(name);
    if (it != m_UniformLocationCache.end()) {
        return it->second;
    }

    // No está en cache, obtener de OpenGL
    GLint location = glGetUniformLocation(m_ProgramID, name.c_str());
    if (location == -1) {
        spdlog::warn("Uniform '{}' no encontrado en shader", name);
    }

    // Guardar en cache
    m_UniformLocationCache[name] = location;
    return location;
}

GLuint ShaderProgram::CompileShader(GLenum type, const char* source) {
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, nullptr);
    glCompileShader(shader);

    std::string typeStr = (type == GL_VERTEX_SHADER) ? "VERTEX" : "FRAGMENT";

    if (!CheckCompileErrors(shader, typeStr)) {
        glDeleteShader(shader);
        return 0;
    }

    return shader;
}

bool ShaderProgram::CheckCompileErrors(GLuint shader, const std::string& type) {
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);

    if (!success) {
        GLchar infoLog[1024];
        glGetShaderInfoLog(shader, 1024, nullptr, infoLog);
        spdlog::error("{} Shader compile failed: {}", type, infoLog);
        return false;
    }

    return true;
}

} // namespace MultiNinjaEspacial::Infrastructure::Rendering
