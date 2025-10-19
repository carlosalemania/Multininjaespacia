// ============================================================================
// Test: Components
// ============================================================================

#include <catch2/catch_test_macros.hpp>
#include "../../src/core/components/Health.hpp"
#include "../../src/core/components/Renderable.hpp"

using namespace MultiNinjaEspacial::Core::Components;

TEST_CASE("Health component funciona", "[components][health]") {
    SECTION("Constructor por defecto") {
        Health h;
        REQUIRE(h.current == 100);
        REQUIRE(h.maximum == 100);
        REQUIRE_FALSE(h.IsDead());
        REQUIRE(h.IsFullHealth());
    }

    SECTION("TakeDamage reduce HP") {
        Health h(100, 100);
        h.TakeDamage(30);
        REQUIRE(h.current == 70);
        REQUIRE_FALSE(h.IsDead());
    }

    SECTION("TakeDamage mata al llegar a 0") {
        Health h(10, 100);
        bool died = h.TakeDamage(15);
        REQUIRE(h.current == 0);
        REQUIRE(h.IsDead());
        REQUIRE(died);
    }

    SECTION("Heal aumenta HP") {
        Health h(50, 100);
        h.Heal(30);
        REQUIRE(h.current == 80);
    }

    SECTION("Heal no excede máximo") {
        Health h(90, 100);
        h.Heal(50);
        REQUIRE(h.current == 100);
        REQUIRE(h.IsFullHealth());
    }

    SECTION("GetHealthPercentage devuelve fracción correcta") {
        Health h(75, 100);
        REQUIRE(h.GetHealthPercentage() == Catch::Approx(0.75f));
    }
}

TEST_CASE("Renderable component funciona", "[components][renderable]") {
    SECTION("Constructor por defecto") {
        Renderable r;
        REQUIRE(r.textureId.empty());
        REQUIRE(r.visible);
        REQUIRE(r.color.a == 1.0f);
    }

    SECTION("SetAlpha modifica transparencia") {
        Renderable r;
        r.SetAlpha(0.5f);
        REQUIRE(r.GetAlpha() == Catch::Approx(0.5f));
    }

    SECTION("Hide/Show funciona") {
        Renderable r;
        r.Hide();
        REQUIRE_FALSE(r.visible);

        r.Show();
        REQUIRE(r.visible);
    }
}
