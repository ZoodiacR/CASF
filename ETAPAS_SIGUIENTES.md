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
| 5 | Comercialización: **control de límites (P0)** + Yape/transferencia + identidad + suscripciones | P0 | 💰💰 | No (manual) |
| 6 | **Escalabilidad + procesamiento asíncrono** (colas, concurrencia) | P0 | 💰💰💰 | Sí (infra) |
| 7 | Producción: hosting, dominios, observabilidad, hardening | P1 | 💰💰💰 | Sí (infra) |
| 8 | Ecosistema: marketplace, self-host, analytics | P3 | 💰💰💰 | Sí |

> **Con $20 recomiendo:** Etapa 1 (parcial) + Etapa 2 completa + Etapa 3 (logo + hero, con capas gratuitas + fallback local) + Etapa 4.1 (animación propia) + Etapa 5.1 (Yape/transferencia en prueba).
> Las etapas 2, 3 y 4 son las que más impacto dan en "que entre por los ojos" y "deje de parecer hecho por IA"; la 5.1 valida el cobro sin costos de pasarela.

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

### 5.4 Suscripciones Free/Pro/Enterprise (P1)
- **Entregables:** planes con límites (apps/mes, imágenes/mes), flujo de upgrade, gestión de suscripción.
- **Criterio de done:** un usuario Free choca con un límite y puede hacer upgrade pagando (por Yape/transferencia en prueba).

### 5.5 Control de límites y versión de prueba (anti-pérdidas) (P0) ⭐
- **Por qué:** esta es la funcionalidad **más crítica para no arruinarte** — sin límites efectivos, un usuario puede generar 1000 apps en el tier Free y consumir $100 de LLM/imágenes que tú pagas. **Debe implementarse ANTES de abrir el producto al público**, incluso en fase de prueba.
- **Entregables:**
  - **Límites hard (bloqueantes)** por plan:
    - `Free`: 3 apps/mes, 5 imágenes/mes, 0 identidades reales (siempre mock).
    - `Pro`: 50 apps/mes, 100 imágenes/mes, 50 verificaciones de identidad/mes.
    - `Enterprise`: ilimitado (o límite negociado).
  - **Contador en tiempo real** (en `state.json` o DB) de: `apps_generated_this_month`, `images_generated_this_month`, `identity_checks_this_month`.
  - **Validación antes de consumir recursos** — el endpoint `/api/generate` verifica el plan del usuario y su contador ANTES de llamar al LLM. Si el límite está agotado, responde `403 Forbidden` con mensaje "Límite mensual alcanzado. Upgrade a Pro para continuar."
  - **Reset mensual automático** — un cron job (o un chequeo al autenticar) que reinicia los contadores el primer día de cada mes.
  - **Dashboard de uso** en el frontend — el usuario ve en todo momento cuánto ha consumido (`3/3 apps generadas este mes`) y cuándo se resetea.
  - **Degradación graceful** — para límites "suaves" (ej. usar modelo LLM más barato cuando el usuario está cerca del límite), aunque esto es opcional y puede complicar.
- **Casos extremos a manejar:**
  - Usuario que cancela su suscripción Pro a mitad de mes → se le respeta el uso hasta fin de mes, luego baja a Free.
  - Usuario que hace bypass (manipula cookies/tokens) → validación server-side en cada request, nunca confiar en el frontend.
  - Usuario que arranca una generación justo antes de alcanzar el límite → usar transacciones atómicas (incrementar contador + iniciar job en la misma transacción).
  - Request que falla después de consumir tokens → **no incrementar contador** si el job falla en etapas tempranas (parsing), solo si consumió LLM/imágenes.
- **Criterio de done:** 
  - [ ] Un usuario Free que intente generar la 4ta app recibe error 403 con mensaje claro de upgrade.
  - [ ] El contador se resetea automáticamente el día 1 de cada mes.
  - [ ] El dashboard muestra el uso en vivo (`2/3 apps, 1/5 imágenes`).
  - [ ] Ningún endpoint de generación consume recursos sin validar límites primero.
  - [ ] Tests automatizados que verifican: `user_free.generate() x 3 → ok, x 4 → 403`.
- **Impacto en seguridad financiera:** esta funcionalidad protege el margen de ganancia — sin ella, el usuario puede consumir más de lo que paga (o regala en Free) y el negocio opera a pérdida.

> **Nota crítica:** implementar ANTES de compartir el producto públicamente, incluso en beta cerrada. Dejar para después es un riesgo financiero alto.

---

## 💳 Apéndice A — Integración de pasarelas de pago (roadmap detallado)

> Este apéndice documenta **todo lo que hay que hacer** para integrar pasarelas reales (Stripe, Mercado Pago, Yape API). Sirve para cotejarlo contra el presupuesto y decidir cuándo implementar cada una. **No entra en los $20 iniciales** — es un proyecto aparte.

### A.1 Decisiones previas (lo que hay que definir ANTES de programar)

| Decisión | Opciones | Recomendación | Por qué |
|---|---|---|---|
| **Modelo de precios** | Por uso (pay-per-app) / Suscripción fija / Híbrido | **Suscripción fija con límites** | Predecible para el usuario; ya está cableado en el código (`plans: Free/Pro/Enterprise`) |
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

## 🎯 Orden recomendado con ~$20 (mañana)

| Paso | Qué | Costo API | Impacto visual |
|---|---|---|---|
| 1 | **Etapa 5.5 — control de límites y anti-pérdidas (CRÍTICO)** | No | Bajo (protección financiera) ⭐ |
| 2 | Etapa 1.1 — tests del materializador (automatizar lo manual) | No | Bajo (seguridad) |
| 3 | **Etapa 2.1-2.4 — design system + iconos + animaciones + componentes premium** | No | **Altísimo** ⭐ |
| 4 | Etapa 3.1 — capa de imágenes con `mock` + fallback local | No | Medio |
| 5 | Etapa 3.2 (logo + hero) con Gemini imagen (**capas gratuitas**) | No (tier gratis) | **Alto** ⭐ |
| 6 | **Etapa 4.1 — animación propia (Ken Burns + Lottie) desde los assets** | No | **Alto** ⭐ |
| 7 | **Etapa 5.1 — Yape + transferencia bancaria en prueba** | No | Funcional |

**Lo que NO cabe en $20** (dejar para después): frontend React completo (1.2-A), video real imagen→video (4.2), pasarelas automatizadas Stripe/Mercado Pago (5.2), identidad real JSON.pe (5.3, opcional barato), **escalabilidad asíncrona (Etapa 6)**, hosting (7).

> **Nota importante:** la Etapa 5.5 (control de límites) es **no negociable** — debe implementarse ANTES de cualquier beta pública, incluso antes de las mejoras visuales. Sin ella, el producto puede operar a pérdida desde el día 1.

---

## 💰 Presupuesto real de lanzamiento a producción

> Importante: distinguir dos tipos de dinero:
> 1. **Costo de desarrollo** (tokens de agente para construir el producto) — esto es lo que recargas en DeepSeek/Cursor ($20 hoy, etc.).
> 2. **Costo de operación mensual** (infraestructura para que el producto viva en producción) — esto es **recurrente** y es lo que hay que presupuestar para lanzar.

### A. Costo de desarrollo (para terminar las etapas)

| Concepto | Estimación |
|---|---|
| **Etapa 5.5 (control de límites — CRÍTICO)** | ~$8-12 en tokens de agente |
| Terminar Etapas 1-4 (diseño + imágenes + animación propia) | ~$40-60 en tokens de agente |
| Etapa 5 (Yape/transferencia + suscripciones) | ~$20-30 |
| Etapa 6 (asíncrono + colas + Postgres) | ~$40-60 |
| **Total desarrollo (no recurrente)** | **~$108-162** repartidos en varias recargas |

> No es un solo pago: se va recargando a medida que avanzas. Con $20 hoy arrancas Etapa 2 + 3 + 4.1.

### B. Costo de operación mensual (infraestructura de producción)

**Opción 1 — Arranque mínimo (1-50 usuarios, validar sin arruinarte): ~$15-25/mes**

| Recurso | Proveedor | Costo/mes |
|---|---|---|
| VPS (API + workers) | Hetzner CPX11 / DigitalOcean $6 | $5-7 |
| Base de datos | SQLite en disco (arranque) o Postgres Neon free | $0-5 |
| Cola de jobs | Redis Upstash free tier o pg-boss | $0 |
| Almacenamiento de assets | Cloudflare R2 (10GB free) | $0 |
| CDN + HTTPS | Cloudflare free | $0 |
| Dominio | Namecheap/Cloudflare | ~$1-2 |
| Email transaccional | Resend free tier (3000/mes) | $0 |
| Monitoreo/errores | Sentry free tier | $0 |
| **Total mensual** | | **~$15-25** |

**Opción 2 — Escalable (100-1000 usuarios, serverless): ~$60-120/mes**

| Recurso | Proveedor | Costo/mes |
|---|---|---|
| API serverless | Render / Railway / Fly.io | $25-40 |
| Base de datos | Postgres gestionado (Neon/Supabase) | $10-25 |
| Cola + workers | Upstash Redis + trabajadores | $10-30 |
| Almacenamiento | Cloudflare R2 / S3 | $5-15 |
| Email + SMS | Resend + Twilio (verificación) | $10-20 |
| Monitoreo + logs | Sentry + BetterStack | $10-30 |
| **Total mensual** | | **~$60-120** |

**Opción 3 — Enterprise / multi-tenant (1000+ usuarios): $200-500+/mes**
- Postgres dedicado, Redis dedicado, múltiples workers autoscaling, backups, uptime SLA, SSO, etc. Solo cuando ya monetice.

### C. Lo que dispara el costo (a vigilar)

1. **Costo de LLM por generación** — cada "generar app" consume tokens. Mitigación: caché, modelos baratos (DeepSeek), y margen sobre el plan del usuario.
2. **Costo de imágenes (Gemini)** — cada imagen generada tiene costo. Mitigación: tier gratis + caché + límites por plan.
3. **Concurrencia** — más usuarios = más workers/CPU. Mitigación: cola + autoscaling + límites por plan.

> **Conclusión de presupuesto:** para **lanzar a producción de forma digna** necesitas ~$100-150 de desarrollo (repartidos) + **$15-25/mes de infraestructura** en arranque. Es un costo **muy bajo** para un SaaS; el mayor gasto no es la infraestructura, es **tu tiempo y los tokens de desarrollo**.

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

---

<!-- CASF · ETAPAS_SIGUIENTES.md -->
