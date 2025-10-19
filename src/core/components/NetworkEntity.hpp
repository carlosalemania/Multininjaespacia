// ============================================================================
// NetworkEntity Component - Componente de Sincronización de Red
// ============================================================================
// Marca entidades que deben sincronizarse por la red en multijugador
// Usado por: NetworkSyncSystem para replicar estado entre clientes
// ============================================================================

#pragma once

#include <cstdint>

namespace MultiNinjaEspacial::Core::Components {

/**
 * @brief Componente para entidades replicadas por red
 *
 * Identifica entidades que necesitan sincronización en partidas multijugador.
 * Incluye:
 * - Network ID único
 * - Owner (quién controla la entidad)
 * - Authority (quién puede modificarla)
 *
 * Ejemplo de uso:
 * ```cpp
 * // Cliente 1 crea su jugador
 * auto player = registry.create();
 * registry.emplace<NetworkEntity>(player,
 *     1234,           // network ID asignado por servidor
 *     1,              // owner ID (cliente 1)
 *     true            // tiene autoridad
 * );
 *
 * // Cliente 2 recibe el jugador del cliente 1 (réplica)
 * auto remotePlayer = registry.create();
 * registry.emplace<NetworkEntity>(remotePlayer,
 *     1234,           // mismo network ID
 *     1,              // owner es cliente 1
 *     false           // NO tiene autoridad (solo renderiza)
 * );
 * ```
 */
struct NetworkEntity {
    // ID único de la entidad en la red (asignado por servidor)
    // Mismo ID en todos los clientes para la misma entidad
    uint32_t networkId{0};

    // ID del jugador/cliente que "posee" esta entidad
    // 0 = servidor, 1+ = clientes
    uint32_t ownerId{0};

    // Si esta instancia tiene autoridad para modificar la entidad
    // true = puede modificar y envía updates
    // false = solo recibe updates y renderiza
    bool hasAuthority{false};

    // Timestamp del último update recibido (para interpolar)
    uint64_t lastUpdateTime{0};

    // ¿Es un objeto controlado por el servidor? (NPC, items, etc.)
    bool serverControlled{false};

    /**
     * @brief Constructor por defecto: entidad local (no networked)
     */
    NetworkEntity() = default;

    /**
     * @brief Constructor para entidad networked
     * @param netId ID de red único
     * @param owner ID del owner
     * @param authority Si esta instancia tiene autoridad
     */
    NetworkEntity(uint32_t netId, uint32_t owner, bool authority)
        : networkId(netId), ownerId(owner), hasAuthority(authority) {}

    /**
     * @brief Verifica si esta entidad es local (controlada por este cliente)
     * @param localPlayerId ID del jugador local
     * @return true si el owner es el jugador local y tiene autoridad
     */
    [[nodiscard]] bool IsLocal(uint32_t localPlayerId) const {
        return ownerId == localPlayerId && hasAuthority;
    }

    /**
     * @brief Verifica si esta es una entidad remota (de otro cliente)
     * @param localPlayerId ID del jugador local
     * @return true si el owner es otro jugador
     */
    [[nodiscard]] bool IsRemote(uint32_t localPlayerId) const {
        return ownerId != localPlayerId;
    }

    /**
     * @brief Verifica si esta entidad necesita enviar updates a la red
     * @return true si tiene autoridad (es responsable de sincronizar)
     */
    [[nodiscard]] bool ShouldSendUpdates() const {
        return hasAuthority;
    }

    /**
     * @brief Actualiza el timestamp del último update recibido
     * @param timestamp Timestamp actual en milisegundos
     */
    void UpdateTimestamp(uint64_t timestamp) {
        lastUpdateTime = timestamp;
    }
};

} // namespace MultiNinjaEspacial::Core::Components
