// ============================================================================
// Health Component - Componente de Salud/Vida
// ============================================================================
// Representa puntos de vida de una entidad
// Usado por: Jugadores, enemigos, objetos destructibles
// ============================================================================

#pragma once

#include <algorithm>

namespace MultiNinjaEspacial::Core::Components {

/**
 * @brief Componente de puntos de vida
 *
 * Gestiona HP actual y máximo de entidades.
 * Útil para sistemas de combate y gameplay.
 *
 * Ejemplo de uso:
 * ```cpp
 * auto player = registry.create();
 * registry.emplace<Health>(player, 100, 100);  // 100/100 HP
 *
 * // Recibir daño
 * auto& hp = registry.get<Health>(player);
 * hp.TakeDamage(25);  // ahora 75/100
 *
 * // Curar
 * hp.Heal(10);  // ahora 85/100
 *
 * // Verificar muerte
 * if (hp.IsDead()) {
 *     registry.destroy(player);
 * }
 * ```
 */
struct Health {
    // Puntos de vida actuales
    int current{100};

    // Puntos de vida máximos
    int maximum{100};

    // Invulnerabilidad temporal (frames restantes)
    // Útil para evitar "instant death" por múltiples hits simultáneos
    int invulnerabilityFrames{0};

    /**
     * @brief Constructor por defecto: 100 HP
     */
    Health() = default;

    /**
     * @brief Constructor con HP específico
     * @param hp HP inicial (también se usa como máximo)
     */
    explicit Health(int hp)
        : current(hp), maximum(hp) {}

    /**
     * @brief Constructor completo
     * @param cur HP actual
     * @param max HP máximo
     */
    Health(int cur, int max)
        : current(std::min(cur, max)), maximum(max) {}

    /**
     * @brief Aplica daño a la entidad
     * @param amount Cantidad de daño (se resta del HP actual)
     * @return true si la entidad murió por este daño
     */
    bool TakeDamage(int amount) {
        // No aplicar daño si hay invulnerabilidad activa
        if (invulnerabilityFrames > 0) {
            return false;
        }

        current -= amount;
        if (current < 0) {
            current = 0;
        }

        return IsDead();
    }

    /**
     * @brief Cura a la entidad
     * @param amount Cantidad de curación (se suma al HP, sin pasar del máximo)
     */
    void Heal(int amount) {
        current += amount;
        if (current > maximum) {
            current = maximum;
        }
    }

    /**
     * @brief Restaura HP al máximo
     */
    void FullHeal() {
        current = maximum;
    }

    /**
     * @brief Verifica si la entidad está muerta
     * @return true si HP actual <= 0
     */
    [[nodiscard]] bool IsDead() const {
        return current <= 0;
    }

    /**
     * @brief Verifica si la entidad está a máxima vida
     * @return true si HP actual == HP máximo
     */
    [[nodiscard]] bool IsFullHealth() const {
        return current >= maximum;
    }

    /**
     * @brief Obtiene el porcentaje de vida (0.0 - 1.0)
     * @return Fracción de vida actual/máxima
     *
     * Útil para barras de vida:
     * ```cpp
     * float barWidth = 100.0f * health.GetHealthPercentage();
     * ```
     */
    [[nodiscard]] float GetHealthPercentage() const {
        if (maximum <= 0) return 0.0f;
        return static_cast<float>(current) / static_cast<float>(maximum);
    }

    /**
     * @brief Activa invulnerabilidad temporal
     * @param frames Número de frames de invulnerabilidad
     *
     * Típicamente usado después de recibir daño.
     * Ejemplo: 60 frames = 1 segundo a 60 FPS
     */
    void SetInvulnerability(int frames) {
        invulnerabilityFrames = frames;
    }

    /**
     * @brief Actualiza el timer de invulnerabilidad (llamar cada frame)
     */
    void UpdateInvulnerability() {
        if (invulnerabilityFrames > 0) {
            invulnerabilityFrames--;
        }
    }

    /**
     * @brief Verifica si la entidad es actualmente invulnerable
     * @return true si tiene frames de invulnerabilidad restantes
     */
    [[nodiscard]] bool IsInvulnerable() const {
        return invulnerabilityFrames > 0;
    }
};

} // namespace MultiNinjaEspacial::Core::Components
