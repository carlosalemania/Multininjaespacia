// ============================================================================
// Movement System - Sistema de Movimiento
// ============================================================================
// Actualiza la posición de entidades basándose en su velocidad
// Opera sobre: Transform + Velocity
// ============================================================================

#include "MovementSystem.hpp"
#include "../components/Transform.hpp"
#include "../components/Velocity.hpp"

namespace MultiNinjaEspacial::Core::Systems {

/**
 * @brief Actualiza todas las entidades con Transform y Velocity
 * @param registry Registro de EnTT con todas las entidades
 * @param deltaTime Tiempo transcurrido desde el último frame (en segundos)
 *
 * Proceso:
 * 1. Busca todas las entidades con Transform + Velocity
 * 2. Para cada una, actualiza position += velocity * deltaTime
 * 3. Actualiza rotation += angularVelocity * deltaTime
 *
 * Ejemplo de uso:
 * ```cpp
 * // En el game loop
 * float deltaTime = 0.016f; // ~60 FPS
 * MovementSystem::Update(registry, deltaTime);
 * ```
 */
void MovementSystem::Update(entt::registry& registry, float deltaTime) {
    // Obtener view de todas las entidades con Transform Y Velocity
    // EnTT optimiza esto automáticamente (cache-friendly)
    auto view = registry.view<Components::Transform, Components::Velocity>();

    // Iterar sobre todas las entidades que cumplen
    for (auto entity : view) {
        // Obtener referencias a los componentes
        auto& transform = view.get<Components::Transform>(entity);
        auto& velocity = view.get<Components::Velocity>(entity);

        // Actualizar posición: p' = p + v * dt
        // Ejemplo: si velocity.linear = {100, 0} y dt = 0.016
        //          entonces se mueve 1.6 píxeles a la derecha
        transform.position += velocity.linear * deltaTime;

        // Actualizar rotación: r' = r + ω * dt
        transform.rotation += velocity.angular * deltaTime;

        // Normalizar rotación al rango [0, 360)
        // Evita overflow después de muchas rotaciones
        while (transform.rotation >= 360.0f) {
            transform.rotation -= 360.0f;
        }
        while (transform.rotation < 0.0f) {
            transform.rotation += 360.0f;
        }
    }
}

/**
 * @brief Actualiza una entidad específica
 * @param registry Registro de EnTT
 * @param entity Entidad a actualizar
 * @param deltaTime Delta time en segundos
 *
 * Versión single-entity para casos donde solo necesitas
 * actualizar una entidad específica.
 */
void MovementSystem::UpdateEntity(entt::registry& registry, entt::entity entity, float deltaTime) {
    // Verificar que la entidad tiene los componentes necesarios
    if (!registry.all_of<Components::Transform, Components::Velocity>(entity)) {
        return;
    }

    auto& transform = registry.get<Components::Transform>(entity);
    auto& velocity = registry.get<Components::Velocity>(entity);

    transform.position += velocity.linear * deltaTime;
    transform.rotation += velocity.angular * deltaTime;

    // Normalizar rotación
    while (transform.rotation >= 360.0f) {
        transform.rotation -= 360.0f;
    }
    while (transform.rotation < 0.0f) {
        transform.rotation += 360.0f;
    }
}

/**
 * @brief Aplica límites de velocidad máxima a todas las entidades
 * @param registry Registro de EnTT
 * @param maxSpeed Velocidad lineal máxima en píxeles/segundo
 * @param maxAngularSpeed Velocidad angular máxima en grados/segundo
 *
 * Útil para evitar que entidades se muevan demasiado rápido.
 * Llamar esto ANTES de Update() en el game loop.
 */
void MovementSystem::ClampVelocities(entt::registry& registry, float maxSpeed, float maxAngularSpeed) {
    auto view = registry.view<Components::Velocity>();

    for (auto entity : view) {
        auto& velocity = view.get<Components::Velocity>(entity);

        // Limitar velocidad lineal
        float speed = velocity.GetSpeed();
        if (speed > maxSpeed) {
            // Normalizar y multiplicar por velocidad máxima
            velocity.linear = (velocity.linear / speed) * maxSpeed;
        }

        // Limitar velocidad angular
        if (velocity.angular > maxAngularSpeed) {
            velocity.angular = maxAngularSpeed;
        } else if (velocity.angular < -maxAngularSpeed) {
            velocity.angular = -maxAngularSpeed;
        }
    }
}

} // namespace MultiNinjaEspacial::Core::Systems
