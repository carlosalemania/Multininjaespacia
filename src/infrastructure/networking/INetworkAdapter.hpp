// ============================================================================
// INetworkAdapter - Interfaz abstracta de Networking (STUB)
// ============================================================================
// TODO: Implementar en Fase 2
// ============================================================================

#pragma once

namespace MultiNinjaEspacial::Infrastructure::Networking {

/**
 * @brief Interfaz abstracta para networking
 *
 * STUB: Para Fase 2 (Multijugador)
 */
class INetworkAdapter {
public:
    virtual ~INetworkAdapter() = default;

    virtual bool Initialize() = 0;
    virtual void Shutdown() = 0;
    virtual void Update() = 0;
};

} // namespace MultiNinjaEspacial::Infrastructure::Networking
