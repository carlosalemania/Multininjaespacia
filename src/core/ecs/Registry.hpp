// ============================================================================
// Registry - Wrapper sobre entt::registry
// ============================================================================
// Proporciona una capa de abstracción sobre EnTT con utilidades específicas
// del juego
// ============================================================================

#pragma once

#include <entt/entt.hpp>
#include <memory>
#include <spdlog/spdlog.h>

namespace MultiNinjaEspacial::Core::ECS {

/**
 * @brief Wrapper sobre entt::registry con funcionalidad adicional
 *
 * Extiende EnTT con:
 * - Logging automático de creación/destrucción de entidades
 * - Factories para entidades comunes (Player, Enemy, etc.)
 * - Helpers para debugging
 *
 * Ejemplo de uso:
 * ```cpp
 * Registry registry;
 *
 * // Crear entidad manualmente
 * auto entity = registry.CreateEntity("player");
 * registry.AddComponent<Transform>(entity, glm::vec2{100, 200});
 *
 * // O usar factory
 * auto player = registry.CreatePlayer(glm::vec2{100, 200});
 * ```
 */
class Registry {
public:
    /**
     * @brief Constructor
     */
    Registry();

    /**
     * @brief Destructor
     */
    ~Registry();

    /**
     * @brief Obtiene el registry nativo de EnTT
     * @return Referencia al entt::registry interno
     *
     * Úsalo cuando necesites acceso directo a funcionalidad de EnTT.
     */
    [[nodiscard]] entt::registry& GetNative() { return m_Registry; }
    [[nodiscard]] const entt::registry& GetNative() const { return m_Registry; }

    /**
     * @brief Crea una nueva entidad con nombre opcional
     * @param name Nombre para debugging (opcional)
     * @return Handle a la entidad creada
     */
    entt::entity CreateEntity(const std::string& name = "");

    /**
     * @brief Destruye una entidad y todos sus componentes
     * @param entity Entidad a destruir
     */
    void DestroyEntity(entt::entity entity);

    /**
     * @brief Verifica si una entidad existe (es válida)
     * @param entity Entidad a verificar
     * @return true si la entidad existe
     */
    [[nodiscard]] bool IsValid(entt::entity entity) const;

    /**
     * @brief Añade un componente a una entidad
     * @tparam T Tipo de componente
     * @tparam Args Tipos de argumentos del constructor
     * @param entity Entidad objetivo
     * @param args Argumentos para construir el componente
     * @return Referencia al componente añadido
     */
    template<typename T, typename... Args>
    T& AddComponent(entt::entity entity, Args&&... args) {
        if (!IsValid(entity)) {
            spdlog::error("Registry::AddComponent - Entidad inválida");
            throw std::runtime_error("Cannot add component to invalid entity");
        }

        spdlog::trace("Registry::AddComponent<{}> a entidad {}",
                     typeid(T).name(), static_cast<uint32_t>(entity));

        return m_Registry.emplace<T>(entity, std::forward<Args>(args)...);
    }

    /**
     * @brief Obtiene un componente de una entidad
     * @tparam T Tipo de componente
     * @param entity Entidad objetivo
     * @return Referencia al componente
     */
    template<typename T>
    T& GetComponent(entt::entity entity) {
        if (!m_Registry.all_of<T>(entity)) {
            spdlog::error("Registry::GetComponent - Entidad {} no tiene componente {}",
                         static_cast<uint32_t>(entity), typeid(T).name());
            throw std::runtime_error("Entity does not have component");
        }
        return m_Registry.get<T>(entity);
    }

    /**
     * @brief Verifica si una entidad tiene un componente
     * @tparam T Tipo de componente
     * @param entity Entidad a verificar
     * @return true si la entidad tiene el componente
     */
    template<typename T>
    [[nodiscard]] bool HasComponent(entt::entity entity) const {
        return m_Registry.all_of<T>(entity);
    }

    /**
     * @brief Elimina un componente de una entidad
     * @tparam T Tipo de componente
     * @param entity Entidad objetivo
     */
    template<typename T>
    void RemoveComponent(entt::entity entity) {
        if (m_Registry.all_of<T>(entity)) {
            m_Registry.remove<T>(entity);
            spdlog::trace("Registry::RemoveComponent<{}> de entidad {}",
                         typeid(T).name(), static_cast<uint32_t>(entity));
        }
    }

    /**
     * @brief Limpia el registry (destruye todas las entidades)
     */
    void Clear();

    /**
     * @brief Obtiene el número de entidades activas
     * @return Cantidad de entidades
     */
    [[nodiscard]] size_t GetEntityCount() const;

    /**
     * @brief Imprime estadísticas de debugging
     */
    void PrintStats() const;

private:
    // Registry nativo de EnTT
    entt::registry m_Registry;

    // Contador de entidades creadas (para IDs únicos en debugging)
    uint64_t m_EntityCounter{0};

    // Mapa de nombres de entidades (solo para debugging)
    std::unordered_map<entt::entity, std::string> m_EntityNames;
};

} // namespace MultiNinjaEspacial::Core::ECS
