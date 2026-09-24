# 🗺️ CASF Studio — Etapas siguientes (Roadmap técnico)

> Complementa a `VENTAJAS_COMPETITIVAS.md` (negocio) y `PATRON_DE_DISENO.md` (arquitectura).
> Aquí está **qué falta construir**, en qué orden, y qué se puede lograr con ~$20 de presupuesto.
>
> **Estado base al escribir esto (2026-09-20):** MVP con ciclo completo
> `prompt → spec → app generada (frontend/ + backend en capas + SQLite + validación + paginación) → preview → costos`.
> Lo que sigue es el camino para que **deje de parecer un prototipo y entre por los ojos**.

---

## 🧭 Cómo leer este documento

- **Prioridad** = P0 (bloqueante / alto impacto) → P3 (a futuro).
- **Esfuerzo** = 💰 bajo / 💰💰 medio / 💰💰💰 alto (en tokens de agente + tiempo).
- **Costo API** = si la etapa consume APIs externas (imágenes/video), además de tokens.
- Cada etapa tiene **entregables** y **criterio de done** verificables.

---

## Resumen ejecutivo

| # | Etapa | Prioridad | Esfuerzo | Costo API |
|---|---|---|---|---|
| 1 | Cerrar deuda: tests + frontend real | P0 | 💰💰💰 | No |
| 2 | **Diseño visual profesional** (iconos + animaciones + "anti-IA") | P0 | 💰💰💰 | No |
| 3 | **Generación de imágenes** (nano banana / Gemini imagen) | P1 | 💰💰 | Sí (tier gratis para probar) |
| 4 | **Animación de assets** (animación propia desde imágenes) | P1 | 💰💰 | No (solo assets estáticos) |
| 5 | Comercialización: **Free demo + créditos + Pro** (P0) + Yape + límites de Build | P0 | 💰💰 | No (manual) |
| 6 | **Escalabilidad + procesamiento asíncrono** (colas, concurrencia) | P0 | 💰💰💰 | Sí (infra) |
| 7 | Producción: hosting, dominios, observabilidad, hardening | P1 | 💰💰💰 | Sí (infra) |
| 8 | Ecosistema: marketplace, self-host, analytics | P3 | 💰💰💰 | Sí |
| 9 | **Calidad por revisión adversaria + slices + quality spec** | P0 | 💰💰 | No |

> **Estado 2026-09-22:** ✅ 5.4–5.5 (Free demo + créditos + 402 + límites) **ya está cableado y smoke-testeado**. ✅ Etapa 9 (revisión adversaria + slices + quality spec) **integrada al framework** (agentes + workflow + rúbrica + CLAUDE.md). Con presupuesto, lo siguiente de mayor retorno es **5.1 (Yape/transferencia — primer cobro real)** o **Etapa 2 (visual — entrar por los ojos)**. No las dos a la vez.
> Números recalculados, predicciones de ingresos y contingencias: secciones **💰** y **📈** más **Apéndice B**.

---

## 📅 Bitácora de sesiones

> Registro de qué se hizo cada día y por dónde retomar. Lo más reciente arriba.

### 2026-09-24 — Studio conectado al framework real (Claude Code + DeepSeek) 🔌
- **Objetivo:** dejar de generar "apps de cartón" (materializador determinista) y conectar CASF Studio al **harness real de Claude Code**, usando **DeepSeek** como LLM.
- **Hecho:**
  - `claudeCodeProvider.ts`: invoca `claude -p` dentro de `d:/Trabajo/proyectos/CASF`, con DeepSeek vía `ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`. Carga `CLAUDE.md`, `.claude/agents/*.md` y `PROJECT_SPEC.md` (benchmark) → specs de nivel "DentaFlow"/"MesaDirecta".
  - **Pestaña "Log en vivo"** en Studio (`LiveLog.tsx` + `GET /api/live-log`): streaming incremental (offset) del `studio-live.log`, visible en la UI **y** en la terminal con `tail -f`.
  - **Persistencia del proceso del chat** (`memory.ts` `saveSession`/`getSession` + `GET /api/session`): al recargar se restauran prompt + spec + pasos de progreso + build. Ya no se pierde el flujo.
  - **Hitos en el log** (`liveLog.ts` `liveMarker`/`appendLive`): `▶ Generando spec… / ✔ Spec generado / ▶ Build iniciado / ✔ Build completado`.
  - `CLAUDE.md` modularizado (`.claude/constitution/engineering.md` + `process.md`) para sortear el límite de 40k de Claude Code.
  - `JWT_SECRET` estable en `backend/.env` (ya no invalida sesiones al reiniciar).
- **Pendiente para mañana (retomar aquí):**
  1. **Build LLM-driven** — que Claude Code implemente el **código** de la app (no solo el spec), con `--permission-mode acceptEdits`/`bypassPermissions` y `--add-dir` para el output. Es la pieza que falta para que Studio cree apps completas de verdad.
  2. Probar end-to-end: prompt → spec (DeepSeek/Claude Code) → **build por Claude Code** → preview, todo visible en "Log en vivo" + terminal + chat restaurado.
  3. Seguir con Etapa 2 (visual) / 5.1 (Yape) según presupuesto.

---

## Etapa 1 — Cerrar deuda técnica (fundación)

**Por qué:** no tiene sentido "embellecer" un monolito. Hay dos brechas que arrastramos:

1. **El frontend de las apps generadas es vanilla JS monolítico** (`app.js` de ~2000 líneas), mientras el spec declara `React`. Funciona, pero no escala ni es mantenible.
2. **No hay tests** del materializador → cada cambio puede romper widgets que ya funcionan.

### 1.1 Tests del materializador (P0)
- **Entregables:**
  - Suite de tests que: regenera una app de cada dominio (fidelidad, tienda, restaurante, salud, LMS, RRHH, inventario, CRM) y valida que los archivos clave existen y compilan (`node --check`).
  - Test del backend generado: arrancar `server.js`, probar `register/login/CRUD/paginación/validación` (ya lo hice manual; automatizarlo).
  - Test de `parseProjectMd` ↔ `specToMarkdown` (round-trip).
- **Criterio de done:** `npm test` en verde, y un CI que lo corra en cada push.

### 1.2 Frontend real de apps generadas (P0)
- **Decisión a tomar (tú decides cuando recargues):**
  - **(A) React + Vite + componentes** — alineado con lo que promete el spec, pero reescribir el runtime entero (~10 widgets). 💰💰💰
  - **(B) Vanilla modular** — dividir el `app.js` monolito en módulos ES (`components/`, `widgets/`, `store.js`), sin framework. Más barato, mantiene compatibilidad con el preview actual. 💰💰
  - **(C) Híbrido** — empezar con (B) y migrar progresivamente a (A). 💰💰💰 (recomendado a medio plazo)
- **Criterio de done:** `app.js` deja de ser un monolito; cada widget vive en su módulo y es testeable.

---

## Etapa 2 — Diseño visual profesional (la prioridad del usuario) ⭐

**Por qué:** el producto hoy es "funcional pero feo" — tipografía por defecto, tablas planas, colores genéricos. Ese es el sello de "hecho por IA". Esta etapa es **la de mayor retorno visual por dólar** porque **no consume APIs de imágenes** (solo tokens de código).

### 2.1 Design system / tokens (P0)
- **Entregables:**
  - Archivo de **tokens CSS**: `--color-primary`, `--color-surface`, `--radius-*`, `--shadow-*`, `--space-*`, `--font-*`.
  - **Paletas por tema** (las apps ya soportan tema oscuro/claro; hacerlas *bonitas*, no solo funcionales).
  - **Tipografía con jerarquía** (display / heading / body / caption) — p. ej. Inter, Poppins o Space Grotesk.
  - **Escala de espaciado** consistente (4/8/12/16/24/32/48).
- **Criterio de done:** dos temas completos (claro/oscuro) que se vean deliberados, no por defecto.

### 2.2 Iconos profesionales (P0)
- **Entregables:** reemplazar emojis (📊👥📅⭐) por **iconos SVG vectoriales** de una librería coherente (Lucide o Phosphor), inline en el runtime.
- **Criterio de done:** cero emojis en la UI; iconos con `stroke`/`fill` consistente, accesibles (`aria-label`).

### 2.3 Animaciones y micro-interacciones (P0)
- **Entregables:**
  - **Transiciones** suaves en hover/focus (botones, tarjetas, nav).
  - **Skeleton loaders** en vez de spinners o pantallas vacías.
  - **Entrada escalonada** (stagger) de tarjetas/listas al cargar.
  - **Micro-interacciones**: toasts animados, contadores que "suben", botones con feedback de presión.
  - **Scroll reveal** (IntersectionObserver) en secciones.
- **Criterio de done:** toda interacción tiene feedback visual; `prefers-reduced-motion` respetado.

### 2.4 Componentes "premium" anti-IA (P0)
- **Entregables:**
  - **Hero section** con gradiente sutil + titular con jerarquía (no un `<h1>` pelado).
  - **Cards** con sombra suave (`box-shadow` con alpha bajo), bordes redondeados, hover lift.
  - **Empty states** ilustrados ("Aún no hay clientes" con icono + CTA).
  - **Estados de error/éxito** bonitos.
  - **Badges, chips, pills** para estados (activo/inactivo, tiers).
  - **Tablas** rediseñadas (filas con separación sutil, hover, sticky header) — hoy son la parte más "IA" de la app.
- **Criterio de done:** una app generada se vea comparable a una plantilla premium de mercado (Tailwind UI / shadcn), no a una respuesta de chat.

### 2.5 Responsive + accesibilidad (P1)
- **Entregables:** verificación en móvil/tablet/desktop; contraste WCAG AA; focus visible; targets ≥ 44px.
- **Criterio de done:** navegación completa por teclado + contraste verificado.

> **Resultado de la Etapa 2:** el mismo generador, pero el **runtime visual** cambia de nivel. Es el cambio que más rápido "vende" el producto.

---

## Etapa 3 — Generación de imágenes (nano banana / Gemini) ⭐

**Contexto honesto:** lo que la comunidad llama **"nano banana"** es el modelo de **generación de imágenes de Google (Gemini 2.5 Flash Image)**. Genera **imágenes estáticas de alta calidad** y soporta edición conversacional (pedir cambios sobre la imagen). **No anima por sí solo** — para animar se combina con la Etapa 4 (animación propia). **Tiene tier gratuito** → ideal para probar sin gastar.

### 3.1 Capa de assets (abstracción de proveedor) (P1)
- **Entregables:** un `ImageProvider` agnóstico (igual que ya existe `PaymentProvider`/`IdentityProvider`):
  - Implementación real → Gemini imagen (nano banana) vía API.
  - Implementación `mock` → placeholder SVG local generado (sin API, sin costo).
  - **Cache** de imágenes generadas (no regenerar la misma imagen).
  - **Contabilidad**: cada imagen suma su costo al ledger (`cost.ts`), como ya hacen los tokens.
- **Criterio de done:** `IMAGE_PROVIDER=mock` funciona sin costo; `IMAGE_PROVIDER=gemini` genera imagen real con costo registrado.

### 3.2 Tipos de assets a generar (P1)
- **Logo** del proyecto (SVG/PNG) al materializar.
- **Hero image / banner** de portada.
- **Imágenes de productos** (e-commerce) y **avatares** de perfiles/equipos.
- **Favicon** y **OG image** (para compartir en redes).
- **Criterio de done:** una app de tienda se genera con fotos de producto realistas; una de restaurante con fotos de platos.

### 3.3 Integración en el materializador (P1)
- **Entregables:** el materializador pide los assets *después* del spec (o en paralelo) y los inyecta en `frontend/` + referencias en el runtime.
- **Criterio de done:** el flujo `prompt → app con imágenes` funciona de punta a punta, con fallback local si no hay API key.

---

## Etapa 4 — Animación de assets (hero animado, micro-animaciones)

**Estrategia elegida (confirmada):** **NO usar APIs de video** (Veo/Kling/Runway — caras por segundo). En su lugar, **pedir a nano banana (Gemini imagen) assets estáticos de alta calidad y animarlos nosotros mismos** para que *parezcan* una animación. Así el costo se reduce a casi cero (solo las capas gratuitas de imagen para pruebas) y mantenemos control total.

### 4.1 Animación propia a partir de assets (P0) ⭐
- **Entregables:**
  - **Ken Burns** (zoom + parallax lento) sobre hero/banners: la imagen estática "respira" con CSS/JS, sin API de video.
  - **Lottie** para iconos y estados animados (check-in con éxito, loading de QR, celebración de puntos).
  - **Micro-interacciones** CSS: hover lift, entradas escalonadas (stagger), toasts animados, contadores que suben.
  - **Sprites / secuencias**: pedir a nano banana un set de 2-4 frames y rotarlos para simular movimiento (flicker, latido, onda).
- **Criterio de done:** 3-5 momentos clave de cada app se sienten "vivos" usando solo assets estáticos + CSS/JS. Cero API de video.

### 4.2 Video real imagen→video (P3 — a futuro, opt-in premium)
- **Contexto:** convertir imagen en video corto real (Google Veo, Kling, Runway) es otro servicio, **caro**. Solo para apps "premium" cuando el producto ya monetice.
- **Criterio de done:** opt-in con costo claro en el ledger; **no por defecto**.

> **Regla de presupuesto:** probar todo con **capas gratuitas** de imagen (Gemini ofrece tier gratuito). Pagar solo cuando un asset real vaya a producción en un proyecto concreto.

---

## Etapa 5 — Comercialización (lo que falta para cobrar)

### 5.1 Pagos en fase de prueba: Yape + transferencia bancaria (P0) ⭐
- **Por qué:** no depender de Stripe/Mercado Pago (que requieren registro/verificación y, en el caso de Yape, acuerdos con el BCP). Para **validar el flujo de cobro** ya es suficiente un método manual con datos reales.
- **Entregables:**
  - **`YapeProvider`** → muestra el **QR de Yape** (imagen estática que el cliente escanea) + número de celular + monto.
  - **`BankTransferProvider`** → muestra datos de transferencia bancaria (banco, número de cuenta, CCI, titular) + monto de referencia.
  - **Verificación manual**: el admin confirma el pago en el panel (estado `pending → paid`), porque Yape/transferencia no emiten webhooks automáticos.
  - El monto y los datos de pago se registran en el ledger de costos/ingresos.
- **Criterio de done:** un usuario puede "pagar" (escanea QR / transfiere), el admin lo ve como `pending`, lo marca `paid`, y se activa la suscripción.

### 5.2 Pasarelas automatizadas (P2 — cuando investigues)
- **Entregables:** `StripeProvider` + `MercadoPagoProvider` (stubs ya existen en el código) con checkout + webhooks automáticos.
- **Criterio de done:** pago de prueba completo sin intervención manual del admin.
- **Nota:** Yape *también* tiene API para comercios (integración oficial BCP), pero requiere proceso de afiliación; la dejamos para después del MVP.

### 5.3 Identidad real (P1)
- **Entregables:** `JSON.pe` (DNI) como primer integrador real (barato y peruano); dejar RENIEC/Open Gateway como stubs.
- **Criterio de done:** un DNI de prueba se valida contra JSON.pe y el check-in QR registra la identidad real.

### 5.4 Planes: Free demo + pagar para usar + créditos (P0) ⭐

**Decisión de producto (2026-09-20):** se **baja Free**. Ya no se regalan 3 apps/mes. Free es **demo**; **usar de verdad (Build)** requiere pago. Quien no quiera $19/mes compra **créditos** más baratos, de a uno o en pack. Ads (5.6) pasan a P3: con Free tan chico no hace falta subsidiar con publicidad.

#### Qué incluye cada capa

| | **Free (demo)** | **Créditos (pay-as-you-go)** | **Pro $19/mes** | **Enterprise $99/mes** |
|---|---|---|---|---|
| Spec (`project.md`) | Sí, para probar el flujo | Incluido al gastar 1 crédito en el ciclo, o si ya tienes spec | Incluido | Incluido |
| **Build** (app real, preview, export, Docker) | **No** | **1 crédito = 1 build** | Incluido (cupo 5.5) | Incluido (cupo negociado) |
| Imágenes de pago | No | Según pack / no por defecto | Cupo del plan | Cupo negociado |
| Ads | Irrelevante (casi no hay sesión de build) | No | No | No |
| Para quién | Curioso, ver cómo se siente | 1–4 apps sueltas (barbería, un cliente) | Quien genera todas las semanas | Agencia / equipo |

#### Créditos (la vía barata)

Precios de trabajo (USD; Yape en PEN al tipo ~3.75). Ajustar al cobrar, no en código todavía.

| Pack | Créditos | Precio | ≈ PEN | Por build | Vs Pro |
|---|---|---|---|---|---|
| 1 app | 1 | **$4** | S/ 15 | $4 | Más barato que un mes si solo quieres **una** |
| Pack chico | 3 | **$10** | S/ 37 | $3.33 | Sigue ganando Pro a partir de **6 builds/mes** |
| Pack | 10 | **$29** | S/ 109 | $2.90 | Quien hace 10 de golpe; si es habitual, Pro ($19) gana |

**Regla para no canibalizar Pro:** el crédito sale **más caro por app** que el cupo de Pro. 5 builds a $4 = $20 ≥ $19. Quien usa el producto en serio se suscribe; quien prueba una vez no se asusta con $19.

**1 crédito se gasta en el Build exitoso**, no al escribir el prompt. Si el build falla antes de materializar, no se descuenta. Los créditos **no caducan** (simple de explicar).

Pago de créditos: el mismo que 5.1 (Yape / transferencia) con referencia `cred-user-pack`. Mock primero, igual que las suscripciones.

#### Flujo que el usuario entiende

```
Gratis: idea → spec (leer, editar, decisiones)
                │
                ▼
         ¿Quieres la app?
                │
     ┌──────────┴──────────┐
  $4 crédito (1 vez)    $19 Pro / mes
     └──────────┬──────────┘
                ▼
              Build
```

- **Entregables:** catálogo de planes + packs; `402` en `/api/build` si Free sin créditos; saldo de créditos en el panel; CTA “Comprar 1 crédito” o “Pasarte a Pro”. ✅ **CABLEADO (2026-09-22)**
- **Criterio de done:**
  - [x] Free puede generar/ver spec y **no** puede hacer Build.
  - [x] 1 crédito mock → 1 Build; el segundo Build sin saldo → 402 + ir a Planes.
  - [x] Pro/Enterprise hacen Build sin gastar créditos.
  - [x] Copy de Planes explica las dos vías (barata suelta vs mensual).
  - [ ] Pasarela real (Yape/transferencia) en vez de `MockPaymentProvider.buyCredits` — ver 5.1.

### 5.5 Control de límites (anti-pérdidas) (P0) ⭐

**Por qué:** sigue siendo la red de seguridad. Ahora Free **no construye**; el agujero sería spec-LLM infinito o Pro sin techo de modelo caro. **Debe existir ANTES de beta pública.**

- **Límites hard:**
  - `Free`: **0 builds**. Spec de demo: **1–2 / mes** (tope de LLM). 0 imágenes de pago. Identidad siempre mock.
  - `Créditos`: builds = saldo. Sin saldo = 402.
  - `Pro`: 50 apps/mes, 100 imágenes/mes, 50 verificaciones/mes. DeepSeek por defecto.
  - `Enterprise`: tope negociado (nunca “ilimitado” literal sin contrato).
- **Contadores:** `builds_this_month`, `specs_this_month`, `credits_balance`, `images_this_month`.
- **Validación server-side** en `/api/build` (y spec generate si Free ya usó el cupo de demo) **antes** de LLM/materializar.
- **Reset mensual** de cupos de plan (los créditos **no** se resetean).
- **Dashboard:** Free ve “0 builds — compra crédito o Pro”; Pro ve `12/50`; créditos ve saldo.
- **Casos extremos:** cancelar Pro a mitad de mes → Free demo + créditos que le queden. Bypass de cookies → el servidor manda. Build fallido → no descontar crédito. Admin de Studio puede Build para probar (excepción explícita, no el usuario).
- **Criterio de done:**
  - [x] Free → Build → 402. (smoke test)
  - [x] Free → 3er spec en el mes → 403. (lógica `authorizeSpec`; espejo del límite de build ya testeado)
  - [x] Crédito 0 → Build → 402. (smoke test)
  - [x] Pro en cupo → Build 200; Pro fuera de cupo → 403 (o gastar créditos si tiene). (smoke test)
  - [x] Tests de esos cuatro caminos (`backend/smoke-monetization.mjs`, 13/13).
  - [ ] Tests automatizados en CI (parte de Etapa 1.1) + reset mensual con clock inyectable.

> **Nota:** ✅ **CABLEADO (2026-09-22)** junto a 5.4. Falta pasarela real (5.1) y CI.

### 5.6 Anuncios en Free (P3 — opcional, ya no es el plan A)

Con Free reducido a **demo sin Build**, la sesión es corta y los ads **casi no recaudan**. Quedan como idea de respaldo si algún día Free vuelve a ser generoso. Si se retoman: un solo slot en el cromo de Studio, **nunca** dentro de la app generada, nunca en Pro. **No priorizar.**

---

## 💳 Apéndice A — Integración de pasarelas de pago (roadmap detallado)

> Este apéndice documenta **todo lo que hay que hacer** para integrar pasarelas reales (Stripe, Mercado Pago, Yape API). Sirve para cotejarlo contra el presupuesto y decidir cuándo implementar cada una. **No entra en los $20 iniciales** — es un proyecto aparte.

### A.1 Decisiones previas (lo que hay que definir ANTES de programar)

| Decisión | Opciones | Recomendación | Por qué |
|---|---|---|---|
| **Modelo de precios** | Por uso (créditos) / Suscripción / Híbrido | **Híbrido: Free demo + créditos + Pro/Ent** | Free no construye; $4 un build o $19/mes si usas seguido |
| **Primera pasarela** | Stripe / Mercado Pago / Yape API | **Yape API (BCP) o Mercado Pago** | Yape API si tienes comercio BCP; Mercado Pago es más fácil de arrancar (sin afiliación) |
| **Modo test primero** | Sí / No | **Sí (obligatorio)** | Toda pasarela tiene modo sandbox; probar ahí antes de usar dinero real |
| **Recurrencia automática** | Sí / Manual | **Sí (con cancelación fácil)** | Estándar de SaaS; sin esto el usuario tiene que "pagar otra vez" cada mes |
| **Webhook handling** | Síncrono / Asíncrono (cola) | **Asíncrono** | Un webhook puede tardar; si falla hay que reintentarlo → necesita cola (Etapa 6) |

### A.2 Stripe (pasarela internacional estándar)

**Ventajas:**
- Líder global, integración en 40+ países (incluido Perú).
- Modo test completo (tarjetas de prueba, webhooks locales con CLI).
- SDKs oficiales para Node, Python, Go, etc.
- Soporta suscripciones recurrentes con Stripe Billing.
- Checkout embebido (Stripe Elements) o redirect (Checkout Session).

**Desventajas:**
- Comisión internacional: **3.6% + $0.30** por transacción (en Perú es similar).
- Requiere registro como comercio (info de negocio, cuenta bancaria).
- Payout en USD → conversión a PEN con tipo de cambio de Stripe.

**Roadmap de integración (si eliges Stripe):**

| Paso | Qué hacer | Tiempo est. | Tokens/costo |
|---|---|---|---|
| 1. Registro en Stripe | Crear cuenta → modo test activado | 15 min | Manual |
| 2. Instalar SDK + Stripe CLI | `npm install stripe` + `stripe login` | 10 min | Manual |
| 3. Crear `StripeProvider` | Implementar interfaz `PaymentProvider` | 1-2h dev | ~$3-5 tokens |
| 4. Productos + precios | Crear en Stripe Dashboard: Free/$0, Pro/$X, Enterprise/$Y | 20 min | Manual |
| 5. Checkout Session | Endpoint `/api/checkout/stripe` → redirect a Stripe Checkout | 1h dev | ~$3 tokens |
| 6. Webhooks | Endpoint `/api/webhooks/stripe` → cola asíncrona + verificar firma | 2-3h dev | ~$5-8 tokens |
| 7. Portal de cliente | Stripe Customer Portal (cambiar plan, cancelar) → botón en UI | 1h dev | ~$2 tokens |
| 8. Testing en sandbox | Probar ciclo completo con tarjeta test `4242 4242 4242 4242` | 1-2h QA | Manual |
| 9. Activar modo live | Switch a claves live + configurar webhook en producción | 30 min | Manual |
| **Total Stripe** | | **~8-12h dev** | **~$13-18** |

**Costo recurrente:** comisión del 3.6% + $0.30 por transacción (se descuenta del cobro).

---

### A.3 Mercado Pago (pasarela latinoamericana)

**Ventajas:**
- Popular en LATAM, múltiples métodos: tarjeta, transferencia, efectivo (Oxxo, PagoEfectivo).
- Comisión más baja que Stripe en algunos países (~2.9% + impuesto).
- SDK oficial Node + checkout redirect o Link de pago.
- **Suscripciones** soportadas (Mercado Pago Subscriptions).

**Desventajas:**
- Documentación menos pulida que Stripe.
- Payout en moneda local (PEN en Perú) → más simple, pero menos global.
- Modo sandbox a veces tiene bugs (reportado por comunidad).

**Roadmap de integración (si eliges Mercado Pago):**

| Paso | Qué hacer | Tiempo est. | Tokens/costo |
|---|---|---|---|
| 1. Registro en Mercado Pago | Crear cuenta → activar desarrollador | 15 min | Manual |
| 2. Instalar SDK | `npm install mercadopago` | 5 min | Manual |
| 3. Crear `MercadoPagoProvider` | Implementar interfaz `PaymentProvider` | 1-2h dev | ~$3-5 tokens |
| 4. Crear preferencia de pago | Endpoint `/api/checkout/mercadopago` → preferencia + redirect | 1h dev | ~$3 tokens |
| 5. Webhooks (IPN) | Endpoint `/api/webhooks/mercadopago` → verificar firma + cola | 2-3h dev | ~$5-8 tokens |
| 6. Suscripciones | Plan recurrente con Mercado Pago Subscriptions | 2h dev | ~$4 tokens |
| 7. Testing en sandbox | Tarjetas test según país (ej. `5031 7557 3453 0604` MasterCard test) | 1-2h QA | Manual |
| 8. Activar modo producción | Switch a Access Token de producción + webhook HTTPS | 30 min | Manual |
| **Total Mercado Pago** | | **~8-12h dev** | **~$15-20** |

**Costo recurrente:** comisión del ~2.9% + impuestos por transacción.

---

### A.4 Yape API oficial (BCP — integración para comercios)

**Ventajas:**
- El método de pago más usado en Perú (penetración masiva).
- Comisión más baja que tarjetas (~1.5-2% según plan con BCP).
- Experiencia nativa: el usuario escanea QR con la app de Yape.

**Desventaas:**
- Requiere **afiliación como comercio con BCP** (proceso manual, verificación de negocio).
- **No tiene modo sandbox público** (a diferencia de Stripe/Mercado Pago); hay que coordinarlo con BCP para ambiente de pruebas.
- Documentación menos accesible (no es self-service como Stripe).

**Roadmap de integración (si eliges Yape API):**

| Paso | Qué hacer | Tiempo est. | Costo |
|---|---|---|---|
| 1. Afiliación BCP | Contactar al BCP, llenar formularios, verificar negocio | **Semanas** | Manual + papeleos |
| 2. Acceso a API Yape | BCP entrega credenciales de sandbox + documentación | 1-2 semanas | Manual |
| 3. Crear `YapeApiProvider` | Implementar interfaz `PaymentProvider` con API oficial | 2-3h dev | ~$5-8 tokens |
| 4. QR dinámico | Generar QR por transacción (no QR fijo) vía API | 1h dev | ~$3 tokens |
| 5. Webhooks Yape | BCP notifica el pago → endpoint `/api/webhooks/yape` + cola | 2h dev | ~$5 tokens |
| 6. Testing con BCP | Coordinar pruebas en sandbox con cuenta test BCP | 1-2h QA | Manual |
| 7. Activar producción | Switch a credenciales live + webhook HTTPS verificado | 30 min | Manual |
| **Total Yape API** | | **~6-9h dev** (sin contar afiliación) | **~$13-16** |

**Costo recurrente:** comisión del ~1.5-2% + costo de afiliación BCP (plan de comercio).

**Nota crítica:** la afiliación BCP puede tardar **semanas/meses** según tu situación de negocio. Por eso en la Etapa 5.1 propuse **Yape manual** (QR fijo, sin API) como solución temporal mientras se tramita.

---

### A.5 Comparación de esfuerzo y decisión

| Pasarela | Esfuerzo dev | Costo tokens | Comisión/txn | Tiempo setup negocio | Cuándo elegirla |
|---|---|---|---|---|---|
| **Stripe** | ~8-12h | ~$13-18 | 3.6% + $0.30 | Días (registro online) | Audiencia global, quieres suscripciones recurrentes automáticas, documentación A+ |
| **Mercado Pago** | ~8-12h | ~$15-20 | ~2.9% + imp | Días (registro online) | Audiencia LATAM, comisión más baja, múltiples métodos de pago locales |
| **Yape API (BCP)** | ~6-9h | ~$13-16 | ~1.5-2% | **Semanas/meses** (afiliación BCP) | Audiencia 100% peruana, comisión más baja, método preferido por usuarios locales |
| **Yape manual (5.1)** | ~2-3h | ~$5 | 0% (directo) | **0** (sin afiliación) | **MVP/prueba de concepto**, validar cobro antes de pagar comisiones |

**Mi recomendación por fases:**

1. **Fase MVP (ahora, $20)**: Yape manual + transferencia bancaria (Etapa 5.1) → validas el flujo, $0 comisión.
2. **Fase Beta (primer mes con usuarios reales)**: **Mercado Pago** → self-service, rápido, buenas comisiones en LATAM, soporta múltiples métodos.
3. **Fase Scale (cuando tengas >100 usuarios pagos)**: Yape API oficial (tramitar afiliación BCP ahora, usar en 2-3 meses) + mantener Mercado Pago.
4. **Fase Global (si expandes fuera de LATAM)**: Stripe → mejor para audiencia internacional.

---

### A.6 Presupuesto total de pasarelas (para cotejarlo)

| Concepto | Monto |
|---|---|
| Desarrollo Yape manual (5.1) | ~$5 tokens |
| Desarrollo Mercado Pago completo | ~$15-20 tokens |
| Desarrollo Stripe completo | ~$13-18 tokens |
| Desarrollo Yape API (tras afiliación) | ~$13-16 tokens |
| Testing + ajustes | ~$5-10 tokens |
| **Total si haces las 3 pasarelas** | **~$50-70 tokens** (no lo hagas todo a la vez) |
| **Costo operacional mensual** | Comisión por transacción (0% manual → ~3.6% Stripe) |

**Recomendación de gasto:** empezar con **Yape manual ($5)** → cuando recargues, hacer **Mercado Pago ($20)** → luego decidir Yape API o Stripe según tu audiencia.

---

## Etapa 6 — Escalabilidad + procesamiento asíncrono (crítico) ⭐

**Por qué (esto NO estaba y es super importante):** hoy el backend del Studio procesa una solicitud a la vez, de forma **síncrona**. Si dos usuarios piden "generar app" al mismo tiempo, el segundo espera. Cuando escale a decenas/miles de solicitudes concurrentes, un diseño síncrono **colapsa** (timeouts, memory leaks, requests que mueren).

**Objetivo:** que el sistema pueda trabajar con **muchas solicitudes a la vez**, sin bloquearse, y que las tareas largas (generar spec, materializar, generar imágenes) corran en **background** de forma asíncrona.

### 6.1 Cola de trabajos (job queue) (P0)
- **Entregables:**
  - **`BullMQ` + Redis** (o `pg-boss` sobre Postgres si queremos evitar Redis) para encolar las tareas largas: `generate-spec`, `materialize`, `generate-image`.
  - El endpoint HTTP recibe la petición y responde **inmediatamente** con un `jobId` (202 Accepted), en vez de bloquear hasta terminar.
  - El frontend **hace polling** (o usa WebSocket/SSE) del `jobId` para mostrar el timeline de progreso en vivo.
  - **Retries con backoff exponencial** para llamadas a LLM/imágenes que fallan.
  - **Concurrencia configurable** (p. ej. 5 workers) para procesar N solicitudes en paralelo.
- **Criterio de done:** lanzar 20 "generar app" a la vez → todos se encolan, se procesan en paralelo, y ningún request bloquea al otro.

### 6.2 Workers separados del servidor HTTP (P0)
- **Entregables:** el servidor API (que responde rápido) y los **workers** (que hacen el trabajo pesado) corren como procesos separados. Escalan de forma independiente.
- **Criterio de done:** puedo subir 1 servidor API + 5 workers sin tocar código (solo réplicas).

### 6.3 Estado y resultados persistentes (P0)
- **Entregables:** cada job guarda su estado (`queued → running → done/failed`) y su resultado en la DB, de modo que un job **sobrevive a un reinicio** del servidor.
- **Criterio de done:** matar el servidor a mitad de un job → el job se reanuda o reintenta al volver, no se pierde.

### 6.4 SQLite → Postgres (P1)
- **Entregables:** el Studio usa SQLite (está bien para 1 usuario); para concurrencia real hay que migrar a **Postgres** (con pooling) y manejar transacciones. Las apps generadas ya tienen la capa `db.js` preparada para cambiar.
- **Criterio de done:** concurrencia de escritura sin lock de SQLite ni "database is locked".

### 6.5 Límites y backpressure (P1)
- **Entregables:** rate limiting por usuario (no saturar el sistema), límites de concurrencia por plan, y **backpressure** (si la cola está llena, encolar con prioridad, no reventar).
- **Criterio de done:** un usuario no puede tumbar el sistema haciendo 100 requests en bucle.

> **Nota de costo:** Redis gestionado (Upstash/Redis Cloud) tiene tier gratis; BullMQ es open-source. En arranque se puede usar `pg-boss` sobre Postgres para no pagar un Redis aparte.

---

## Etapa 7 — Producción (para que sea un producto real)

- **Hosting + dominios personalizados** (P2): desplegar apps generadas a un subdominio/dómino del cliente.
- **Observabilidad** (P2): logs estructurados, métricas RED, alertas (ya está en el framework, falta en el Studio).
- **Hardening** (P2): rate limiting, HTTPS, backups de SQLite, rotación de secretos.
- **Criterio de done:** una app generada puede vivir en producción con dominio propio y monitoreo.

---

## Etapa 8 — Ecosistema (a futuro)

- **Marketplace de plantillas/agentes** (P3): vender blueprints verticales.
- **Self-host enterprise** (P3): SSO, auditoría, multi-usuario.
- **Analytics de uso** (P3): funnel (prompt→build→pago), retención, costo por usuario.

---

## Etapa 9 — Calidad por revisión adversaria + slices + quality spec (P0) ✅

**Por qué:** dos agujeros de calidad que un solo "review al final" no tapa: (1) un **spec fino** llega al materializador y produce una app genérica; (2) una implementación **superficial** se da por "hecha" sin que nadie cuestione su arquitectura. Esta etapa mete **fricción de calidad** en los dos puntos.

### 9.1 Post-implementation review: arquitecto + revisor (adversarial)

**La idea (adaptada de una sugerencia externa):** después de la implementación hay un step donde **dos agentes discuten la arquitectura**.

- **Arquitecto** (`chief_engineer`) entra en **modo hipótesis** y, **ignorando el código**, pregunta: *"¿es esta la mejor forma de resolver esto? ¿por qué alguien haría esto? ¿cuál era la intención de quien hizo este trabajo?"*.
- **Revisor** (`architecture_reviewer`) **va al código** y prueba las hipótesis del arquitecto (lee código, traza intent vs. implementación, corre/inspecciona tests), marcando cada una CONFIRMADA / REFUTADA / NO VERIFICADA con evidencia (`file:line`).
- Al final deciden si conviene **refactor** (romper y rehacer) o si la implementación es **suficientemente sólida para solo endurecerla (hardening)**.
- La implementación se trata como un **"cutre borrador"**: se puede romper y rehacer, pero **justificando entre ellos por qué y con qué se reemplaza** (forma concreta, no un deseo).

### 9.2 Slices como checkpoints

**La idea:** dividir todo en **slices**; un slice es solo un **checkpoint** para revisar antes de seguir al siguiente.

```
Implementa slice → revisor → fix → revisor → hasta 2 intentos de fix
   → si tras 2 intentos sigue mal, se anota lo que quedó sin resolver
→ siguiente slice → review → fix → (todo lo no resuelto tras la 2ª ronda se anota como pendiente)
```

- **Slice comodín al final:** al terminar el último slice, se lanza un slice que revisa **todos** los slices contra **todos** los hallazgos pendientes + lo que aparezca nuevo.
- Este slice de revisión tiene **hasta 10 intentos** review → fix.
- **Escalada:** si el fixer falla muchas veces el mismo problema, el revisor le propone **implementar un refactor como parte del fix** (en vez de un tercer parche cosmético).
- Lo que quede sin resolver tras 10 intentos se anota como **deuda técnica explícita** (owner + severidad + por qué), no riesgo silencioso.

### 9.3 Sub-agente de calidad del project spec

**La idea:** un sub-agente que revise la calidad de los specs generados por el agente generador del Studio, midiéndolos contra un spec **bien rico** (benchmark: `PROJECT_SPEC.md`).

- **`spec_quality_reviewer`** puntúa cada spec generado con una **rúbrica de 12 dimensiones ponderadas** (visión, usuarios, flujo, dominio, data model, auth/RBAC, API, seguridad, infra, frontend/UX, scope discipline, success criteria) + **red-lines** que bloquean el build (sin data model, sin arquitectura, sin auth para apps con dinero, stack equivocado).
- Verdict: **EXCELLENT / GOOD / THIN / INSUFFICIENT**; un THIN/INSUFFICIENT se enriquece (feedback o regeneración) **antes** del build.
- Benchmark destilado en [spec_quality_rubric.md](.claude/templates/spec_quality_rubric.md).

### Entregables ✅ (2026-09-22)
- [x] Agente `architecture_reviewer` (revisor adversarial, modo evidencia).
- [x] `chief_engineer` con "modo hipótesis" documentado.
- [x] Agente `spec_quality_reviewer` + rúbrica `spec_quality_rubric.md` (12 dimensiones + red-lines).
- [x] Workflow `slice_review_workflow.md` (slices + wildcard slice + escalada a refactor).
- [x] Integrado en `sprint_workflow.md` (Stage 2.5), `CLAUDE.md` (cap. 26 + apéndice) y este roadmap.

### Pendiente (cuando toque)
- [ ] Cablear `spec_quality_reviewer` como gate real en CASF Studio (`/api/spec/quality`) — puntuación automática del spec antes del build.
- [ ] Autómatizar el slice review como paso del pipeline de generación.

---

## 🎯 Orden recomendado con ~$20 (mañana)

| Paso | Qué | Costo API | Impacto visual |
|---|---|---|---|
| 1 | **Etapa 5.4–5.5 — Free demo + créditos + 402 en Build** | No | Bajo (protección + cobro) ⭐ |
| 2 | Etapa 1.1 — tests del materializador (automatizar lo manual) | No | Bajo (seguridad) |
| 3 | **Etapa 2.1-2.4 — design system + iconos + animaciones + componentes premium** | No | **Altísimo** ⭐ |
| 4 | Etapa 3.1 — capa de imágenes con `mock` + fallback local | No | Medio |
| 5 | Etapa 3.2 (logo + hero) con Gemini imagen (**capas gratuitas**) | No (tier gratis) | **Alto** ⭐ |
| 6 | **Etapa 4.1 — animación propia (Ken Burns + Lottie) desde los assets** | No | **Alto** ⭐ |
| 7 | **Etapa 5.1 — Yape + transferencia bancaria en prueba** | No | Funcional |

**Lo que NO cabe en $20** (dejar para después): frontend React completo (1.2-A), video real imagen→video (4.2), pasarelas automatizadas Stripe/Mercado Pago (5.2), identidad real JSON.pe (5.3, opcional barato), **escalabilidad asíncrona (Etapa 6)**, hosting (7).

> **Nota importante:** **Build de pago** (crédito o Pro) es no negociable antes de beta pública. Documentado en 5.4–5.5. ✅ **El código ya está cableado (2026-09-22)** — falta solo la pasarela real (5.1) y los tests en CI.

---

## 💰 Presupuesto real de lanzamiento a producción (recalculado)

> Distinguir **tres** bolsas de dinero, no dos:
> 1. **Desarrollo** — tokens de agente (Cursor/DeepSeek) para construir el producto. No es recurrente.
> 2. **Operación fija** — infra mensual (VPS, dominio, DB). Recurrente aunque nadie use el producto.
> 3. **Costo variable (COGS)** — LLM + imágenes **por cada generación**. Crece con usuarios Free y pagos. Es lo que te puede fundir si no hay límites (Etapa 5.5).
>
> Tipo de cambio de trabajo: **1 USD ≈ S/ 3.75** (aprox. set 2026). Ajustar si el tipo se mueve. Precios de plan ya en código: **Free $0 / Pro $19 / Enterprise $99**.

### A. Costo de desarrollo (desglose real, no el resumen anterior)

El total anterior (~$108-162) **estaba incompleto**: agrupaba 1-4, no separaba 5.1–5.4, y no incluía buffer ni Etapa 7. Aquí va el recálculo.

| Bloque | Qué incluye | Bajo | Alto | ¿Hace falta para cobrar? |
|---|---|---|---|---|
| **5.4 + 5.5 Free demo, créditos, 402 en Build** | Planes + packs + contadores + tope de spec en Free | $10 | $18 | **Sí — antes de beta pública** |
| 1.1 Tests del materializador | Suite por dominio + backend generado + round-trip spec | $8 | $15 | Sí (evitar regresiones caras) |
| 1.2 Frontend generado modular (vanilla, no React) | Partir `app.js` monolito | $15 | $25 | No para MVP de cobro |
| 2.1–2.4 Design system + iconos + animaciones + anti-IA | Lo que más vende visualmente | $25 | $40 | Casi sí (si no, parece prototipo) |
| 3.1–3.2 Capa de imágenes + logo/hero | `ImageProvider` mock + Gemini tier gratis | $12 | $20 | No para cobrar; sí para “entrar por los ojos” |
| 4.1 Animación propia | Ken Burns + Lottie + CSS | $10 | $18 | No |
| 5.1 Yape + transferencia | QR, datos bancarios, `pending → paid` (planes y créditos) | $5 | $8 | **Sí — primer cobro** |
| 5.2 Mercado Pago (cuando toque) | Checkout + webhooks | $15 | $20 | No (después de validar cobro) |
| 5.3 Identidad real JSON.pe | Primer integrador peruano | $8 | $15 | No |
| 6 Colas + workers + Postgres | Escalabilidad real | $40 | $60 | No hasta ~50-100 usuarios concurrentes |
| 7 Producción (hardening, dominio, backups) | HTTPS, secretos, observabilidad mínima | $15 | $30 | Sí para dominio público serio |
| **Buffer 20%** (bugs, retrabajo, pulido) | Siempre aparece | $28 | $46 | Sí, presupuestarlo |

**Totales (desarrollo, no recurrente):**

| Paquete | Qué compras | USD | ≈ PEN |
|---|---|---|---|
| **Mínimo para no perder plata en público** | 5.5 + 5.1 + 5.4 + buffer chico | **$25–45** | S/ 95–170 |
| **MVP comercializable (recomendado)** | Mínimo + 1.1 + 2 + 3.1-3.2 + 4.1 + 7 básico | **$120–190** | S/ 450–715 |
| **Producto completo (etapas 1–7, sin React rewrite ni Stripe)** | MVP + 1.2 vanilla + 5.2 MP + 5.3 + 6 + 7 | **$210–330** | S/ 790–1 240 |
| **Con frontend React de apps generadas (1.2-A)** | Lo anterior + reescritura | **$250–410** | S/ 940–1 540 |

> Con **~$20 de recarga** no cierras el MVP comercializable. Cierras un trozo (límites **o** visual **o** Yape). El desarrollo se paga en **varias recargas** a lo largo de semanas, no en un solo golpe.
>
> Lo que **no** está en estos números: tu tiempo, IGV/empresa si facturas formal, afiliación BCP, ni anuncios pagos.

### B. Costo de operación mensual (infraestructura fija)

**Opción 1 — Arranque mínimo (1-50 usuarios): ~$15-25/mes (S/ 55–95)**

| Recurso | Proveedor | Costo/mes |
|---|---|---|
| VPS (API + workers) | Hetzner CPX11 / DigitalOcean $6 | $5-7 |
| Base de datos | SQLite en disco o Postgres Neon free | $0-5 |
| Cola de jobs | Redis Upstash free o pg-boss | $0 |
| Assets | Cloudflare R2 (10GB free) | $0 |
| CDN + HTTPS | Cloudflare free | $0 |
| Dominio | Namecheap/Cloudflare | ~$1-2 |
| Email | Resend free (3000/mes) | $0 |
| Errores | Sentry free | $0 |
| **Total** | | **~$15-25** |

**Opción 2 — Escalable (100-1000 usuarios): ~$60-120/mes (S/ 225–450)**

| Recurso | Proveedor | Costo/mes |
|---|---|---|
| API | Render / Railway / Fly.io | $25-40 |
| Postgres | Neon / Supabase pago | $10-25 |
| Cola + workers | Upstash Redis | $10-30 |
| Storage | R2 / S3 | $5-15 |
| Email + SMS | Resend + Twilio | $10-20 |
| Monitoreo | Sentry + logs | $10-30 |
| **Total** | | **~$60-120** |

**Opción 3 — 1000+ usuarios: $200-500+/mes.** Solo cuando ya haya MRR que lo pague.

### C. Costo variable por generación (COGS) — aquí se gana o se pierde

Arquitectura **hoy**: el materializador es código local (casi $0). El LLM paga sobre todo el **spec**. Precio DeepSeek chat en ledger: **$0.27 / $1.10 por millón** de tokens.

| Tipo de generación | Costo típico | Si se va de las manos |
|---|---|---|
| Spec con DeepSeek (flujo actual) | **$0.005–0.02** | $0.05 si el prompt es enorme |
| Spec + 2–5 imágenes Gemini de pago | **$0.04–0.15** | $0.30 si no hay caché |
| Spec + código generado por LLM (futuro, no es el materializador actual) | **$0.08–0.40** | **$1–3** si usas Claude/GPT-4o en cada build |

**COGS mensual por usuario si gastan todo el cupo (Etapa 5.5), con DeepSeek + imágenes de pago:**

| Plan | Cupo | COGS peor caso | Precio | ¿Aguanta? |
|---|---|---|---|---|
| Free | **0 builds**, 1–2 specs demo | **~$0.01–0.04** (solo spec) | $0 | Sí: casi no hay COGS. |
| Créditos | 1 build / crédito | **~$0.02–0.15** | $4 (o pack) | Sí, margen alto. |
| Pro | 50 apps + 100 imágenes | **~$4–12** (DeepSeek) / **$40–80** (si todo es Claude) | $19 | DeepSeek: sí. Claude en todo: **no — pierdes**. |
| Enterprise | “ilimitado” | Puede ser **cualquier cosa** | $99 | Solo con tope negociado o modelo dedicado. |

**Uso realista (nadie llena el cupo todos los meses):**

| Plan | Uso típico | COGS típico |
|---|---|---|
| Free | 1 spec, **0 builds** | **~$0.01–0.04** |
| Créditos | 1–3 builds sueltos | **$0.02–0.15** por build |
| Pro | 8–15 apps, 10–20 imágenes | **$0.80–3.00** |
| Enterprise | 30–80 apps, mix de modelos | **$8–25** (hay que medir) |

**Regla de oro del margen:** Pro a $19 debe correr **DeepSeek (o más barato) por defecto**. Modelos premium = extra del cupo o solo Enterprise. Sin esa regla, el plan Pro del código actual **no es sostenible**.

### D. Lo que dispara el costo (a vigilar)

1. **LLM por generación** — mitigación: DeepSeek default, caché de specs similares, Etapa 5.5.
2. **Imágenes** — mitigación: mock/tier gratis primero, caché, cupo por plan.
3. **Spec Free sin techo** — alguien puede spamear generate. Mitigación: 1–2 specs/mes en Free + rate limit.
4. **Concurrencia** — más users = más CPU. Mitigación: cola (Etapa 6) + no subir a opción 2 de infra hasta tener MRR.
5. **Churn + reembolsos** — un Pro que genera 40 apps y cancela el día 28 te deja el COGS y te quita el ingreso del mes siguiente.

### E. Recálculo consolidado (números para decidir)

| Concepto | USD | ≈ PEN |
|---|---|---|
| Desarrollo hasta MVP comercializable | $120–190 | S/ 450–715 |
| Desarrollo hasta producto 1–7 | $210–330 | S/ 790–1 240 |
| Infra arranque / mes | $15–25 | S/ 55–95 |
| Infra escalable / mes | $60–120 | S/ 225–450 |
| COGS por Pro típico / mes | $0.80–3 | S/ 3–11 |
| Recargas de desarrollo mientras construyes / mes | $20–40 | S/ 75–150 |

> **Conclusión:** lanzar “digno” cuesta **~$120–190 de desarrollo** (varias recargas) + **$15–25/mes de infra**. El riesgo ya no es “Free regala 3 apps”: es **spec-LLM sin tope** y **Pro con Claude**. Build se paga (crédito o suscripción).

---

## 📈 Predicciones de ingresos (realistas) y umbral de auto-sostenibilidad

> Esto **no** es un pitch. Es una hoja para no autoengañarse. Hipótesis de mercado: SaaS nicho LATAM, founder solo, cobro inicial por Yape/transferencia, **cero presupuesto de ads** al inicio. Competidores (Lovable, v0) cobran ~$20–25/mes: **$19 Pro es creíble**, no barato-sospechoso.
>
> Conversión Free→pago en herramientas de este tipo, **orgánica y sin marca**: 1–5% es lo normal. 8% ya es **bueno**. 15% sería excepcional y no lo usamos como base.

### F. Unidad económica (un usuario Pro)

```
Ingreso Pro:              $19.00
Comisión pasarela MVP:     $0.00  (Yape/transferencia)
Comisión MP/Stripe luego: ~$0.55–0.70  (si automatizas)
COGS típico:              $0.80–3.00
Infra prorrateada*:       $0.50–2.00
────────────────────────────────
Margen de contribución:   ~$14–17  (Yape + DeepSeek + límites)
```

\*Infra $20 / N usuarios pagos. Con 10 Pro ≈ $2/user; con 40 Pro ≈ $0.50/user.

**Un Pro “paga” ~1.2–2 meses de infra de arranque.** El negocio se cae si: (a) Free es caro, (b) Pro usa Claude a lo bruto, (c) no hay conversión.

**Unidad crédito (1 build a $4):** COGS ~$0.02–0.15 → margen **~$3.80**. Es la vía de entrada. No sustituye Pro: a las 5 apps del mes ya conviene el $19.

**Unidad Free:** casi $0 de ingreso y casi $0 de COGS (sin Build). No hace falta ads para sostenerla.

**Unidad Pro no cambia:** $19 y **cero ads**. Mezclar anuncios en lo pago destruye el argumento de upgrade.

### G. Ingresos necesarios para que sea auto-sostenido

Definir “auto-sostenido” en **cuatro peldaños** (si no, “escalable” significa cualquier cosa).

| Nivel | Qué cubre de verdad | MRR mínimo | Equivalente (mix 90% Pro / 10% Ent) | ≈ PEN/mes |
|---|---|---|---|---|
| **0. Supervivencia** | Solo infra $20 + LLM de Free/Pro | **$50–80** | 3–5 Pro | S/ 190–300 |
| **1. Auto-sostenido técnico** | Infra + COGS + recargas de mantenimiento $30 + 20% buffer | **$150–220** | 8–12 Pro | S/ 560–825 |
| **2. Auto-sostenido personal** | Nivel 1 + ingreso mínimo fundador **$400–500** (medio tiempo, Perú) | **$650–850** | ~28–40 Pro **o** 6 Ent + 10 Pro | S/ 2 400–3 200 |
| **3. Escalable** | Infra opción 2 ($90) + COGS $120–200 + fundador $800 + $100 ads | **$1 400–1 800** | ~70–90 Pro **o** 10 Ent + 40 Pro | S/ 5 250–6 750 |
| **4. Contratar** | Nivel 3 + 1 persona part-time ~$600 | **$2 200–2 800** | mix Enterprise de verdad | S/ 8 250–10 500 |

**Punto de equilibrio técnico (nivel 1), números redondos:**

- Fijos: $25 infra + $30 recarga + COGS de specs demo ≈ **$55–60**
- Margen por Pro ≈ **$15**; margen por crédito ≈ **$3.80**
- **Break-even ≈ 4–7 Pro** **o** una mezcla (p. ej. 2 Pro + ~8 créditos vendidos).
- Margen por Pro ≈ **$15**
- **Break-even ≈ 5–8 usuarios Pro de verdad** (pagando cada mes, no trial).
- Con **2 Enterprise** ($198) ya estás cerca del nivel 1 **aunque tengas pocos Pro**.

Hasta no llegar al **nivel 1**, el producto es un **hobby subsidiado**. Hasta el **nivel 2**, no es un sueldo. “Escalar infra” (opción 2/3) **antes del nivel 2** es la forma clásica de fundirse.

### H. Cuatro escenarios a 12 meses (desde beta pública)

Supuestos comunes (explícitos, para poder mentirte después con datos):

- Precio congelado: Free $0 / Pro $19 / Enterprise $99.
- Entre los de pago: **90% Pro, 10% Enterprise** (en malo/crítico: 100% Pro).
- CAC ≈ $0 (orgánico, conocidos, comunidades). Si pagas ads, resta ese dinero del MRR.
- Churn = % de pagos que se van **cada mes**.
- Free **siempre** con cupo 5.5. Si quitas el cupo, el escenario “crítico” se adelanta.

#### 🟢 Caso bueno (aún realista, no unicornio)

Señal: hay nicho claro (p. ej. pymes peruanas / agencias), el visual ya no parece IA, cobras por Yape sin fricción, 1–2 casos de uso se corren de boca en boca.

| Mes | Usuarios activos | Conversión | Pagos (Pro+Ent) | Churn | MRR | COGS+infra (est.) | Resultado |
|---|---|---|---|---|---|---|---|
| 1 | 30 | 0% (beta) | 0 | — | $0 | $25 | Pérdida chica |
| 3 | 90 | 5% | 4 Pro | 5% | $76 | $35 | Casi break-even infra |
| 6 | 180 | 7% | 11 Pro + 1 Ent | 4% | $308 | $55 | **Nivel 1** |
| 12 | 350 | 8% | 22 Pro + 3 Ent | 4% | **$715** | $90 | **Nivel 2 justo** |

- MRR año 1 cierre: **~$700**. Ingreso anualizado ~$8k si se mantiene (no es “empresa”, es **sueldo medio tiempo + producto vivo**).
- Qué lo hace bueno: retención (churn ≤5%), 3 Enterprise reales (agencias), Free barato de operar.

#### 🟡 Caso regular (el más probable si lanzas sin ads y con producto “correcto”)

Señal: gente prueba, 2–4 pagan, el resto se queda en Free o no vuelve. No hay explosión ni desastre.

| Mes | Usuarios activos | Conversión | Pagos | Churn | MRR | COGS+infra | Resultado |
|---|---|---|---|---|---|---|---|
| 1 | 15 | 0% | 0 | — | $0 | $22 | Hobby |
| 3 | 50 | 2% | 1 Pro | 8% | $19 | $30 | A pérdida leve |
| 6 | 110 | 3% | 3 Pro | 7% | $57 | $40 | **No cubre recargas** |
| 12 | 200 | 3.5% | 6 Pro + 0 Ent | 7% | **$114** | $50 | **Entre nivel 0 y 1** |

- Cierre año 1: **~$100–120 MRR**. El VPS se paga; **tú no**. Sostenible solo como side-project.
- Riesgo silencioso: 200 Free × $0.10 COGS = $20 extra. Sin 5.5, este caso se vuelve malo.

#### 🟠 Caso malo (producto usable, mercado frío o cobro friccionado)

Señal: registros hay, pagos casi no. O pagan 1 mes y se van (churn alto). Yape manual se traba (“¿ya pagué?”).

| Mes | Usuarios activos | Conversión | Pagos | Churn | MRR | COGS+infra | Resultado |
|---|---|---|---|---|---|---|---|
| 1 | 10 | 0% | 0 | — | $0 | $20 | — |
| 3 | 35 | 1% | 0–1 Pro | 12% | $0–19 | $35 | Free come más que Pro |
| 6 | 70 | 1% | 1 Pro | 12% | $19 | $45 | **Pérdida $25/mes** |
| 12 | 90 | 1% | 1–2 Pro | 15% | **$19–38** | $50 | **Inviable como negocio** |

- Cierre año 1: **menos de $40 MRR**. Seguir invirtiendo $20–40/mes en recargas es **regalar tiempo y plata**.
- Causa típica: parece demo, no hay un vertical que duela, o el Free ya “alcanza”.

#### 🔴 Caso crítico (abuso, o nadie quiere pagar, o la API se dispara)

Señal: factura de LLM sube y el ledger no tiene ingresos. Bots en registro. Un usuario Free (sin 5.5) genera en bucle. O 0 pagos a mes 4.

| Mes | Qué pasa | MRR | Costo real | Resultado |
|---|---|---|---|---|
| 1–2 | Lanzas público sin límites duros | $0 | Infra $20 + LLM **$40–120** | Hemorragia |
| 3 | 1 pago que pide reembolso / chargeback | $0–19 | Sigue el COGS | Desmoraliza |
| 4 | Cortes: o apagas Free, o apagas el producto | $0 | Aún pagas dominio/VPS | **Parar** |

- Pérdida plausible en 90 días: **$150–400** (APIs) + recargas de desarrollo. No es “startup risk”; es **cuenta de luz de tokens**.
- Este caso es **evitable** al 80% con Etapa 5.5 + DeepSeek default + registro con fricción mínima (email verify).

### I. Lectura honesta de los cuatro casos

| Caso | Probabilidad (juicio, no ciencia) | ¿Auto-sostenido a 12 meses? | Qué hacer |
|---|---|---|---|
| Bueno | 15–25% si vertical + visual + cobro fácil | Nivel 2 **justo** | No subir infra a opción 2 todavía |
| Regular | **40–50%** (base) | Nivel 0–1 | Side project; no dejar el trabajo |
| Malo | 20–30% | No | Activar contingencia naranja |
| Crítico | 10–15% sin 5.5; **menos de 5%** con 5.5 bien hecho | No, y quema caja | Contingencia roja **esa semana** |

**Para ser “escalable y auto-sostenido” (nivel 2–3) hace falta, en números:**

- **Mínimo absoluto:** ~**8–12 Pro** retenidos (nivel 1).
- **Mínimo para que te pague medio tiempo:** ~**$650–850 MRR** ≈ **30 Pro** o **5–8 Enterprise** de agencia.
- **Mínimo para escalar infra de verdad:** no gastar $90/mes de Railway **hasta** tener ~**$1 400 MRR** (nivel 3).

Si a **mes 6** no hay **≥3 pagos reales** (Yape confirmados), el caso ya no es “bueno”: es regular o malo. Decidir con el ledger, no con esperanza.

---

## 🛟 Apéndice B — Planes de contingencia cortos

> Guardados aquí a propósito: cuando el mes salga feo, no hay que inventar el plan a las 2 a.m. Se ejecuta el de la fila que toque.

### B.1 Semáforo (revisar cada 30 días con el ledger)

| Semáforo | Trigger objetivo | Plan |
|---|---|---|
| 🟢 Bueno | MRR ≥ $250 **y** churn menor a 6% **y** COGS menor a 20% del ingreso | Seguir roadmap visual/producto. **No** subir de infra. Reinvestir 30% del margen en Etapa 2/3, no en ads caros. |
| 🟡 Regular | MRR $80–250 o conversión 2–4% | Congelar Etapa 8 y 1.2-A (React). Bajar Free a **1 app/mes**. Un solo vertical de marketing (ej. “barberías/pymes Perú”). Cobro solo Yape. |
| 🟠 Malo | MRR menor a $50 a mes 4 **o** churn mayor a 12% **o** Free COGS mayor que ingresos | Activar **B.3**. Dejar de recargar Cursor “por si acaso”. |
| 🔴 Crítico | LLM/imágenes mayor a $40 en un mes con MRR ≈ 0 **o** un usuario con más de 50 generaciones | Activar **B.4 el mismo día**. No esperar a fin de mes. |

### B.2 Si el caso es bueno

1. No contratar ni pasar a opción 2 de infra.
2. Subir Pro a **$24** solo si hay lista de espera o el cupo se satura; si no, dejar $19.
3. Buscar **2–3 agencias** a Enterprise ($99) a mano (WhatsApp), no con landing genérica.
4. Guardar 2 meses de infra en efectivo ($50) antes de cualquier experimento de ads.

### B.3 Si el caso es regular o malo (producto vivo, plata no)

1. **Free se vuelve demo:** 1 app, sin imágenes de pago, modelo mock o DeepSeek con tope $0.05/user.
2. **No compensar con ads.** Free ya no construye. Si no hay pagos: créditos más visibles (S/15) o “Build = pagar”.
3. **Generar = pagar:** el build completo requiere Pro (aunque sea 1 mes). El spec preview puede seguir gratis.
4. **Ingreso puente:** 1–2 trabajos de implementacion/consultoría usando CASF (S/ 800–2 000 por app entregada a un negocio real). Eso **no** escala, pero cubre recargas.
5. Pausar imágenes, identidad real, y Etapa 6.
6. Mensaje público honesto: “beta de pago, cupos limitados”. Escasez real, no marketing.

### B.4 Si el caso es crítico (está sangrando)

Ejecutar **en este orden**, el mismo día:

1. **Kill switch:** `IMAGE_PROVIDER=mock`, LLM mock o DeepSeek con presupuesto diario (hard cap en código, no “ojo”).
2. Cerrar registro público (invite-only / waitlist).
3. Bajar workers a 0; dejar el VPS más barato o solo local.
4. Auditar el ledger: quién generó, cuánto costó. Banear abuso.
5. Reembolsar si alguien pagó y no puede usar el producto (reputación vale más que $19).
6. **No** reescribir el materializador “para salvarlo” esa semana. El problema es de **caja y límites**, no de features.
7. Reabrir solo cuando 5.5 esté en producción y el cap diario de API esté probado.

### B.5 Contingencias extra (cortas, por si acaso)

| Amenaza | Plan corto |
|---|---|
| DeepSeek sube precios o se cae | Cambiar default a un modelo igual de barato; Pro no incluye Opus. El `cost.ts` ya es agnóstico. |
| Yape no escala / discusiones de “ya pagué” | Pasar a Mercado Pago (5.2) **solo** si hay ≥10 pagos/mes que duelan. Hasta entonces, exigir voucher + referencia única. |
| Un competidor saca lo mismo más bonito | No pelear en UI genérica. Empujar el foso: spec + memoria + costos + vertical Perú (PEN, Yape, DNI). |
| Te quedas sin recargas a mitad de una etapa | Entregar 5.5 + 5.1. Todo lo visual espera. Un producto feo que no pierde plata gana a uno lindo que sí. |
| IGV / formalización | Mientras cobres informal por Yape y sea poco, documenta ingresos. Al cruzar ~nivel 2, cotizar recibo por honorarios o empresa; el MRR debe aguantar 8–18% extra. No formalices en caso malo “por si acaso”. |
| Quieres “escalar” porque hay 20 usuarios Free | Usuarios Free **no** son tracción de negocio. Escalar = usuarios **de pago retenidos**. |
| Los ads se vuelven invasivos | No aplicar. El plan A es Free demo + créditos, no publicidad. |

### B.6 Caja mínima de seguridad (personal)

Antes de beta pública, tener **aparte del presupuesto de desarrollo**:

| Reserva | Para qué | Monto |
|---|---|---|
| 3 meses de infra opción 1 | El producto no se apaga si un mes no cobra | **$45–75** |
| Cap de API prepagado | DeepSeek/Gemini no se van a crédito loco | Tope **$10–20** |
| No mezclar | Recargas de Cursor ≠ plata de vivir | Cuentas o bolsillos separados |

Si esa reserva no existe, **no hay beta pública**. Hay demo local y cobro 1-a-1 por WhatsApp a conocidos (caso “consultoría puente”).

---

## 🚦 Definición de "terminado" global (cuando el producto deje de parecer IA)

- [ ] Una app generada es **indistinguible de una plantilla premium** a simple vista.
- [ ] Cero emojis, cero tablas planas, cero tipografía por defecto.
- [ ] Animaciones sutiles y con propósito (no decoración vacía).
- [ ] Logos + imágenes de producto generadas (con fallback local sin costo).
- [ ] Todo accesible (teclado + contraste + `prefers-reduced-motion`).
- [ ] Cada asset generado está **contabilizado en el ledger de costos**.
- [ ] El sistema **procesa solicitudes en paralelo** (cola + workers), no una a la vez.
- [ ] **Los límites por plan están implementados y validados** — ningún usuario puede consumir más recursos de los permitidos, protegiendo el margen del negocio.
- [ ] El ledger permite ver si estamos en semáforo 🟢/🟡/🟠/🔴 (Apéndice B) sin adivinar.

---

<!-- CASF · ETAPAS_SIGUIENTES.md -->
