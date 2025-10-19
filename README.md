# 🚀 Multi Ninja Espacial

![Estado](https://img.shields.io/badge/Estado-MVP%20Completo-brightgreen)
![Godot](https://img.shields.io/badge/Godot-4.2+-blue)
![Plataforma](https://img.shields.io/badge/Plataforma-Web-orange)
![Licencia](https://img.shields.io/badge/Licencia-MIT-yellow)

> Juego educativo cristiano tipo sandbox para niños (4-12 años)

Un mundo de bloques donde los niños aprenden valores cristianos mientras construyen, exploran y recolectan recursos. El sistema "Luz Interior" recompensa acciones positivas y fomenta el juego creativo.

---

## 🎮 Características

- ✨ **Sistema "Luz Interior"**: Recompensas por construcción, recolección y tiempo de juego
- 🧱 **5 Tipos de Bloques**: Tierra, Piedra, Madera, Cristal, Metal
- 🌍 **Mundo Procedural**: Generación automática con Perlin Noise
- 💾 **Guardado Automático**: LocalStorage en web, cada 2 minutos
- 🎨 **Estilo Low-Poly**: Optimizado para navegadores (<50MB)
- 🎵 **Audio Dinámico**: Música y efectos de sonido inmersivos

---

## 📦 Instalación

### Requisitos
- Godot 4.2 o superior
- Navegador moderno (Chrome, Firefox, Safari)

### Pasos
1. Clonar este repositorio
2. Abrir el proyecto en Godot Editor
3. Seguir `SCENE_ASSEMBLY_GUIDE.md` para crear las escenas
4. Configurar Input Map según `INPUT_MAP_CONFIG.md`
5. Presionar F5 para jugar

---

## 🎯 Controles

| Acción | Tecla/Mouse |
|--------|-------------|
| Moverse | WASD |
| Saltar | Space |
| Mirar | Mouse |
| Colocar Bloque | Click Izquierdo |
| Romper Bloque | Click Derecho (mantener) |
| Cambiar Slot | 1-9 |
| Pausar | ESC |

---

## 🌟 Sistema "Luz Interior"

El juego recompensa acciones positivas con **Luz Interior**:

- 🏗️ **Construcción**: +5 Luz por cada 10 bloques colocados
- 💎 **Recolección**: +3 Luz por cada 20 recursos recolectados
- ⏱️ **Tiempo de Juego**: +2 Luz por minuto jugando

### Milestones
- 🌟 50 Luz
- ⭐ 100 Luz
- 🌠 200 Luz
- ✨ 500 Luz
- 💫 1000 Luz (Máximo)

---

## 📁 Estructura del Proyecto

```
multininjaespacial/
├── autoloads/          # Singletons globales (GameManager, SaveSystem, etc.)
├── scripts/            # Lógica del juego
│   ├── core/           # Constants, Enums, Utils
│   ├── player/         # Movimiento, cámara, interacción
│   ├── world/          # Chunks, bloques, generador de terreno
│   ├── ui/             # HUD, menús
│   └── game/           # GameWorld principal
├── scenes/             # Escenas .tscn (a crear en Godot)
├── assets/             # Audio, texturas, modelos (a añadir)
└── docs/               # Documentación
```

---

## 🛠️ Tecnologías

- **Motor**: Godot 4.2+ (GDScript)
- **Renderer**: GL Compatibility (mejor soporte web)
- **Generación**: FastNoiseLite (Perlin Noise)
- **Storage**: LocalStorage API (web) / FileAccess (desktop)

---

## 📚 Documentación

- [`GODOT-WEB-STRUCTURE.md`](GODOT-WEB-STRUCTURE.md) - Arquitectura completa del proyecto
- [`SCENE_ASSEMBLY_GUIDE.md`](SCENE_ASSEMBLY_GUIDE.md) - Cómo crear las escenas en Godot
- [`INPUT_MAP_CONFIG.md`](INPUT_MAP_CONFIG.md) - Configuración de controles
- [`PROJECT_SUMMARY.md`](PROJECT_SUMMARY.md) - Resumen técnico completo

---

## 🚀 Exportar para Web

1. Abrir **Project → Export**
2. Añadir preset **Web**
3. Configurar:
   - Export Type: Regular
   - Export with Debug: Desactivar (producción)
   - Head Include: Custom HTML (opcional)
4. Click en **Export Project**
5. Subir carpeta generada a:
   - [itch.io](https://itch.io) (recomendado para juegos)
   - [GitHub Pages](https://pages.github.com)
   - Netlify, Vercel, etc.

---

## 🎓 Valores Educativos

Este juego enseña:

- **Fe**: La Luz Interior representa crecimiento espiritual
- **Trabajo**: Construcción y recolección requieren esfuerzo
- **Responsabilidad**: Sistema de guardado enseña a preservar el progreso
- **Creatividad**: Construcción libre fomenta la imaginación
- **Paciencia**: Romper bloques más duros requiere tiempo

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas!

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 🐛 Reporte de Bugs

Si encuentras un bug, por favor abre un [Issue](../../issues) con:
- Descripción del problema
- Pasos para reproducir
- Comportamiento esperado vs actual
- Screenshots (si aplica)
- Sistema operativo y navegador

---

## 📝 Roadmap

### ✅ MVP (Versión 1.0) - COMPLETADO
- [x] Movimiento 3D first-person
- [x] Sistema de bloques voxel
- [x] Generación procedural de terreno
- [x] Sistema "Luz Interior"
- [x] Guardado/carga LocalStorage
- [x] UI completa

### 🔄 Versión 1.1 (Próximo)
- [ ] Tutorial interactivo paso a paso
- [ ] Texturas para bloques (512x512)
- [ ] Más tipos de bloques (10-15 total)
- [ ] Sistema de crafteo simple
- [ ] Partículas y animaciones

### 🔮 Versión 2.0 (Futuro)
- [ ] Modo multijugador cooperativo (4-8 jugadores)
- [ ] NPCs que enseñen valores
- [ ] Misiones y objetivos guiados
- [ ] Versión móvil (Android/iOS)

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

**Multi Ninja Espacial Team**

Creado con ❤️ para niños que quieren aprender jugando.

---

## 🙏 Agradecimientos

- **Godot Engine** - Motor de juego open source
- **Claude Code** - Asistencia en desarrollo
- **Comunidad cristiana** - Inspiración y valores
- **Padres y educadores** - Feedback y testing

---

<div align="center">

**¡Construye, explora y haz brillar tu Luz Interior! ✨**

[📖 Documentación](SCENE_ASSEMBLY_GUIDE.md) | [🐛 Reportar Bug](../../issues)

</div>
