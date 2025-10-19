// ============================================================================
// Entity - Wrapper opcional sobre entt::entity
// ============================================================================
// Proporciona una interfaz OOP para trabajar con entidades
// NOTA: En ECS puro esto NO es necesario, pero facilita ciertos casos de uso
// ============================================================================

#pragma once

#include <entt/entt.hpp>
#include "Registry.hpp"

namespace MultiNinjaEspacial::Core::ECS {

/**
 * @brief Wrapper RAII-style sobre entt::entity
 *
 * Proporciona interfaz orientada a objetos para trabajar con entidades.
 * Útil cuando prefieres "entity.AddComponent<T>()" en lugar de "registry.emplace<T>(entity)".
 *
 * IMPORTANTE: Esto es OPCIONAL. Puedes usar entt::entity directamente.
 *
 * Ejemplo de uso:
 * ```cpp
 * Registry registry;
 *
 * // Estilo 1: ECS puro (recomendado para performance)
 * auto e = registry.CreateEntity("player");
 * registry.AddComponent<Transform>(e, glm::vec2{0, 0});
 *
 * // Estilo 2: Wrapper OOP (más legible, ligero overhead)
 * Entity player = registry.CreateEntity("player");
 * player.AddComponent<Transform>(glm::vec2{0, 0});
 * ```
 */
class Entity {
public:
    /**
     * @brief Constructor
     * @param handle Handle de EnTT
     * @param registry Puntero al registry
     */
    Entity(entt::entity handle, Registry* registry);

    /**
     * @brief Destructor (NO destruye la entidad automáticamente)
     */
    ~Entity();

    /**
     * @brief Obtiene el handle nativo de EnTT
     * @return entt::entity handle
     */
    [[nodiscard]] entt::entity GetHandle() const { return m_Handle; }

    /**
     * @brief Obtiene el registry asociado
     * @return Puntero al registry
     */
    [[nodiscard]] Registry* GetRegistry() const { return m_Registry; }

    /**
     * @brief Añade un componente a esta entidad
     * @tparam T Tipo de componente
     * @tparam Args Tipos de argumentos del constructor
     * @param args Argumentos para construir el componente
     * @return Referencia al componente añadido
     */
    template<typename T, typename... Args>
    T& AddComponent(Args&&... args) {
        return m_Registry->AddComponent<T>(m_Handle, std::forward<Args>(args)...);
    }

    /**
     * @brief Obtiene un componente de esta entidad
     * @tparam T Tipo de componente
     * @return Referencia al componente
     */
    template<typename T>
    T& GetComponent() {
        return m_Registry->GetComponent<T>(m_Handle);
    }

    /**
     * @brief Verifica si esta entidad tiene un componente
     * @tparam T Tipo de componente
     * @return true si tiene el componente
     */
    template<typename T>
    [[nodiscard]] bool HasComponent() const {
        return m_Registry->HasComponent<T>(m_Handle);
    }

    /**
     * @brief Elimina un componente de esta entidad
     * @tparam T Tipo de componente
     */
    template<typename T>
    void RemoveComponent() {
        m_Registry->RemoveComponent<T>(m_Handle);
    }

    /**
     * @brief Destruye esta entidad
     */
    void Destroy();

    /**
     * @brief Verifica si esta entidad es válida
     * @return true si la entidad existe en el registry
     */
    [[nodiscard]] bool IsValid() const;

    /**
     * @brief Operador de conversión a bool (para if checks)
     */
    explicit operator bool() const { return IsValid(); }

    /**
     * @brief Operador de comparación
     */
    bool operator==(const Entity& other) const {
        return m_Handle == other.m_Handle && m_Registry == other.m_Registry;
    }

    bool operator!=(const Entity& other) const {
        return !(*this == other);
    }

private:
    entt::entity m_Handle{entt::null};
    Registry* m_Registry{nullptr};
};

} // namespace MultiNinjaEspacial::Core::ECS
