// ============================================================================
// Transform Component - Componente de Posición y Rotación
// ============================================================================
// Representa la posición, rotación y escala de una entidad en el espacio 2D
// Usado por: Todos los objetos del juego (jugadores, enemigos, proyectiles)
// ============================================================================

#pragma once

#include <glm/glm.hpp>

namespace MultiNinjaEspacial::Core::Components {

/**
 * @brief Componente de transformación espacial
 *
 * Almacena posición, rotación y escala en 2D.
 * En un ECS, este es un "dato puro" sin lógica.
 *
 * Ejemplo de uso:
 * ```cpp
 * auto entity = registry.create();
 * registry.emplace<Transform>(entity,
 *     glm::vec2{100.0f, 200.0f},  // posición
 *     45.0f,                       // rotación en grados
 *     glm::vec2{1.0f, 1.0f}        // escala
 * );
 * ```
 */
struct Transform {
    // Posición en coordenadas del mundo (x, y)
    // Origen: esquina superior izquierda de la pantalla
    glm::vec2 position{0.0f, 0.0f};

    // Rotación en grados (0-360)
    // 0° = derecha, 90° = abajo, 180° = izquierda, 270° = arriba
    float rotation{0.0f};

    // Escala (1.0 = tamaño original)
    // Permite hacer sprites más grandes (>1.0) o pequeños (<1.0)
    glm::vec2 scale{1.0f, 1.0f};

    /**
     * @brief Constructor por defecto: entidad en origen sin rotación
     */
    Transform() = default;

    /**
     * @brief Constructor con posición inicial
     * @param pos Posición inicial (x, y)
     */
    explicit Transform(const glm::vec2& pos)
        : position(pos) {}

    /**
     * @brief Constructor completo
     * @param pos Posición inicial
     * @param rot Rotación inicial en grados
     * @param scl Escala inicial
     */
    Transform(const glm::vec2& pos, float rot, const glm::vec2& scl)
        : position(pos), rotation(rot), scale(scl) {}

    /**
     * @brief Calcula la matriz de transformación 2D para rendering
     * @return Matriz 3x3 de transformación (posición + rotación + escala)
     *
     * Esta matriz se usa en los shaders para transformar vértices.
     * Orden: Escala → Rotación → Traslación
     */
    [[nodiscard]] glm::mat3 GetMatrix() const {
        // Matriz de traslación
        glm::mat3 translation = glm::mat3(1.0f);
        translation[2][0] = position.x;
        translation[2][1] = position.y;

        // Matriz de rotación (convertir grados a radianes)
        float rad = glm::radians(rotation);
        float cosR = std::cos(rad);
        float sinR = std::sin(rad);
        glm::mat3 rotationMat = glm::mat3(
            cosR,  sinR, 0.0f,
            -sinR, cosR, 0.0f,
            0.0f,  0.0f, 1.0f
        );

        // Matriz de escala
        glm::mat3 scaleMat = glm::mat3(
            scale.x, 0.0f,    0.0f,
            0.0f,    scale.y, 0.0f,
            0.0f,    0.0f,    1.0f
        );

        // Combinar: T * R * S
        return translation * rotationMat * scaleMat;
    }
};

} // namespace MultiNinjaEspacial::Core::Components
