// ============================================================================
// Entity - Wrapper simple sobre entt::entity
// ============================================================================
// Proporciona una interfaz orientada a objetos (opcional) sobre ECS
// Nota: En ECS puro no necesitas esto, pero facilita ciertos patrones
// ============================================================================

#include "Entity.hpp"

namespace MultiNinjaEspacial::Core::ECS {

Entity::Entity(entt::entity handle, Registry* registry)
    : m_Handle(handle), m_Registry(registry) {
}

Entity::~Entity() {
    // No destruir la entidad automáticamente - podría estar en uso
}

void Entity::Destroy() {
    if (m_Registry && IsValid()) {
        m_Registry->DestroyEntity(m_Handle);
        m_Handle = entt::null;
    }
}

bool Entity::IsValid() const {
    return m_Registry != nullptr &&
           m_Handle != entt::null &&
           m_Registry->IsValid(m_Handle);
}

} // namespace MultiNinjaEspacial::Core::ECS
