// ============================================================================
// Test: Systems
// ============================================================================

#include <catch2/catch_test_macros.hpp>
#include "../../src/core/ecs/Registry.hpp"
#include "../../src/core/components/Transform.hpp"
#include "../../src/core/components/Velocity.hpp"
#include "../../src/core/systems/MovementSystem.hpp"

using namespace MultiNinjaEspacial::Core;

TEST_CASE("MovementSystem actualiza posición", "[systems][movement]") {
    ECS::Registry registry;
    auto entity = registry.CreateEntity();

    registry.AddComponent<Components::Transform>(
        entity,
        glm::vec2{0.0f, 0.0f}
    );

    registry.AddComponent<Components::Velocity>(
        entity,
        glm::vec2{100.0f, 50.0f} // 100 px/s derecha, 50 px/s abajo
    );

    SECTION("Actualización con deltaTime correcto") {
        float deltaTime = 0.1f; // 100ms

        Systems::MovementSystem::Update(registry.GetNative(), deltaTime);

        auto& transform = registry.GetComponent<Components::Transform>(entity);
        REQUIRE(transform.position.x == Catch::Approx(10.0f));  // 100 * 0.1
        REQUIRE(transform.position.y == Catch::Approx(5.0f));   // 50 * 0.1
    }

    SECTION("Actualización con rotación") {
        auto& velocity = registry.GetComponent<Components::Velocity>(entity);
        velocity.angular = 90.0f; // 90 grados/segundo

        Systems::MovementSystem::Update(registry.GetNative(), 0.5f);

        auto& transform = registry.GetComponent<Components::Transform>(entity);
        REQUIRE(transform.rotation == Catch::Approx(45.0f)); // 90 * 0.5
    }
}

TEST_CASE("MovementSystem normaliza rotación", "[systems][movement]") {
    ECS::Registry registry;
    auto entity = registry.CreateEntity();

    registry.AddComponent<Components::Transform>(entity);
    registry.AddComponent<Components::Velocity>(entity, glm::vec2{0.0f}, 360.0f);

    Systems::MovementSystem::Update(registry.GetNative(), 1.0f);

    auto& transform = registry.GetComponent<Components::Transform>(entity);
    REQUIRE(transform.rotation >= 0.0f);
    REQUIRE(transform.rotation < 360.0f);
}
