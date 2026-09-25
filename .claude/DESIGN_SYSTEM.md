# 🎨 CASF — Design System (Lenguaje Visual Profesional)

> La fuente de verdad del **aspecto visual** de las apps generadas por el materializador.
> Destilado de las plantillas profesionales de referencia: **Linear, Vercel, Stripe, shadcn/ui**.
> El objetivo: que una app generada **no parezca "hecha por IA"**, sino un producto real.

---

## 0. Principio rector

> **"La tipografía es lo que más distingue un diseño profesional de uno genérico."**

Un diseño se ve profesional no por la cantidad de gradientes, sino por: tipografía cuidada, una escala de espaciado consistente, un acento único y saturado, y **iconografía profesional SVG** (no emojis). Menos es más.

**Reglas de oro (2026):**
1. **Tipografía primero.** Inter (o Geist) con pesos 400/500/600/700/800. JetBrains Mono para cifras/código.
2. **Un solo acento saturado.** Azul eléctrico / índigo / lima / naranja quemado. NUNCA un arcoíris de pasteles.
3. **Gradiente quirúrgico.** Solo en el hero y el CTA principal. No como decoración general.
4. **Iconos SVG profesionales** (trazo, estilo Lucide/Feather). **Prohibidos los emojis** como iconografía.
5. **Near-black surfaces** con "ladder" de elevación (cada capa elevada es un poco más clara).
6. **Espaciado en múltiplos de 4px.** 8/12/16/24 internos; 64/96 entre secciones. **Nunca 32.**
7. **Contraste 4.5:1** en ambos temas (verificado, no "porque se ve oscuro").
8. **`prefers-reduced-motion` + `focus-visible` + `forced-colors`** siempre.

---

## 1. Tokens de color (dark por defecto)

Estrategia "ladder de superficies" de Linear: fondo casi negro, cada superficie elevada un escalón más claro.

| Token | Valor | Uso |
|---|---|---|
| `--bg` | `#0a0b0c` | Fondo de página (near-black) |
| `--bg2` | `#101114` | Superficie de inputs / filas hover |
| `--card` | `#131417` | Tarjetas / secciones |
| `--card2` | `#1a1c20` | Superficies elevadas dentro de cards |
| `--border` | `#26282e` | Bordes sutiles |
| `--text` | `#e8eaed` | Texto principal (off-white, no blanco puro) |
| `--muted` | `#9aa0a6` | Texto secundario |
| `--accent` | `#5E6AD2` (Linear) / `#533AFD` (Stripe) / `#0070f3` (Vercel) | Acento único |
| `--ok` | `#2ecc71` / `#0f9d58` | Éxito |
| `--warn` | `#f59e0b` | Advertencia |
| `--err` | `#e5484d` | Error |

**Reglas:**
- El acento es **uno solo** por app, derivado de la categoría del producto (p.ej. fintech→índigo Stripe, dev-tool→azul Linear, genérico→azul Vercel).
- Gradiente de acento: `linear-gradient(135deg, var(--accent), <accent más claro>)` **solo** en hero y CTA.
- Los acentos **no deben ser colores pastel** ni múltiples a la vez.

---

## 2. Tipografía

| Rol | Familia | Peso | Notas |
|---|---|---|---|
| Display / títulos | Inter | 700–800 | `letter-spacing` negativo escalado: `-0.04em` en hero, `-0.02em` en h2 |
| Cuerpo | Inter | 400–500 | `line-height: 1.55` |
| Etiquetas / eyebrows | Inter | 600 | mayúsculas, `letter-spacing: 0.04em`, tamaño 11–12px |
| Cifras / dinero / código | JetBrains Mono | 400–500 | `font-variant-numeric: tabular-nums` para alinear columnas |

**Escala display (negativa progresiva):**
- Hero: `clamp(2rem, 5vw, 3rem)`, weight 800, `letter-spacing: -0.03em`
- H2 sección: `1.25rem`, weight 700, `letter-spacing: -0.02em`
- Body: `15–16px`, nunca por debajo de 14px.

> Referencia: Linear usa Inter (Display/Text) + mono; Vercel usa Geist + Geist Mono. Inter es el sustituto libre más cercano a ambas.

---

## 3. Espaciado y radio

- **Base 4px.** Internos: 8 / 12 / 16 / 24. Secciones: 64 / 96. **Prohibido 32px** (arruina ambos extremos de la escala).
- **Radios:** escala de 8 pasos — 4px (inputs), 8px (botones), 12px (cards), 16px (modales), `999px` (pills/badges).
- **Sombras:** mínimas. `0 1px 2px rgba(0,0,0,.4)` para cards; solo el CTA principal y modales llevan sombra profunda.

---

## 4. Iconografía profesional (SVG, estilo Lucide)

**Prohibido usar emojis como iconos.** Todo icono es **SVG inline**, 24×24 viewBox, trazo de 1.5–2px, `stroke="currentColor"`, `fill="none"`, `stroke-linecap="round"` / `stroke-linejoin="round"`.

### Catálogo base (helper `icon(name)`)
Cada icono vive en un map del runtime y se inyecta con `<span class="ic">`:

| Clave | Uso |
|---|---|
| `shop` | e-commerce / catálogo |
| `cart` | carrito |
| `package` | pedidos |
| `utensils` | restaurante / menú |
| `table` | mesas |
| `receipt` | órdenes / cuentas |
| `calendar` | agenda / citas |
| `users` | pacientes / clientes |
| `stethoscope` | doctores / salud |
| `scissors` | barbería / servicios |
| `gift` | recompensas |
| `chart` | dashboard / KPIs |
| `qr` | check-in / QR |
| `camera` | escanear |
| `bot` | asistente / chat |
| `user` | perfil / persona |
| `plus` | añadir |
| `trash` | borrar |
| `search` | buscar |
| `download` | exportar |
| `star` | rating |

### Plantilla de un icono (ej. `cart`)
```html
<svg viewBox="0 0 24 24" width="18" height="18" fill="none"
     stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
  <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
</svg>
```

### Regla de uso
- En `<h2>` de sección, el icono va **dentro de un `<span class="ic">`** con `margin-right: 8px` y color `var(--accent)`.
- En botones, el icono va inline con `margin-right: 6px`.
- Nunca más de un icono por heading; nunca iconos + emoji mezclados.

---

## 5. Componentes canónicos

| Componente | Características profesionales |
|---|---|
| **Navbar** | sticky, `backdrop-filter: blur`, border-bottom sutil, brand en gradient-text |
| **Hero** | gradient quirúrgico + tipografía display grande + CTA pill |
| **Card** | surface ladder + border sutil + hover `translateY(-2px)` |
| **Botón primario** | gradient acento, pill radius, sombra al hover |
| **Botón ghost** | transparente + border, texto muted |
| **Badge** | pill, fondo del color a 15% de opacidad, texto del color pleno |
| **Tabla CRUD** | th uppercase 11px + `tabular-nums` en cifras, hover de fila |
| **KPI card** | valor en `font-size: 1.8rem` weight 800 + label muted 12px |
| **Input** | `--bg2`, border 1px, focus ring `0 0 0 3px rgba(accent,.18)` |
| **Toast** | fijo abajo, border-left 4px de color semántico, animación fadein |

---

## 6. Anti-patrones (lo que hace que parezca IA)

**PROHIBIDO:**
- ❌ Emojis como iconos (🛒 📦 👥) → usar SVG.
- ❌ Gradiente en todo el fondo de página.
- ❌ Múltiples colores de acento pastel a la vez.
- ❌ Tipografía default del sistema sin jerarquía.
- ❌ Cards sin border ni elevación (todo plano).
- ❌ Espaciado inconsistente (32px, 20px aleatorios).
- ❌ Texto centrado en secciones de datos.
- ❌ Sombras excesivas por todas partes.

---

## 7. Cómo aplica esto el materializador

1. **`CSS`** (constante en `materializer.ts`) usa estos tokens exactos y la escala de espaciado.
2. **`RUNTIME`** expone `icon(name)` y reemplaza todo emoji por SVG.
3. **`frontend_architect.md`** exige este design system en toda revisión de UI generada.
4. El **`spec_quality_reviewer`** verifica que el spec pida "iconografía profesional + design system" (dimensión 10 del rubric).

---

## 8. Navegación por vistas (no "single-page scroll") ⭐

> **Corrección pendiente (2026-09-23).** Hoy una app generada es **una sola página** con todas las funciones apiladas (dashboard, clientes, citas, puntos, recompensas, dueño, bot…). Eso funciona, pero **parece demo**, no producto.

Una app profesional separa cada función en una **vista** y navega entre ellas con un **app shell** (como CASF Studio, que usa pestañas). El objetivo: que el usuario vea **una función a la vez**, con navegación clara.

### Reglas (cuando se implemente)

1. **App shell con navegación:** una barra lateral (o tabs superiores en móvil) con ítems: `Dashboard`, `Clientes`, `Citas`, `Puntos`, `Recompensas`, `Servicios`, `Dueño`, `Ayuda`. Un ítem activo resaltado.
2. **Una función por vista:** cada vista renderiza **solo su dominio** (p. ej. la vista "Citas" no muestra el ledger de puntos). Sin scroll infinito que mezcle todo.
3. **Routing por hash (sin framework):** `#/dashboard`, `#/clients`, `#/appointments`… `hashchange` decide qué vista renderizar. Mantiene compatibilidad con el preview estático actual (`/slug/frontend/index.html`).
4. **Estado compartido, vistas separadas:** los datos viven en un store único (`store.js`/API), pero **cada vista** es un `render*()` independiente y testeable (apunta al objetivo de la Etapa 1.2: partir el `app.js` monolito en módulos por vista).
5. **Responsive:** en móvil la barra lateral colapsa a tabs/`<select>`; targets ≥ 44px (Etapa 2.5).
6. **Toggle de idioma y tema** viven en el shell (persistentes), no dentro de cada vista.

### Criterio de done
- [ ] Navegar entre todas las vistas sin recargar (hash routing).
- [ ] Cada vista muestra **una** función, no un muro de secciones.
- [ ] URL `#/...` permite deep-link y volver atrás.
- [ ] El shell es idéntico en todas las vistas (brand, idioma, tema, nav).

---

<!-- CASF · design-system.md · v1.0 -->
