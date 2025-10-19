// ============================================================================
// Renderable Component - Componente de Renderizado
// ============================================================================
// Marca una entidad como "dibujable" y almacena información de renderizado
// Usado por: RenderSystem para dibujar sprites en pantalla
// ============================================================================

#pragma once

#include <glm/glm.hpp>
#include <string>

namespace MultiNinjaEspacial::Core::Components {

/**
 * @brief Componente que marca entidades renderizables
 *
 * Contiene toda la información necesaria para dibujar un sprite:
 * - ID de textura
 * - Color tint
 * - Layer (para ordenar dibujo)
 * - Visibilidad
 *
 * Ejemplo de uso:
 * ```cpp
 * auto entity = registry.create();
 * registry.emplace<Renderable>(entity,
 *     "player_sprite",           // texture ID
 *     glm::vec4{1.0f},           // color blanco (sin tint)
 *     10                          // layer 10 (más alto = dibuja encima)
 * );
 * ```
 */
struct Renderable {
    // ID de la textura a renderizar
    // Se busca en el TextureManager usando este string
    std::string textureId;

    // Color tint (RGBA, valores 0.0-1.0)
    // {1,1,1,1} = sin cambios
    // {1,0,0,1} = tintado rojo
    // {1,1,1,0.5} = 50% transparente
    glm::vec4 color{1.0f, 1.0f, 1.0f, 1.0f};

    // Layer de renderizado (mayor número = se dibuja encima)
    // Ejemplo de layers:
    //   0-9:   Fondo
    //   10-19: Jugadores
    //   20-29: Proyectiles
    //   30-39: Efectos de partículas
    //   40+:   UI
    int layer{0};

    // Visibilidad (si false, RenderSystem lo ignora)
    bool visible{true};

    /**
     * @brief Constructor por defecto: entidad invisible sin textura
     */
    Renderable() = default;

    /**
     * @brief Constructor con textura
     * @param texId ID de textura
     */
    explicit Renderable(std::string texId)
        : textureId(std::move(texId)) {}

    /**
     * @brief Constructor completo
     * @param texId ID de textura
     * @param col Color tint
     * @param lyr Layer de renderizado
     */
    Renderable(std::string texId, const glm::vec4& col, int lyr)
        : textureId(std::move(texId)), color(col), layer(lyr) {}

    /**
     * @brief Establece opacidad (0.0 = transparente, 1.0 = opaco)
     * @param alpha Valor de opacidad
     */
    void SetAlpha(float alpha) {
        color.a = glm::clamp(alpha, 0.0f, 1.0f);
    }

    /**
     * @brief Obtiene opacidad actual
     * @return Valor alpha (0.0-1.0)
     */
    [[nodiscard]] float GetAlpha() const {
        return color.a;
    }

    /**
     * @brief Oculta la entidad (equivale a visible = false)
     */
    void Hide() {
        visible = false;
    }

    /**
     * @brief Muestra la entidad (equivale a visible = true)
     */
    void Show() {
        visible = true;
    }
};

} // namespace MultiNinjaEspacial::Core::Components
