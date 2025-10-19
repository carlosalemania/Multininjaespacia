// ============================================================================
// Movement System - Header
// ============================================================================

#pragma once

#include <entt/entt.hpp>

namespace MultiNinjaEspacial::Core::Systems {

/**
 * @brief Sistema que actualiza posiciones basándose en velocidades
 *
 * Este es un sistema "puro" sin estado (todos los métodos son estáticos).
 * Sigue el patrón de ECS: los datos están en componentes, la lógica en sistemas.
 */
class MovementSystem {
public:
    /**
     * @brief Actualiza todas las entidades con movimiento
     * @param registry Registro de EnTT
     * @param deltaTime Tiempo transcurrido en segundos
     */
    static void Update(entt::registry& registry, float deltaTime);

    /**
     * @brief Actualiza una entidad específica
     * @param registry Registro de EnTT
     * @param entity Entidad a actualizar
     * @param deltaTime Tiempo transcurrido en segundos
     */
    static void UpdateEntity(entt::registry& registry, entt::entity entity, float deltaTime);

    /**
     * @brief Limita velocidades al máximo especificado
     * @param registry Registro de EnTT
     * @param maxSpeed Velocidad lineal máxima (px/s)
     * @param maxAngularSpeed Velocidad angular máxima (deg/s)
     */
    static void ClampVelocities(entt::registry& registry, float maxSpeed, float maxAngularSpeed);
};

} // namespace MultiNinjaEspacial::Core::Systems
