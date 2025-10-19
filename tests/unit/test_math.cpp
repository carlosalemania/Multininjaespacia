// ============================================================================
// Test: Math
// ============================================================================

#include <catch2/catch_test_macros.hpp>
#include <glm/glm.hpp>

TEST_CASE("GLM básico funciona", "[math][glm]") {
    SECTION("Vector construction") {
        glm::vec2 v(1.0f, 2.0f);
        REQUIRE(v.x == 1.0f);
        REQUIRE(v.y == 2.0f);
    }

    SECTION("Vector operations") {
        glm::vec2 a(1.0f, 2.0f);
        glm::vec2 b(3.0f, 4.0f);
        glm::vec2 c = a + b;

        REQUIRE(c.x == 4.0f);
        REQUIRE(c.y == 6.0f);
    }

    SECTION("Vector length") {
        glm::vec2 v(3.0f, 4.0f);
        float length = glm::length(v);
        REQUIRE(length == Catch::Approx(5.0f));
    }

    SECTION("Vector normalization") {
        glm::vec2 v(100.0f, 0.0f);
        glm::vec2 normalized = glm::normalize(v);
        REQUIRE(normalized.x == Catch::Approx(1.0f));
        REQUIRE(normalized.y == Catch::Approx(0.0f));
    }
}
