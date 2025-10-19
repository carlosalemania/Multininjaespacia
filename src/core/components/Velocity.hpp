// ============================================================================
// Velocity Component - Componente de Velocidad
// ============================================================================
// Representa la velocidad lineal y angular de una entidad
// Usado por: MovementSystem para actualizar Transform cada frame
// ============================================================================

#pragma once

#include <glm/glm.hpp>

namespace MultiNinjaEspacial::Core::Components {

/**
 * @brief Componente de velocidad (lineal y angular)
 *
 * Almacena velocidad en píxeles/segundo y rotación en grados/segundo.
 * El MovementSystem usa este componente para actualizar Transform.
 *
 * Ejemplo de uso:
 * ```cpp
 * auto entity = registry.create();
 * registry.emplace<Velocity>(entity,
 *     glm::vec2{100.0f, 0.0f},  // moverse 100 píxeles/seg a la derecha
 *     0.0f                       // sin rotación
 * );
 * ```
 */
struct Velocity {
    // Velocidad lineal en píxeles por segundo (x, y)
    // Ejemplo: {100.0f, 0.0f} = moverse a la derecha a 100 px/s
    glm::vec2 linear{0.0f, 0.0f};

    // Velocidad angular en grados por segundo
    // Positivo = rotar en sentido horario
    // Negativo = rotar en sentido antihorario
    float angular{0.0f};

    /**
     * @brief Constructor por defecto: entidad estática
     */
    Velocity() = default;

    /**
     * @brief Constructor con velocidad lineal
     * @param lin Velocidad lineal inicial
     */
    explicit Velocity(const glm::vec2& lin)
        : linear(lin) {}

    /**
     * @brief Constructor completo
     * @param lin Velocidad lineal
     * @param ang Velocidad angular en grados/segundo
     */
    Velocity(const glm::vec2& lin, float ang)
        : linear(lin), angular(ang) {}

    /**
     * @brief Calcula la velocidad total (magnitud del vector)
     * @return Velocidad escalar en píxeles/segundo
     */
    [[nodiscard]] float GetSpeed() const {
        return glm::length(linear);
    }

    /**
     * @brief Obtiene la dirección normalizada del movimiento
     * @return Vector unitario de dirección (o {0,0} si velocidad es 0)
     */
    [[nodiscard]] glm::vec2 GetDirection() const {
        float speed = GetSpeed();
        if (speed > 0.0001f) {
            return linear / speed;
        }
        return glm::vec2{0.0f, 0.0f};
    }
};

} // namespace MultiNinjaEspacial::Core::Components
