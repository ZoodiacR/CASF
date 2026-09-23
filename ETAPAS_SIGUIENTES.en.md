# 🗺️ CASF Studio — Next stages (Technical roadmap)

> Complements `VENTAJAS_COMPETITIVAS.md` (business) and `PATRON_DE_DISENO.md` (architecture).
> Here is **what remains to build**, in what order, and what can be achieved with ~$20 of budget.
>
> **Baseline when writing this (2026-09-20):** MVP with a complete cycle
> `prompt → spec → generated app (frontend/ + layered backend + SQLite + validation + pagination) → preview → costs`.
> What follows is the path to make it **stop looking like a prototype and catch the eye**.

> 🇪🇸 [Lee esta documentación en español](ETAPAS_SIGUIENTES.md)

---

## 🧭 How to read this document

- **Priority** = P0 (blocking / high impact) → P3 (future).
- **Effort** = 💰 low / 💰💰 medium / 💰💰💰 high (in agent tokens + time).
- **API cost** = whether the stage consumes external APIs (images/video), in addition to tokens.
- Each stage has verifiable **deliverables** and **done criteria**.

---

## Executive summary

| # | Stage | Priority | Effort | API cost |
|---|---|---|---|---|
| 1 | Close debt: tests + real frontend | P0 | 💰💰💰 | No |
| 2 | **Professional visual design** (icons + animations + "anti-AI") | P0 | 💰💰💰 | No |
| 3 | **Image generation** (nano banana / Gemini image) | P1 | 💰💰 | Yes (free tier to test) |
| 4 | **Asset animation** (self-animation from images) | P1 | 💰💰 | No (static assets only) |
| 5 | Monetization: **Free demo + credits + Pro** (P0) + Yape + Build limits | P0 | 💰💰 | No (manual) |
| 6 | **Scalability + async processing** (queues, concurrency) | P0 | 💰💰💰 | Yes (infra) |
| 7 | Production: hosting, domains, observability, hardening | P1 | 💰💰💰 | Yes (infra) |
| 8 | Ecosystem: marketplace, self-host, analytics | P3 | 💰💰💰 | Yes |
| 9 | **Quality via adversarial review + slices + quality spec** | P0 | 💰💰 | No |

> **Status 2026-09-22:** ✅ 5.4–5.5 (Free demo + credits + 402 + limits) **is already wired and smoke-tested**. ✅ Stage 9 (adversarial review + slices + quality spec) **integrated into the framework** (agents + workflow + rubric + CLAUDE.md). With budget, the next highest-return item is **5.1 (Yape/transfer — first real payment)** or **Stage 2 (visual — catch the eye)**. Not both at once.
> Recalculated numbers, income predictions and contingencies: sections **💰** and **📈** plus **Appendix B**.

---

## Stage 1 — Close technical debt (foundation)

**Why:** it makes no sense to "beautify" a monolith. There are two gaps we carry:

1. **The frontend of generated apps is monolithic vanilla JS** (`app.js` of ~2000 lines), while the spec declares `React`. It works, but it doesn't scale or stay maintainable.
2. **There are no tests** for the materializer → every change can break widgets that already work.

### 1.1 Materializer tests (P0)
- **Deliverables:**
  - Test suite that: regenerates one app per domain (loyalty, store, restaurant, health, LMS, HR, inventory, CRM) and validates that key files exist and compile (`node --check`).
  - Test of the generated backend: start `server.js`, test `register/login/CRUD/pagination/validation` (already done manually; automate it).
  - Test of `parseProjectMd` ↔ `specToMarkdown` (round-trip).
- **Done criteria:** `npm test` green, and a CI that runs it on every push.

### 1.2 Real frontend for generated apps (P0)
- **Decision to make (you decide when you recharge):**
  - **(A) React + Vite + components** — aligned with what the spec promises, but rewriting the entire runtime (~10 widgets). 💰💰💰
  - **(B) Modular vanilla** — split the monolithic `app.js` into ES modules (`components/`, `widgets/`, `store.js`), no framework. Cheaper, keeps compatibility with the current preview. 💰💰
  - **(C) Hybrid** — start with (B) and progressively migrate to (A). 💰💰💰 (recommended mid-term)
- **Done criteria:** `app.js` stops being a monolith; each widget lives in its own module and is testable.

---

## Stage 2 — Professional visual design (the user's priority) ⭐

**Why:** the product today is "functional but ugly" — default typography, flat tables, generic colors. That's the "AI-made" stamp. This stage is **the highest visual return per dollar** because it **consumes no image APIs** (only code tokens).

### 2.1 Design system / tokens (P0)
- **Deliverables:**
  - **CSS token** file: `--color-primary`, `--color-surface`, `--radius-*`, `--shadow-*`, `--space-*`, `--font-*`.
  - **Palettes per theme** (apps already support dark/light theme; make them *beautiful*, not just functional).
  - **Typography with hierarchy** (display / heading / body / caption) — e.g. Inter, Poppins or Space Grotesk.
  - **Consistent spacing scale** (4/8/12/16/24/32/48).
- **Done criteria:** two complete themes (light/dark) that look deliberate, not default.

### 2.2 Professional icons (P0)
- **Deliverables:** replace emojis (📊👥📅⭐) with **vector SVG icons** from a coherent library (Lucide or Phosphor), inline in the runtime.
- **Done criteria:** zero emojis in the UI; icons with consistent `stroke`/`fill`, accessible (`aria-label`).

### 2.3 Animations and micro-interactions (P0)
- **Deliverables:**
  - Smooth **transitions** on hover/focus (buttons, cards, nav).
  - **Skeleton loaders** instead of spinners or empty screens.
  - **Staggered entrance** of cards/lists on load.
  - **Micro-interactions**: animated toasts, counters that "count up", buttons with press feedback.
  - **Scroll reveal** (IntersectionObserver) on sections.
- **Done criteria:** every interaction has visual feedback; `prefers-reduced-motion` respected.

### 2.4 "Premium" anti-AI components (P0)
- **Deliverables:**
  - **Hero section** with subtle gradient + headline with hierarchy (not a bare `<h1>`).
  - **Cards** with soft shadow (`box-shadow` with low alpha), rounded corners, hover lift.
  - **Empty states** illustrated ("No clients yet" with icon + CTA).
  - **Error/success states** that look good.
  - **Badges, chips, pills** for states (active/inactive, tiers).
  - **Redesigned tables** (rows with subtle separation, hover, sticky header) — today they are the most "AI" part of the app.
- **Done criteria:** a generated app looks comparable to a premium market template (Tailwind UI / shadcn), not to a chat response.

### 2.5 Responsive + accessibility (P1)
- **Deliverables:** verification on mobile/tablet/desktop; WCAG AA contrast; visible focus; targets ≥ 44px.
- **Done criteria:** full keyboard navigation + verified contrast.

> **Stage 2 result:** the same generator, but the **visual runtime** levels up. It's the change that "sells" the product fastest.

---

## Stage 3 — Image generation (nano banana / Gemini) ⭐

**Honest context:** what the community calls **"nano banana"** is Google's **image generation model (Gemini 2.5 Flash Image)**. It generates **high-quality static images** and supports conversational editing (requesting changes over the image). **It does not animate on its own** — to animate it is combined with Stage 4 (self-animation). **It has a free tier** → ideal for testing without spending.

### 3.1 Asset layer (provider abstraction) (P1)
- **Deliverables:** an agnostic `ImageProvider` (same as the existing `PaymentProvider`/`IdentityProvider`):
  - Real implementation → Gemini image (nano banana) via API.
  - `mock` implementation → locally generated SVG placeholder (no API, no cost).
  - **Cache** of generated images (don't regenerate the same image).
  - **Accounting**: each image adds its cost to the ledger (`cost.ts`), as tokens already do.
- **Done criteria:** `IMAGE_PROVIDER=mock` works at zero cost; `IMAGE_PROVIDER=gemini` generates a real image with registered cost.

### 3.2 Asset types to generate (P1)
- Project **logo** (SVG/PNG) on materialization.
- **Hero image / banner** cover.
- **Product images** (e-commerce) and profile/team **avatars**.
- **Favicon** and **OG image** (for social sharing).
- **Done criteria:** a store app generates with realistic product photos; a restaurant one with dish photos.

### 3.3 Materializer integration (P1)
- **Deliverables:** the materializer requests assets *after* the spec (or in parallel) and injects them into `frontend/` + references in the runtime.
- **Done criteria:** the `prompt → app with images` flow works end-to-end, with local fallback if no API key.

---

## Stage 4 — Asset animation (animated hero, micro-animations)

**Chosen strategy (confirmed):** **NOT use video APIs** (Veo/Kling/Runway — expensive per second). Instead, **ask nano banana (Gemini image) for high-quality static assets and animate them ourselves** so they *look* like animation. This reduces cost to almost zero (only free image tiers for testing) and keeps full control.

### 4.1 Self-animation from assets (P0) ⭐
- **Deliverables:**
  - **Ken Burns** (zoom + slow parallax) over hero/banners: the static image "breathes" with CSS/JS, no video API.
  - **Lottie** for animated icons and states (successful check-in, QR loading, points celebration).
  - **CSS micro-interactions**: hover lift, staggered entrances, animated toasts, count-up counters.
  - **Sprites / sequences**: ask nano banana for a set of 2-4 frames and rotate them to simulate movement (flicker, heartbeat, wave).
- **Done criteria:** 3-5 key moments of each app feel "alive" using only static assets + CSS/JS. Zero video API.

### 4.2 Real image→video (P3 — future, premium opt-in)
- **Context:** converting an image into a real short video (Google Veo, Kling, Runway) is a separate, **expensive** service. Only for "premium" apps once the product already monetizes.
- **Done criteria:** opt-in with clear cost in the ledger; **not by default**.

> **Budget rule:** test everything with **free image tiers** (Gemini offers a free tier). Pay only when a real asset goes to production in a concrete project.

---

## Stage 5 — Monetization (what's left to charge)

### 5.1 Payments in test phase: Yape + bank transfer (P0) ⭐
- **Why:** not depend on Stripe/Mercado Pago (which require registration/verification and, in Yape's case, BCP agreements). To **validate the payment flow**, a manual method with real data is enough.
- **Deliverables:**
  - **`YapeProvider`** → shows the **Yape QR** (static image the customer scans) + phone number + amount.
  - **`BankTransferProvider`** → shows bank transfer details (bank, account number, CCI, holder) + reference amount.
  - **Manual verification**: the admin confirms the payment in the panel (state `pending → paid`), because Yape/transfer don't emit automatic webhooks.
  - The amount and payment data are recorded in the cost/income ledger.
- **Done criteria:** a user can "pay" (scans QR / transfers), the admin sees it as `pending`, marks it `paid`, and the subscription activates.

### 5.2 Automated gateways (P2 — when you investigate)
- **Deliverables:** `StripeProvider` + `MercadoPagoProvider` (stubs already exist in the code) with checkout + automatic webhooks.
- **Done criteria:** complete test payment without manual admin intervention.
- **Note:** Yape *also* has an API for merchants (official BCP integration), but requires an onboarding process; we leave it for after the MVP.

### 5.3 Real identity (P1)
- **Deliverables:** `JSON.pe` (DNI) as the first real integrator (cheap and Peruvian); leave RENIEC/Open Gateway as stubs.
- **Done criteria:** a test DNI validates against JSON.pe and the QR check-in registers real identity.

### 5.4 Plans: Free demo + pay-to-use + credits (P0) ⭐

**Product decision (2026-09-20):** **Free is lowered**. No longer giving away 3 apps/month. Free is **demo**; **actually using it (Build)** requires payment. Whoever doesn't want $19/month buys **cheaper credits**, one at a time or in packs. Ads (5.6) drop to P3: with such a small Free there's no need to subsidize with advertising.

#### What each tier includes

| | **Free (demo)** | **Credits (pay-as-you-go)** | **Pro $19/month** | **Enterprise $99/month** |
|---|---|---|---|---|
| Spec (`project.md`) | Yes, to test the flow | Included when spending 1 credit on the cycle, or if you already have a spec | Included | Included |
| **Build** (real app, preview, export, Docker) | **No** | **1 credit = 1 build** | Included (quota 5.5) | Included (negotiated quota) |
| Paid images | No | Per pack / not by default | Plan quota | Negotiated quota |
| Ads | Irrelevant (almost no build session) | No | No | No |
| For whom | Curious, see how it feels | 1–4 loose apps (barbershop, one client) | Whoever generates every week | Agency / team |

#### Credits (the cheap route)

Working prices (USD; Yape in PEN at ~3.75 rate). Adjust when charging, not in code yet.

| Pack | Credits | Price | ≈ PEN | Per build | Vs Pro |
|---|---|---|---|---|---|
| 1 app | 1 | **$4** | S/ 15 | $4 | Cheaper than a month if you only want **one** |
| Small pack | 3 | **$10** | S/ 37 | $3.33 | Pro keeps winning from **6 builds/month** |
| Pack | 10 | **$29** | S/ 109 | $2.90 | Whoever makes 10 at once; if habitual, Pro ($19) wins |

**Rule to avoid cannibalizing Pro:** the credit costs **more per app** than the Pro quota. 5 builds at $4 = $20 ≥ $19. Whoever seriously uses the product subscribes; whoever tries once isn't scared off by $19.

**1 credit is spent on the successful Build**, not on writing the prompt. If the build fails before materializing, it's not charged. Credits **don't expire** (simple to explain).

Credit payment: the same as 5.1 (Yape / transfer) with reference `cred-user-pack`. Mock first, same as subscriptions.

#### Flow the user understands

```
Free: idea → spec (read, edit, decisions)
                │
                ▼
         Want the app?
                │
     ┌──────────┴──────────┐
  $4 credit (once)    $19 Pro / month
     └──────────┬──────────┘
                ▼
              Build
```

- **Deliverables:** plan + pack catalog; `402` on `/api/build` if Free without credits; credit balance in the panel; CTA "Buy 1 credit" or "Go Pro". ✅ **WIRED (2026-09-22)**
- **Done criteria:**
  - [x] Free can generate/view spec and **cannot** Build.
  - [x] 1 mock credit → 1 Build; the second Build without balance → 402 + go to Plans.
  - [x] Pro/Enterprise Build without spending credits.
  - [x] Plans copy explains the two routes (cheap single vs monthly).
  - [ ] Real gateway (Yape/transfer) instead of `MockPaymentProvider.buyCredits` — see 5.1.

### 5.5 Limit control (anti-loss) (P0) ⭐

**Why:** still the safety net. Now Free **doesn't build**; the hole would be infinite spec-LLM or Pro with no cap on an expensive model. **Must exist BEFORE public beta.**

- **Hard limits:**
  - `Free`: **0 builds**. Demo spec: **1–2 / month** (LLM cap). 0 paid images. Identity always mock.
  - `Credits`: builds = balance. No balance = 402.
  - `Pro`: 50 apps/month, 100 images/month, 50 verifications/month. DeepSeek by default.
  - `Enterprise`: negotiated cap (never literally "unlimited" without a contract).
- **Counters:** `builds_this_month`, `specs_this_month`, `credits_balance`, `images_this_month`.
- **Server-side validation** in `/api/build` (and spec generate if Free already used the demo quota) **before** LLM/materialize.
- **Monthly reset** of plan quotas (credits are **not** reset).
- **Dashboard:** Free sees "0 builds — buy a credit or Pro"; Pro sees `12/50`; credits sees balance.
- **Edge cases:** cancel Pro mid-month → Free demo + remaining credits. Cookie bypass → the server enforces. Failed build → don't charge the credit. Studio admin can Build to test (explicit exception, not the user).
- **Done criteria:**
  - [x] Free → Build → 402. (smoke test)
  - [x] Free → 3rd spec in the month → 403. (`authorizeSpec` logic; mirror of the already-tested build limit)
  - [x] Credit 0 → Build → 402. (smoke test)
  - [x] Pro within quota → Build 200; Pro out of quota → 403 (or spend credits if available). (smoke test)
  - [x] Tests of those four paths (`backend/smoke-monetization.mjs`, 13/13).
  - [ ] Automated tests in CI (part of Stage 1.1) + monthly reset with injectable clock.

> **Note:** ✅ **WIRED (2026-09-22)** together with 5.4. Missing real gateway (5.1) and CI.

### 5.6 Ads in Free (P3 — optional, no longer plan A)

With Free reduced to **demo without Build**, the session is short and ads **barely collect**. They remain as a fallback idea if someday Free becomes generous again. If resumed: a single slot in the Studio chrome, **never** inside the generated app, never in Pro. **Do not prioritize.**

---

## 💳 Appendix A — Payment gateway integration (detailed roadmap)

> This appendix documents **everything to do** to integrate real gateways (Stripe, Mercado Pago, Yape API). It serves to compare against the budget and decide when to implement each one. **It does not enter the initial $20** — it's a separate project.

### A.1 Prior decisions (what to define BEFORE coding)

| Decision | Options | Recommendation | Why |
|---|---|---|---|
| **Pricing model** | Per-use (credits) / Subscription / Hybrid | **Hybrid: Free demo + credits + Pro/Ent** | Free doesn't build; $4 a build or $19/month if you use it often |
| **First gateway** | Stripe / Mercado Pago / Yape API | **Yape API (BCP) or Mercado Pago** | Yape API if you have a BCP merchant; Mercado Pago is easier to start (no onboarding) |
| **Test mode first** | Yes / No | **Yes (mandatory)** | Every gateway has sandbox mode; test there before using real money |
| **Automatic recurrence** | Yes / Manual | **Yes (with easy cancellation)** | SaaS standard; without it the user has to "pay again" every month |
| **Webhook handling** | Sync / Async (queue) | **Async** | A webhook can be slow; if it fails it must retry → needs a queue (Stage 6) |

### A.2 Stripe (standard international gateway)

**Advantages:**
- Global leader, integration in 40+ countries (including Peru).
- Full test mode (test cards, local webhooks with CLI).
- Official SDKs for Node, Python, Go, etc.
- Supports recurring subscriptions with Stripe Billing.
- Embedded checkout (Stripe Elements) or redirect (Checkout Session).

**Disadvantages:**
- International commission: **3.6% + $0.30** per transaction (similar in Peru).
- Requires merchant registration (business info, bank account).
- Payout in USD → conversion to PEN at Stripe's exchange rate.

**Integration roadmap (if you choose Stripe):**

| Step | What to do | Est. time | Tokens/cost |
|---|---|---|---|
| 1. Stripe registration | Create account → activate test mode | 15 min | Manual |
| 2. Install SDK + Stripe CLI | `npm install stripe` + `stripe login` | 10 min | Manual |
| 3. Create `StripeProvider` | Implement `PaymentProvider` interface | 1-2h dev | ~$3-5 tokens |
| 4. Products + prices | Create in Stripe Dashboard: Free/$0, Pro/$X, Enterprise/$Y | 20 min | Manual |
| 5. Checkout Session | Endpoint `/api/checkout/stripe` → redirect to Stripe Checkout | 1h dev | ~$3 tokens |
| 6. Webhooks | Endpoint `/api/webhooks/stripe` → async queue + verify signature | 2-3h dev | ~$5-8 tokens |
| 7. Customer portal | Stripe Customer Portal (change plan, cancel) → button in UI | 1h dev | ~$2 tokens |
| 8. Sandbox testing | Test full cycle with test card `4242 4242 4242 4242` | 1-2h QA | Manual |
| 9. Activate live mode | Switch to live keys + configure production webhook | 30 min | Manual |
| **Stripe total** | | **~8-12h dev** | **~$13-18** |

**Recurring cost:** 3.6% + $0.30 commission per transaction (deducted from the charge).

---

### A.3 Mercado Pago (Latin American gateway)

**Advantages:**
- Popular in LATAM, multiple methods: card, transfer, cash (Oxxo, PagoEfectivo).
- Lower commission than Stripe in some countries (~2.9% + tax).
- Official Node SDK + redirect checkout or Payment Link.
- **Subscriptions** supported (Mercado Pago Subscriptions).

**Disadvantages:**
- Less polished documentation than Stripe.
- Payout in local currency (PEN in Peru) → simpler, but less global.
- Sandbox mode sometimes has bugs (community-reported).

**Integration roadmap (if you choose Mercado Pago):**

| Step | What to do | Est. time | Tokens/cost |
|---|---|---|---|
| 1. Mercado Pago registration | Create account → activate developer | 15 min | Manual |
| 2. Install SDK | `npm install mercadopago` | 5 min | Manual |
| 3. Create `MercadoPagoProvider` | Implement `PaymentProvider` interface | 1-2h dev | ~$3-5 tokens |
| 4. Create payment preference | Endpoint `/api/checkout/mercadopago` → preference + redirect | 1h dev | ~$3 tokens |
| 5. Webhooks (IPN) | Endpoint `/api/webhooks/mercadopago` → verify signature + queue | 2-3h dev | ~$5-8 tokens |
| 6. Subscriptions | Recurring plan with Mercado Pago Subscriptions | 2h dev | ~$4 tokens |
| 7. Sandbox testing | Test cards per country (e.g. `5031 7557 3453 0604` MasterCard test) | 1-2h QA | Manual |
| 8. Activate production mode | Switch to production Access Token + HTTPS webhook | 30 min | Manual |
| **Mercado Pago total** | | **~8-12h dev** | **~$15-20** |

**Recurring cost:** ~2.9% + taxes commission per transaction.

---

### A.4 Official Yape API (BCP — merchant integration)

**Advantages:**
- The most-used payment method in Peru (massive penetration).
- Lower commission than cards (~1.5-2% depending on BCP plan).
- Native experience: the user scans a QR with the Yape app.

**Disadvantages:**
- Requires **merchant onboarding with BCP** (manual process, business verification).
- **No public sandbox mode** (unlike Stripe/Mercado Pago); must be coordinated with BCP for a test environment.
- Less accessible documentation (not self-service like Stripe).

**Integration roadmap (if you choose Yape API):**

| Step | What to do | Est. time | Cost |
|---|---|---|---|
| 1. BCP onboarding | Contact BCP, fill forms, verify business | **Weeks** | Manual + paperwork |
| 2. Yape API access | BCP delivers sandbox credentials + documentation | 1-2 weeks | Manual |
| 3. Create `YapeApiProvider` | Implement `PaymentProvider` interface with official API | 2-3h dev | ~$5-8 tokens |
| 4. Dynamic QR | Generate QR per transaction (not fixed QR) via API | 1h dev | ~$3 tokens |
| 5. Yape webhooks | BCP notifies the payment → endpoint `/api/webhooks/yape` + queue | 2h dev | ~$5 tokens |
| 6. Testing with BCP | Coordinate sandbox tests with a BCP test account | 1-2h QA | Manual |
| 7. Activate production | Switch to live credentials + verified HTTPS webhook | 30 min | Manual |
| **Yape API total** | | **~6-9h dev** (excluding onboarding) | **~$13-16** |

**Recurring cost:** ~1.5-2% commission + BCP onboarding cost (merchant plan).

**Critical note:** BCP onboarding can take **weeks/months** depending on your business situation. That's why in Stage 5.1 I proposed **manual Yape** (fixed QR, no API) as a temporary solution while it's being processed.

---

### A.5 Effort comparison and decision

| Gateway | Dev effort | Token cost | Commission/txn | Business setup time | When to choose it |
|---|---|---|---|---|---|
| **Stripe** | ~8-12h | ~$13-18 | 3.6% + $0.30 | Days (online registration) | Global audience, want automatic recurring subscriptions, A+ docs |
| **Mercado Pago** | ~8-12h | ~$15-20 | ~2.9% + tax | Days (online registration) | LATAM audience, lower commission, multiple local payment methods |
| **Yape API (BCP)** | ~6-9h | ~$13-16 | ~1.5-2% | **Weeks/months** (BCP onboarding) | 100% Peruvian audience, lowest commission, preferred method by local users |
| **Manual Yape (5.1)** | ~2-3h | ~$5 | 0% (direct) | **0** (no onboarding) | **MVP/proof of concept**, validate payment before paying commissions |

**My recommendation by phases:**

1. **MVP phase (now, $20)**: manual Yape + bank transfer (Stage 5.1) → validate the flow, $0 commission.
2. **Beta phase (first month with real users)**: **Mercado Pago** → self-service, fast, good LATAM commissions, supports multiple methods.
3. **Scale phase (when you have >100 paying users)**: official Yape API (start BCP onboarding now, use in 2-3 months) + keep Mercado Pago.
4. **Global phase (if you expand outside LATAM)**: Stripe → best for international audience.

---

### A.6 Total gateway budget (for comparison)

| Concept | Amount |
|---|---|
| Manual Yape development (5.1) | ~$5 tokens |
| Full Mercado Pago development | ~$15-20 tokens |
| Full Stripe development | ~$13-18 tokens |
| Yape API development (after onboarding) | ~$13-16 tokens |
| Testing + adjustments | ~$5-10 tokens |
| **Total if you do all 3 gateways** | **~$50-70 tokens** (don't do it all at once) |
| **Monthly operational cost** | Commission per transaction (0% manual → ~3.6% Stripe) |

**Spending recommendation:** start with **manual Yape ($5)** → when you recharge, do **Mercado Pago ($20)** → then decide Yape API or Stripe based on your audience.

---

## Stage 6 — Scalability + async processing (critical) ⭐

**Why (this was NOT there and is super important):** today the Studio backend processes one request at a time, **synchronously**. If two users request "generate app" at the same time, the second waits. When it scales to tens/thousands of concurrent requests, a synchronous design **collapses** (timeouts, memory leaks, dying requests).

**Goal:** the system can handle **many requests at once**, without blocking, and long tasks (generate spec, materialize, generate images) run **in the background** asynchronously.

### 6.1 Job queue (P0)
- **Deliverables:**
  - **`BullMQ` + Redis** (or `pg-boss` over Postgres if we want to avoid Redis) to queue long tasks: `generate-spec`, `materialize`, `generate-image`.
  - The HTTP endpoint receives the request and responds **immediately** with a `jobId` (202 Accepted), instead of blocking until done.
  - The frontend **polls** (or uses WebSocket/SSE) the `jobId` to show the live progress timeline.
  - **Retries with exponential backoff** for LLM/image calls that fail.
  - **Configurable concurrency** (e.g. 5 workers) to process N requests in parallel.
- **Done criteria:** launch 20 "generate app" at once → all queue up, process in parallel, and no request blocks another.

### 6.2 Workers separated from the HTTP server (P0)
- **Deliverables:** the API server (responds fast) and the **workers** (do the heavy work) run as separate processes. They scale independently.
- **Done criteria:** I can spin up 1 API server + 5 workers without touching code (just replicas).

### 6.3 Persistent state and results (P0)
- **Deliverables:** each job saves its state (`queued → running → done/failed`) and its result in the DB, so a job **survives a server restart**.
- **Done criteria:** kill the server mid-job → the job resumes or retries on return, it isn't lost.

### 6.4 SQLite → Postgres (P1)
- **Deliverables:** the Studio uses SQLite (fine for 1 user); for real concurrency migrate to **Postgres** (with pooling) and handle transactions. Generated apps already have the `db.js` layer ready to switch.
- **Done criteria:** write concurrency without SQLite lock nor "database is locked".

### 6.5 Limits and backpressure (P1)
- **Deliverables:** rate limiting per user (don't saturate the system), concurrency limits per plan, and **backpressure** (if the queue is full, enqueue with priority, don't blow up).
- **Done criteria:** one user can't bring the system down with 100 requests in a loop.

> **Cost note:** managed Redis (Upstash/Redis Cloud) has a free tier; BullMQ is open-source. At launch you can use `pg-boss` over Postgres to avoid paying for a separate Redis.

---

## Stage 7 — Production (to be a real product)

- **Hosting + custom domains** (P2): deploy generated apps to a client subdomain/domain.
- **Observability** (P2): structured logs, RED metrics, alerts (already in the framework, missing in the Studio).
- **Hardening** (P2): rate limiting, HTTPS, SQLite backups, secret rotation.
- **Done criteria:** a generated app can live in production with its own domain and monitoring.

---

## Stage 8 — Ecosystem (future)

- **Template/agent marketplace** (P3): sell vertical blueprints.
- **Enterprise self-host** (P3): SSO, audit, multi-user.
- **Usage analytics** (P3): funnel (prompt→build→payment), retention, cost per user.

---

## Stage 9 — Quality via adversarial review + slices + quality spec (P0) ✅

**Why:** two quality holes that a single "review at the end" doesn't cover: (1) a **thin spec** reaches the materializer and produces a generic app; (2) a **superficial** implementation is called "done" without anyone questioning its architecture. This stage adds **quality friction** at both points.

### 9.1 Post-implementation review: architect + reviewer (adversarial)

**The idea (adapted from an external suggestion):** after implementation there's a step where **two agents argue about the architecture**.

- **Architect** (`chief_engineer`) enters **hypothesis mode** and, **ignoring the code**, asks: *"is this the best way to solve this? why would someone do this? what was the intent of whoever did this work?"*.
- **Reviewer** (`architecture_reviewer`) **goes to the code** and tests the architect's hypotheses (reads code, traces intent vs. implementation, runs/inspects tests), marking each one CONFIRMED / REFUTED / UNVERIFIED with evidence (`file:line`).
- At the end they decide whether to **refactor** (break and redo) or whether the implementation is **solid enough to only harden it (hardening)**.
- The implementation is treated as a **"cutre borrador" (crude draft)**: it can be broken and rebuilt, but **justifying among themselves why and with what it's replaced** (concrete shape, not a wish).

### 9.2 Slices as checkpoints

**The idea:** divide everything into **slices**; a slice is just a **checkpoint** to review before moving to the next.

```
Implement slice → reviewer → fix → reviewer → up to 2 fix attempts
   → if after 2 attempts it's still wrong, note what remained unresolved
→ next slice → review → fix → (everything unresolved after round 2 is noted as pending)
```

- **Wildcard slice at the end:** after finishing the last slice, launch a slice that reviews **all** slices against **all** pending findings + whatever new appears.
- This review slice has **up to 10 attempts** review → fix.
- **Escalation:** if the fixer repeatedly fails the same problem, the reviewer proposes **implementing a refactor as part of the fix** (instead of a third cosmetic patch).
- What remains unresolved after 10 attempts is noted as **explicit tech debt** (owner + severity + why), not silent risk.

### 9.3 Project-spec quality sub-agent

**The idea:** a sub-agent that reviews the quality of the specs generated by the Studio's generator agent, measuring them against a **very rich** spec (benchmark: `PROJECT_SPEC.md`).

- **`spec_quality_reviewer`** scores each generated spec with a **12-dimension weighted rubric** (vision, users, flow, domain, data model, auth/RBAC, API, security, infra, frontend/UX, scope discipline, success criteria) + **red-lines** that block the build (no data model, no architecture, no auth for money-handling apps, wrong stack).
- Verdict: **EXCELLENT / GOOD / THIN / INSUFFICIENT**; a THIN/INSUFFICIENT is enriched (feedback or regeneration) **before** the build.
- Benchmark distilled in [spec_quality_rubric.md](.claude/templates/spec_quality_rubric.md).

### Deliverables ✅ (2026-09-22)
- [x] `architecture_reviewer` agent (adversarial reviewer, evidence mode).
- [x] `chief_engineer` with documented "hypothesis mode".
- [x] `spec_quality_reviewer` agent + `spec_quality_rubric.md` rubric (12 dimensions + red-lines).
- [x] `slice_review_workflow.md` workflow (slices + wildcard slice + escalation to refactor).
- [x] Integrated in `sprint_workflow.md` (Stage 2.5), `CLAUDE.md` (ch. 26 + appendix) and this roadmap.

### Pending (when due)
- [ ] Wire `spec_quality_reviewer` as a real gate in CASF Studio (`/api/spec/quality`) — automatic spec scoring before build.
- [ ] Automate slice review as a step of the generation pipeline.

---

## 🎯 Recommended order with ~$20 (tomorrow)

| Step | What | API cost | Visual impact |
|---|---|---|---|
| 1 | **Stage 5.4–5.5 — Free demo + credits + 402 on Build** | No | Low (protection + payment) ⭐ |
| 2 | Stage 1.1 — materializer tests (automate the manual) | No | Low (safety) |
| 3 | **Stage 2.1-2.4 — design system + icons + animations + premium components** | No | **Very high** ⭐ |
| 4 | Stage 3.1 — image layer with `mock` + local fallback | No | Medium |
| 5 | Stage 3.2 (logo + hero) with Gemini image (**free tiers**) | No (free tier) | **High** ⭐ |
| 6 | **Stage 4.1 — self-animation (Ken Burns + Lottie) from the assets** | No | **High** ⭐ |
| 7 | **Stage 5.1 — Yape + bank transfer in test** | No | Functional |

**What does NOT fit in $20** (leave for later): full React frontend (1.2-A), real image→video (4.2), automated Stripe/Mercado Pago gateways (5.2), real JSON.pe identity (5.3, cheap optional), **async scalability (Stage 6)**, hosting (7).

> **Important note:** **Paid Build** (credit or Pro) is non-negotiable before public beta. Documented in 5.4–5.5. ✅ **The code is already wired (2026-09-22)** — only the real gateway (5.1) and CI tests remain.

---

## 💰 Real production launch budget (recalculated)

> Distinguish **three** money pools, not two:
> 1. **Development** — agent tokens (Cursor/DeepSeek) to build the product. Not recurring.
> 2. **Fixed operation** — monthly infra (VPS, domain, DB). Recurring even if nobody uses the product.
> 3. **Variable cost (COGS)** — LLM + images **per generation**. Grows with Free and paying users. It's what can sink you if there are no limits (Stage 5.5).
>
> Working exchange rate: **1 USD ≈ S/ 3.75** (approx. Sep 2026). Adjust if the rate moves. Plan prices already in code: **Free $0 / Pro $19 / Enterprise $99**.

### A. Development cost (real breakdown, not the previous summary)

The previous total (~$108-162) **was incomplete**: it grouped 1-4, didn't separate 5.1–5.4, and didn't include buffer or Stage 7. Here is the recalculation.

| Block | What it includes | Low | High | Needed to charge? |
|---|---|---|---|---|
| **5.4 + 5.5 Free demo, credits, 402 on Build** | Plans + packs + counters + spec cap in Free | $10 | $18 | **Yes — before public beta** |
| 1.1 Materializer tests | Per-domain suite + generated backend + spec round-trip | $8 | $15 | Yes (avoid expensive regressions) |
| 1.2 Modular generated frontend (vanilla, not React) | Split the monolithic `app.js` | $15 | $25 | Not for the payment MVP |
| 2.1–2.4 Design system + icons + animations + anti-AI | What sells most visually | $25 | $40 | Almost yes (otherwise it looks like a prototype) |
| 3.1–3.2 Image layer + logo/hero | `ImageProvider` mock + Gemini free tier | $12 | $20 | Not to charge; yes to "catch the eye" |
| 4.1 Self-animation | Ken Burns + Lottie + CSS | $10 | $18 | No |
| 5.1 Yape + transfer | QR, bank details, `pending → paid` (plans and credits) | $5 | $8 | **Yes — first payment** |
| 5.2 Mercado Pago (when due) | Checkout + webhooks | $15 | $20 | No (after validating payment) |
| 5.3 Real JSON.pe identity | First Peruvian integrator | $8 | $15 | No |
| 6 Queues + workers + Postgres | Real scalability | $40 | $60 | Not until ~50-100 concurrent users |
| 7 Production (hardening, domain, backups) | HTTPS, secrets, minimal observability | $15 | $30 | Yes for a serious public domain |
| **20% buffer** (bugs, rework, polish) | Always appears | $28 | $46 | Yes, budget it |

**Totals (development, non-recurring):**

| Package | What you buy | USD | ≈ PEN |
|---|---|---|---|
| **Minimum to not lose money in public** | 5.5 + 5.1 + 5.4 + small buffer | **$25–45** | S/ 95–170 |
| **Marketable MVP (recommended)** | Minimum + 1.1 + 2 + 3.1-3.2 + 4.1 + basic 7 | **$120–190** | S/ 450–715 |
| **Complete product (stages 1–7, no React rewrite nor Stripe)** | MVP + 1.2 vanilla + 5.2 MP + 5.3 + 6 + 7 | **$210–330** | S/ 790–1 240 |
| **With React frontend for generated apps (1.2-A)** | The above + rewrite | **$250–410** | S/ 940–1 540 |

> With **~$20 of recharge** you don't close the marketable MVP. You close a chunk (limits **or** visual **or** Yape). Development is paid in **several recharges** over weeks, not in a single shot.
>
> What's **not** in these numbers: your time, IGV/company if you invoice formally, BCP onboarding, nor paid ads.

### B. Monthly operation cost (fixed infrastructure)

**Option 1 — Minimum start (1-50 users): ~$15-25/month (S/ 55–95)**

| Resource | Provider | Cost/month |
|---|---|---|
| VPS (API + workers) | Hetzner CPX11 / DigitalOcean $6 | $5-7 |
| Database | SQLite on disk or Postgres Neon free | $0-5 |
| Job queue | Redis Upstash free or pg-boss | $0 |
| Assets | Cloudflare R2 (10GB free) | $0 |
| CDN + HTTPS | Cloudflare free | $0 |
| Domain | Namecheap/Cloudflare | ~$1-2 |
| Email | Resend free (3000/month) | $0 |
| Errors | Sentry free | $0 |
| **Total** | | **~$15-25** |

**Option 2 — Scalable (100-1000 users): ~$60-120/month (S/ 225–450)**

| Resource | Provider | Cost/month |
|---|---|---|
| API | Render / Railway / Fly.io | $25-40 |
| Postgres | Neon / paid Supabase | $10-25 |
| Queue + workers | Upstash Redis | $10-30 |
| Storage | R2 / S3 | $5-15 |
| Email + SMS | Resend + Twilio | $10-20 |
| Monitoring | Sentry + logs | $10-30 |
| **Total** | | **~$60-120** |

**Option 3 — 1000+ users: $200-500+/month.** Only when there's already MRR to pay for it.

### C. Variable cost per generation (COGS) — here you win or lose

Architecture **today**: the materializer is local code (almost $0). The LLM pays mainly for the **spec**. DeepSeek chat price in ledger: **$0.27 / $1.10 per million** tokens.

| Generation type | Typical cost | If it gets out of hand |
|---|---|---|
| Spec with DeepSeek (current flow) | **$0.005–0.02** | $0.05 if the prompt is huge |
| Spec + 2–5 paid Gemini images | **$0.04–0.15** | $0.30 if no cache |
| Spec + LLM-generated code (future, not the current materializer) | **$0.08–0.40** | **$1–3** if you use Claude/GPT-4o on every build |

**Monthly COGS per user if they use the full quota (Stage 5.5), with DeepSeek + paid images:**

| Plan | Quota | Worst-case COGS | Price | Holds up? |
|---|---|---|---|---|
| Free | **0 builds**, 1–2 demo specs | **~$0.01–0.04** (spec only) | $0 | Yes: almost no COGS. |
| Credits | 1 build / credit | **~$0.02–0.15** | $4 (or pack) | Yes, high margin. |
| Pro | 50 apps + 100 images | **~$4–12** (DeepSeek) / **$40–80** (if all Claude) | $19 | DeepSeek: yes. Claude on everything: **no — you lose**. |
| Enterprise | "unlimited" | Can be **anything** | $99 | Only with negotiated cap or dedicated model. |

**Realistic usage (nobody fills the quota every month):**

| Plan | Typical usage | Typical COGS |
|---|---|---|
| Free | 1 spec, **0 builds** | **~$0.01–0.04** |
| Credits | 1–3 loose builds | **$0.02–0.15** per build |
| Pro | 8–15 apps, 10–20 images | **$0.80–3.00** |
| Enterprise | 30–80 apps, mix of models | **$8–25** (must measure) |

**Golden margin rule:** Pro at $19 must run **DeepSeek (or cheaper) by default**. Premium models = extra quota or Enterprise only. Without that rule, the Pro plan in the current code **is not sustainable**.

### D. What triggers cost (to watch)

1. **LLM per generation** — mitigation: DeepSeek default, cache of similar specs, Stage 5.5.
2. **Images** — mitigation: mock/free tier first, cache, quota per plan.
3. **Free spec without cap** — someone can spam generate. Mitigation: 1–2 specs/month in Free + rate limit.
4. **Concurrency** — more users = more CPU. Mitigation: queue (Stage 6) + don't move to infra option 2 until you have MRR.
5. **Churn + refunds** — a Pro that generates 40 apps and cancels on day 28 leaves you the COGS and takes away next month's income.

### E. Consolidated recalculation (numbers to decide)

| Concept | USD | ≈ PEN |
|---|---|---|
| Development up to marketable MVP | $120–190 | S/ 450–715 |
| Development up to product 1–7 | $210–330 | S/ 790–1 240 |
| Start infra / month | $15–25 | S/ 55–95 |
| Scalable infra / month | $60–120 | S/ 225–450 |
| Typical Pro COGS / month | $0.80–3 | S/ 3–11 |
| Development recharges while building / month | $20–40 | S/ 75–150 |

> **Conclusion:** launching "dignified" costs **~$120–190 of development** (several recharges) + **$15–25/month of infra**. The risk is no longer "Free gives away 3 apps": it's **uncapped spec-LLM** and **Pro with Claude**. Build is paid (credit or subscription).

---

## 📈 Realistic income predictions and self-sustainability threshold

> This is **not** a pitch. It's a sheet to avoid self-deception. Market hypothesis: niche LATAM SaaS, solo founder, initial payment via Yape/transfer, **zero ad budget** at the start. Competitors (Lovable, v0) charge ~$20–25/month: **$19 Pro is credible**, not suspiciously cheap.
>
> Free→paid conversion in tools of this type, **organic and without brand**: 1–5% is normal. 8% is already **good**. 15% would be exceptional and we don't use it as a base.

### F. Economic unit (one Pro user)

```
Pro income:               $19.00
MVP gateway commission:   $0.00  (Yape/transfer)
MP/Stripe commission later: ~$0.55–0.70  (if you automate)
Typical COGS:             $0.80–3.00
Prorated infra*:          $0.50–2.00
────────────────────────────────
Contribution margin:      ~$14–17  (Yape + DeepSeek + limits)
```

\*Infra $20 / N paying users. With 10 Pro ≈ $2/user; with 40 Pro ≈ $0.50/user.

**One Pro "pays" ~1.2–2 months of start infra.** The business falls if: (a) Free is expensive, (b) Pro uses Claude recklessly, (c) there's no conversion.

**Credit unit (1 build at $4):** COGS ~$0.02–0.15 → margin **~$3.80**. It's the entry route. It doesn't replace Pro: at 5 apps/month the $19 already pays off.

**Free unit:** almost $0 income and almost $0 COGS (without Build). No need for ads to sustain it.

**Pro unit doesn't change:** $19 and **zero ads**. Mixing ads into paid destroys the upgrade argument.

### G. Income needed to be self-sustained

Define "self-sustained" in **four rungs** (otherwise "scalable" means anything).

| Level | What it really covers | Minimum MRR | Equivalent (90% Pro / 10% Ent mix) | ≈ PEN/month |
|---|---|---|---|---|
| **0. Survival** | Only $20 infra + Free/Pro LLM | **$50–80** | 3–5 Pro | S/ 190–300 |
| **1. Technically self-sustained** | Infra + COGS + $30 maintenance recharges + 20% buffer | **$150–220** | 8–12 Pro | S/ 560–825 |
| **2. Personally self-sustained** | Level 1 + minimum founder income **$400–500** (part-time, Peru) | **$650–850** | ~28–40 Pro **or** 6 Ent + 10 Pro | S/ 2 400–3 200 |
| **3. Scalable** | Infra option 2 ($90) + COGS $120–200 + founder $800 + $100 ads | **$1 400–1 800** | ~70–90 Pro **or** 10 Ent + 40 Pro | S/ 5 250–6 750 |
| **4. Hire** | Level 3 + 1 part-time person ~$600 | **$2 200–2 800** | real Enterprise mix | S/ 8 250–10 500 |

**Technical break-even (level 1), round numbers:**

- Fixed: $25 infra + $30 recharge + demo spec COGS ≈ **$55–60**
- Margin per Pro ≈ **$15**; margin per credit ≈ **$3.80**
- **Break-even ≈ 4–7 Pro** **or** a mix (e.g. 2 Pro + ~8 credits sold).
- Margin per Pro ≈ **$15**
- **Break-even ≈ 5–8 real Pro users** (paying every month, not trial).
- With **2 Enterprise** ($198) you're already near level 1 **even with few Pro**.

Until reaching **level 1**, the product is a **subsidized hobby**. Until **level 2**, it's not a salary. "Scaling infra" (option 2/3) **before level 2** is the classic way to go broke.

### H. Four 12-month scenarios (from public beta)

Common assumptions (explicit, so you can later contradict with data):

- Frozen price: Free $0 / Pro $19 / Enterprise $99.
- Among payers: **90% Pro, 10% Enterprise** (in bad/critical: 100% Pro).
- CAC ≈ $0 (organic, acquaintances, communities). If you pay ads, subtract that money from MRR.
- Churn = % of payers who leave **each month**.
- Free **always** with 5.5 quota. If you remove the quota, the "critical" scenario arrives early.

#### 🟢 Good case (still realistic, not unicorn)

Signal: there's a clear niche (e.g. Peruvian SMEs / agencies), the visual no longer looks like AI, you charge via Yape without friction, 1–2 use cases spread word-of-mouth.

| Month | Active users | Conversion | Payments (Pro+Ent) | Churn | MRR | COGS+infra (est.) | Result |
|---|---|---|---|---|---|---|---|
| 1 | 30 | 0% (beta) | 0 | — | $0 | $25 | Small loss |
| 3 | 90 | 5% | 4 Pro | 5% | $76 | $35 | Almost infra break-even |
| 6 | 180 | 7% | 11 Pro + 1 Ent | 4% | $308 | $55 | **Level 1** |
| 12 | 350 | 8% | 22 Pro + 3 Ent | 4% | **$715** | $90 | **Level 2 just** |

- Year-1 closing MRR: **~$700**. Annualized income ~$8k if sustained (not "a company", it's **part-time salary + live product**).
- What makes it good: retention (churn ≤5%), 3 real Enterprise (agencies), cheap-to-run Free.

#### 🟡 Regular case (most likely if you launch without ads and with a "correct" product)

Signal: people try, 2–4 pay, the rest stay in Free or don't return. No explosion nor disaster.

| Month | Active users | Conversion | Payments | Churn | MRR | COGS+infra | Result |
|---|---|---|---|---|---|---|---|
| 1 | 15 | 0% | 0 | — | $0 | $22 | Hobby |
| 3 | 50 | 2% | 1 Pro | 8% | $19 | $30 | Slight loss |
| 6 | 110 | 3% | 3 Pro | 7% | $57 | $40 | **Doesn't cover recharges** |
| 12 | 200 | 3.5% | 6 Pro + 0 Ent | 7% | **$114** | $50 | **Between level 0 and 1** |

- Year-1 closing: **~$100–120 MRR**. The VPS pays for itself; **you don't**. Sustainable only as a side-project.
- Silent risk: 200 Free × $0.10 COGS = $20 extra. Without 5.5, this case turns bad.

#### 🟠 Bad case (usable product, cold market or frictional payment)

Signal: there are signups, almost no payments. Or they pay 1 month and leave (high churn). Manual Yape jams ("did I already pay?").

| Month | Active users | Conversion | Payments | Churn | MRR | COGS+infra | Result |
|---|---|---|---|---|---|---|---|
| 1 | 10 | 0% | 0 | — | $0 | $20 | — |
| 3 | 35 | 1% | 0–1 Pro | 12% | $0–19 | $35 | Free eats more than Pro |
| 6 | 70 | 1% | 1 Pro | 12% | $19 | $45 | **Loss $25/month** |
| 12 | 90 | 1% | 1–2 Pro | 15% | **$19–38** | $50 | **Unviable as a business** |

- Year-1 closing: **less than $40 MRR**. Continuing to invest $20–40/month in recharges is **giving away time and money**.
- Typical cause: looks like a demo, no vertical that hurts, or Free already "suffices".

#### 🔴 Critical case (abuse, or nobody wants to pay, or the API spikes)

Signal: the LLM bill rises and the ledger has no income. Bots at signup. A Free user (without 5.5) generates in a loop. Or 0 payments by month 4.

| Month | What happens | MRR | Real cost | Result |
|---|---|---|---|---|
| 1–2 | You launch public without hard limits | $0 | Infra $20 + LLM **$40–120** | Hemorrhage |
| 3 | 1 payment that requests refund / chargeback | $0–19 | COGS continues | Demoralizing |
| 4 | Cuts: either turn off Free, or turn off the product | $0 | You still pay domain/VPS | **Stop** |

- Plausible loss in 90 days: **$150–400** (APIs) + development recharges. It's not "startup risk"; it's **a token electricity bill**.
- This case is **80% avoidable** with Stage 5.5 + DeepSeek default + signup with minimal friction (email verify).

### I. Honest reading of the four cases

| Case | Probability (judgment, not science) | Self-sustained at 12 months? | What to do |
|---|---|---|---|
| Good | 15–25% if vertical + visual + easy payment | Level 2 **just** | Don't move to infra option 2 yet |
| Regular | **40–50%** (base) | Level 0–1 | Side project; don't quit the job |
| Bad | 20–30% | No | Activate orange contingency |
| Critical | 10–15% without 5.5; **less than 5%** with 5.5 done right | No, and burns cash | Red contingency **that week** |

**To be "scalable and self-sustained" (level 2–3), in numbers, you need:**

- **Absolute minimum:** ~**8–12 Pro** retained (level 1).
- **Minimum to pay you part-time:** ~**$650–850 MRR** ≈ **30 Pro** or **5–8 agency Enterprise**.
- **Minimum to really scale infra:** don't spend $90/month on Railway **until** you have ~**$1 400 MRR** (level 3).

If by **month 6** there aren't **≥3 real payments** (confirmed Yape), the case is no longer "good": it's regular or bad. Decide with the ledger, not with hope.

---

## 🛟 Appendix B — Short contingency plans

> Saved here on purpose: when the month turns ugly, you don't have to invent the plan at 2 a.m. Execute the one from the row that applies.

### B.1 Traffic light (review every 30 days with the ledger)

| Light | Objective trigger | Plan |
|---|---|---|
| 🟢 Good | MRR ≥ $250 **and** churn under 6% **and** COGS under 20% of income | Continue visual/product roadmap. **Don't** scale infra. Reinvest 30% of margin in Stage 2/3, not expensive ads. |
| 🟡 Regular | MRR $80–250 or 2–4% conversion | Freeze Stage 8 and 1.2-A (React). Lower Free to **1 app/month**. One single marketing vertical (e.g. "barbershops/Peruvian SMEs"). Yape-only payment. |
| 🟠 Bad | MRR under $50 at month 4 **or** churn over 12% **or** Free COGS over income | Activate **B.3**. Stop recharging Cursor "just in case". |
| 🔴 Critical | LLM/images over $40 in a month with MRR ≈ 0 **or** one user with over 50 generations | Activate **B.4 the same day**. Don't wait until month-end. |

### B.2 If the case is good

1. Don't hire nor move to infra option 2.
2. Raise Pro to **$24** only if there's a waitlist or quota saturates; otherwise leave $19.
3. Find **2–3 agencies** for Enterprise ($99) by hand (WhatsApp), not with a generic landing.
4. Save 2 months of infra in cash ($50) before any ad experiment.

### B.3 If the case is regular or bad (live product, no money)

1. **Free becomes demo:** 1 app, no paid images, mock model or DeepSeek with $0.05/user cap.
2. **Don't compensate with ads.** Free no longer builds. If there are no payments: more visible credits (S/15) or "Build = pay".
3. **Generate = pay:** the full build requires Pro (even if just 1 month). The spec preview can stay free.
4. **Bridge income:** 1–2 implementation/consulting jobs using CASF (S/ 800–2 000 per app delivered to a real business). That **doesn't** scale, but covers recharges.
5. Pause images, real identity, and Stage 6.
6. Honest public message: "paid beta, limited slots". Real scarcity, not marketing.

### B.4 If the case is critical (it's bleeding)

Execute **in this order**, the same day:

1. **Kill switch:** `IMAGE_PROVIDER=mock`, mock LLM or DeepSeek with daily budget (hard cap in code, not "by eye").
2. Close public signup (invite-only / waitlist).
3. Drop workers to 0; keep the cheapest VPS or just local.
4. Audit the ledger: who generated, how much it cost. Ban abuse.
5. Refund whoever paid and can't use the product (reputation is worth more than $19).
6. **Don't** rewrite the materializer "to save it" that week. The problem is **cash and limits**, not features.
7. Reopen only when 5.5 is in production and the daily API cap is tested.

### B.5 Extra contingencies (short, just in case)

| Threat | Short plan |
|---|---|
| DeepSeek raises prices or goes down | Change default to an equally cheap model; Pro doesn't include Opus. `cost.ts` is already agnostic. |
| Yape doesn't scale / "I already paid" disputes | Move to Mercado Pago (5.2) **only** if there are ≥10 payments/month that hurt. Until then, require voucher + unique reference. |
| A competitor ships the same, prettier | Don't fight on generic UI. Push the moat: spec + memory + costs + Peru vertical (PEN, Yape, DNI). |
| You run out of recharges mid-stage | Deliver 5.5 + 5.1. Everything visual waits. An ugly product that doesn't lose money beats a pretty one that does. |
| IGV / formalization | While you charge informally via Yape and it's little, document income. On crossing ~level 2, quote receipts by fee or a company; MRR must absorb 8–18% extra. Don't formalize in the bad case "just in case". |
| You want to "scale" because there are 20 Free users | Free users are **not** business traction. Scaling = **retained paying** users. |
| Ads become invasive | Don't apply. Plan A is Free demo + credits, not advertising. |

### B.6 Minimum personal safety cash

Before public beta, have **apart from the development budget**:

| Reserve | For what | Amount |
|---|---|---|
| 3 months of option-1 infra | The product doesn't shut down if a month doesn't charge | **$45–75** |
| Prepaid API cap | DeepSeek/Gemini don't go to crazy credit | Cap **$10–20** |
| Don't mix | Cursor recharges ≠ living money | Separate accounts or pockets |

If that reserve doesn't exist, **there is no public beta**. There's local demo and 1-on-1 payment via WhatsApp to acquaintances ("bridge consulting" case).

---

## 🚦 Global "done" definition (when the product stops looking like AI)

- [ ] A generated app is **indistinguishable from a premium template** at a glance.
- [ ] Zero emojis, zero flat tables, zero default typography.
- [ ] Subtle animations with purpose (not empty decoration).
- [ ] Generated logos + product images (with cost-free local fallback).
- [ ] Everything accessible (keyboard + contrast + `prefers-reduced-motion`).
- [ ] Every generated asset is **accounted in the cost ledger**.
- [ ] The system **processes requests in parallel** (queue + workers), not one at a time.
- [ ] **Per-plan limits are implemented and validated** — no user can consume more resources than allowed, protecting the business margin.
- [ ] The ledger lets you see if we're at 🟢/🟡/🟠/🔴 (Appendix B) without guessing.

---

<!-- CASF · ETAPAS_SIGUIENTES.md -->
