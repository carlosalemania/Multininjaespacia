// ============================================================================
// Registry - Implementación
// ============================================================================

#include "Registry.hpp"

namespace MultiNinjaEspacial::Core::ECS {

Registry::Registry() {
    spdlog::info("Registry inicializado");
}

Registry::~Registry() {
    spdlog::info("Registry destruido - {} entidades activas", GetEntityCount());
}

entt::entity Registry::CreateEntity(const std::string& name) {
    auto entity = m_Registry.create();

    // Asignar nombre si se proporcionó
    if (!name.empty()) {
        m_EntityNames[entity] = name;
        spdlog::debug("Entidad creada: {} (ID: {})", name, static_cast<uint32_t>(entity));
    } else {
        spdlog::trace("Entidad creada: ID {}", static_cast<uint32_t>(entity));
    }

    m_EntityCounter++;
    return entity;
}

void Registry::DestroyEntity(entt::entity entity) {
    if (!IsValid(entity)) {
        spdlog::warn("Intentando destruir entidad inválida");
        return;
    }

    // Log si tiene nombre
    auto it = m_EntityNames.find(entity);
    if (it != m_EntityNames.end()) {
        spdlog::debug("Entidad destruida: {} (ID: {})", it->second, static_cast<uint32_t>(entity));
        m_EntityNames.erase(it);
    } else {
        spdlog::trace("Entidad destruida: ID {}", static_cast<uint32_t>(entity));
    }

    m_Registry.destroy(entity);
}

bool Registry::IsValid(entt::entity entity) const {
    return m_Registry.valid(entity);
}

void Registry::Clear() {
    size_t count = GetEntityCount();
    m_Registry.clear();
    m_EntityNames.clear();
    spdlog::info("Registry limpiado - {} entidades destruidas", count);
}

size_t Registry::GetEntityCount() const {
    // EnTT usa size() para obtener el número de entidades vivas
    return m_Registry.size();
}

void Registry::PrintStats() const {
    spdlog::info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    spdlog::info("Registry Stats:");
    spdlog::info("  Entidades activas: {}", GetEntityCount());
    spdlog::info("  Entidades creadas (total): {}", m_EntityCounter);
    spdlog::info("  Entidades con nombre: {}", m_EntityNames.size());
    spdlog::info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
}

} // namespace MultiNinjaEspacial::Core::ECS
