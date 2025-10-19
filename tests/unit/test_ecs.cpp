// ============================================================================
// Test: ECS (Entity-Component-System)
// ============================================================================
// Tests unitarios para Registry y Entity
// ============================================================================

#include <catch2/catch_test_macros.hpp>
#include "../../src/core/ecs/Registry.hpp"
#include "../../src/core/components/Transform.hpp"
#include "../../src/core/components/Velocity.hpp"

using namespace MultiNinjaEspacial::Core;

TEST_CASE("Registry puede crear y destruir entidades", "[ecs][registry]") {
    ECS::Registry registry;

    SECTION("Crear entidad devuelve handle válido") {
        auto entity = registry.CreateEntity("test");
        REQUIRE(registry.IsValid(entity));
    }

    SECTION("Destruir entidad invalida el handle") {
        auto entity = registry.CreateEntity("test");
        registry.DestroyEntity(entity);
        REQUIRE_FALSE(registry.IsValid(entity));
    }

    SECTION("Contador de entidades funciona") {
        REQUIRE(registry.GetEntityCount() == 0);

        auto e1 = registry.CreateEntity();
        REQUIRE(registry.GetEntityCount() == 1);

        auto e2 = registry.CreateEntity();
        REQUIRE(registry.GetEntityCount() == 2);

        registry.DestroyEntity(e1);
        REQUIRE(registry.GetEntityCount() == 1);
    }
}

TEST_CASE("Componentes pueden añadirse y obtenerse", "[ecs][components]") {
    ECS::Registry registry;
    auto entity = registry.CreateEntity();

    SECTION("Añadir y obtener Transform") {
        auto& transform = registry.AddComponent<Components::Transform>(
            entity,
            glm::vec2{100.0f, 200.0f}
        );

        REQUIRE(registry.HasComponent<Components::Transform>(entity));
        REQUIRE(transform.position.x == 100.0f);
        REQUIRE(transform.position.y == 200.0f);
    }

    SECTION("Añadir múltiples componentes") {
        registry.AddComponent<Components::Transform>(entity);
        registry.AddComponent<Components::Velocity>(entity);

        REQUIRE(registry.HasComponent<Components::Transform>(entity));
        REQUIRE(registry.HasComponent<Components::Velocity>(entity));
    }

    SECTION("Remover componente") {
        registry.AddComponent<Components::Transform>(entity);
        REQUIRE(registry.HasComponent<Components::Transform>(entity));

        registry.RemoveComponent<Components::Transform>(entity);
        REQUIRE_FALSE(registry.HasComponent<Components::Transform>(entity));
    }
}

TEST_CASE("Transform component funciona correctamente", "[components][transform]") {
    SECTION("Constructor por defecto") {
        Components::Transform t;
        REQUIRE(t.position.x == 0.0f);
        REQUIRE(t.position.y == 0.0f);
        REQUIRE(t.rotation == 0.0f);
        REQUIRE(t.scale.x == 1.0f);
        REQUIRE(t.scale.y == 1.0f);
    }

    SECTION("Constructor con posición") {
        Components::Transform t(glm::vec2{10.0f, 20.0f});
        REQUIRE(t.position.x == 10.0f);
        REQUIRE(t.position.y == 20.0f);
    }

    SECTION("GetMatrix devuelve matriz válida") {
        Components::Transform t(glm::vec2{100.0f, 200.0f}, 45.0f, glm::vec2{2.0f, 2.0f});
        auto matrix = t.GetMatrix();
        // Verificar que la matriz no es nula (básico)
        REQUIRE(matrix[0][0] != 0.0f);
    }
}

TEST_CASE("Velocity component funciona correctamente", "[components][velocity]") {
    SECTION("Constructor por defecto") {
        Components::Velocity v;
        REQUIRE(v.linear.x == 0.0f);
        REQUIRE(v.linear.y == 0.0f);
        REQUIRE(v.angular == 0.0f);
    }

    SECTION("GetSpeed devuelve magnitud correcta") {
        Components::Velocity v(glm::vec2{3.0f, 4.0f});
        REQUIRE(v.GetSpeed() == Catch::Approx(5.0f)); // 3-4-5 triangle
    }

    SECTION("GetDirection normaliza correctamente") {
        Components::Velocity v(glm::vec2{100.0f, 0.0f});
        auto dir = v.GetDirection();
        REQUIRE(dir.x == Catch::Approx(1.0f));
        REQUIRE(dir.y == Catch::Approx(0.0f));
    }
}
