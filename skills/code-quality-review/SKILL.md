---
name: code-quality-review
description: Use when reviewing code for quality dimensions — simplicity, readability, extensibility, testability, cohesion/coupling. Provides reviewer-oriented checklists, anti-pattern catalogs, and severity rubrics. Distinct from software-development (which is for authoring).
---

# Code Quality Review

## Overview

Evaluate proposed code changes through five quality lenses: **simplicity, readability, extensibility, testability, cohesion/coupling**. This skill is for reviewers — it tells you what to look for, how to phrase the finding, and when to stay quiet.

**How to invoke:**
```
Skill({ skill: "code-quality-review" })
```

**When to invoke:** Reviewing a PR, diff, or proposed code change for quality (not correctness, not security). Use alongside `unit-testing` when test quality is also in scope.

---

## Core Principle

**Every quality finding must name a specific cost.** "Could be cleaner" is not a finding — it's a vibe.

A real quality finding answers: *what does this cost the next person?*

| ❌ Vibe | ✅ Cost-named |
|---------|---------------|
| "This is hard to read" | "Three nested ternaries hide the empty-cart branch — readers have to mentally simulate to find it" |
| "Could be simpler" | "The factory wraps a single `new User(...)` call with no variation — delete it and inline" |
| "Not extensible" | "Adding a new payment method requires editing 4 switch statements; no seam for new types" |
| "Hard to test" | "`processOrder` reads `Date.now()` directly — tests can't assert behavior at specific times without monkey-patching" |

If you can't name the cost, don't post the finding.

---

## Lens 1: Simplicity

> "The best code is no code. The second best is simple code."

### What to look for

- **Premature abstraction**: factory/builder/strategy/visitor patterns introduced before there are 2+ concrete uses
- **Speculative generality**: parameters, hooks, or extension points added "in case we need them"
- **Over-engineering**: 50 lines doing what 5 lines could do
- **Accidental complexity**: complexity added by the implementation choice, not the problem
- **Indirection without payoff**: wrapper functions that just call the wrapped thing
- **Configuration that could be a constant**: env vars, settings objects, options bags with one realistic value

### ❌ BAD: Premature abstraction

```typescript
// Single caller, single behavior — abstraction has no leverage
interface UserGreeter {
  greet(user: User): string;
}

class DefaultUserGreeter implements UserGreeter {
  greet(user: User): string {
    return `Hello, ${user.name}`;
  }
}

class GreetingService {
  constructor(private greeter: UserGreeter = new DefaultUserGreeter()) {}
  hello(user: User): string {
    return this.greeter.greet(user);
  }
}
```

### ✅ GOOD: Just the function

```typescript
function greet(user: User): string {
  return `Hello, ${user.name}`;
}
```

### Flag as HIGH if

- An abstraction has exactly one implementation and no roadmap-driven reason for a second
- A function does in 30 lines what a stdlib/framework call does in 1
- A class hierarchy was introduced for a single concrete type
- An options/config parameter has only one value used anywhere in the codebase
- Code is structured for a hypothetical future requirement that isn't on the roadmap

### Don't flag

- Abstractions with 2+ real, distinct uses (even if you'd factor them differently)
- Patterns that are codebase convention — flag the convention separately, not the file
- Boilerplate required by the framework (Django views, React component shapes, etc.)

---

## Lens 2: Readability

### What to look for

- **Naming**: variables/functions/types named for *what they are* in domain terms, not their type or implementation
- **Function length**: long functions are smells, but length alone isn't the bug — the bug is usually mixed abstraction levels or missing names for sub-steps
- **Nesting depth**: 3+ levels of nesting forces the reader to hold too much context
- **Mixed abstraction levels**: a function that calls `chargeCard()`, `setOrderStatus()`, and *also* does `for (const c of order.note) { ... }` byte-level work
- **Comment signal/noise**: comments that explain *what* (noise — code already says that) vs *why* (signal — non-obvious constraint)
- **Magic literals**: bare numbers/strings without a name (`if (status === 3)`)
- **Cognitive load**: how many things must I track in my head to understand this line?

### ❌ BAD: Mixed abstraction + bad names

```typescript
async function p(o: Order) {
  let t = 0;
  for (const i of o.items) {
    t += i.q * i.p;  // q? p?
    if (i.t === 1) t += t * 0.1;  // 1? what's t === 1?
  }
  const r = await fetch(`/api/charge?a=${t}&u=${o.u}`);
  if (r.status === 200) {
    o.s = 'ok';
    db.save(o);
    mailer.send(o.u, `Order ${o.id} confirmed`);
  }
}
```

### ✅ GOOD: Named, single-level

```typescript
const TAXABLE = 1;
const TAX_RATE = 0.1;

async function processOrder(order: Order) {
  const total = computeTotal(order.items);
  await chargeAndConfirm(order, total);
}

function computeTotal(items: Item[]): number {
  return items.reduce((sum, item) => {
    const lineTotal = item.quantity * item.price;
    const tax = item.kind === TAXABLE ? lineTotal * TAX_RATE : 0;
    return sum + lineTotal + tax;
  }, 0);
}

async function chargeAndConfirm(order: Order, total: number) {
  const charged = await charge(order.userId, total);
  if (!charged) return;
  order.status = 'ok';
  await db.save(order);
  await mailer.sendConfirmation(order);
}
```

### Flag as HIGH if

- A reader needs to scroll up/down repeatedly to understand a single function
- Names lie or mislead (`getUser` that creates a user, `isValid` with side effects)
- Magic numbers/strings appear in conditional logic without a named constant
- A function spans multiple abstraction levels (high-level orchestration + low-level loops in the same body)
- Nesting exceeds 3 levels because of accidental structure (not inherent algorithm complexity)
- Comments contradict the code (stale comments are worse than none)

### Don't flag

- Short names in narrow scopes (`i`, `x`, `acc` in a 3-line reduce are fine)
- Single-letter math conventions (`x`, `y`, `dx` in geometric/numeric code)
- Function length per se — flag the underlying mixed-abstraction issue, not "100 lines is too long"
- Style preferences the linter would catch
- Domain jargon used correctly (don't demand "userIdentifier" when the team says "uid")

---

## Lens 3: Extensibility

Extensibility is a tradeoff, not a virtue. The goal is **right-sized extension points**, not maximum extensibility.

### What to look for

- **Missing seams where change is likely**: a payment processor with hardcoded Stripe, when the roadmap mentions adding PayPal next quarter
- **Speculative extension points**: plugin systems, registries, hooks added without a second client to justify them (this overlaps with Lens 1 — flag once, the more specific lens wins)
- **Closed for the wrong reason**: `private` or `final` blocking legitimate extension — but only flag if there's a real consumer who needs the seam
- **Hidden polymorphism**: long `if (type === 'A') ... else if (type === 'B') ...` chains scattered across files, when a single dispatch point would localize change
- **Brittle dispatch**: type switches that don't have a default-case alarm — adding a new type silently misses paths

### ❌ BAD: Scattered type switches

```typescript
// In billing.ts
if (account.tier === 'free') return 0;
if (account.tier === 'pro') return 19;
if (account.tier === 'enterprise') return 99;

// In limits.ts
if (account.tier === 'free') return 100;
if (account.tier === 'pro') return 10000;
if (account.tier === 'enterprise') return Infinity;

// In ui.ts
if (account.tier === 'free') return 'Upgrade';
// ... and three more files
```

### ✅ GOOD: Single dispatch table

```typescript
const TIERS = {
  free:       { price: 0,  apiLimit: 100,      cta: 'Upgrade' },
  pro:        { price: 19, apiLimit: 10000,    cta: 'Manage' },
  enterprise: { price: 99, apiLimit: Infinity, cta: 'Contact sales' },
} as const;

function tierConfig(tier: keyof typeof TIERS) {
  return TIERS[tier];
}
```

### Flag as HIGH if

- Adding a new variant requires editing 3+ files because the dispatch is scattered
- An extension point exists but has no consumer and no near-term plan for one (over-extensible)
- A type union is matched non-exhaustively (TypeScript: missing `never` check; other langs: no default)
- A "core" module imports a "plugin"-shaped module, inverting the dependency

### Don't flag

- Concrete code that has only ever needed one variant — wait for the second use
- Lack of a plugin system in code that has no plugins
- Hardcoded values that are genuinely constant (you don't need a strategy for `Math.PI`)

---

## Lens 4: Testability

A piece of code is testable if you can verify its behavior without monkey-patching, network access, or running the full system.

### What to look for

- **Hard-coded I/O**: direct `fetch`, `fs.readFile`, DB calls inside business logic instead of injected at the boundary
- **Hidden time/randomness**: `Date.now()`, `Math.random()`, `new Date()` baked into logic — tests can't assert "what happens at midnight?" without freezing time globally
- **Untestable side effects**: writes to global state, singletons that can't be reset, module-level mutable state
- **Boundary leaks**: pure-looking functions that secretly hit the network or filesystem
- **Pure-core / imperative-shell violations**: business rules tangled with I/O instead of pulled into pure functions
- **Hidden dependencies**: imports used like injected dependencies (e.g., directly importing a logger that should be a parameter)
- **Tests that exist would only pass if you also mocked an HTTP server** — the seam is in the wrong place

### ❌ BAD: Logic + I/O + clock all tangled

```typescript
async function shouldSendReminder(userId: string): Promise<boolean> {
  const user = await db.users.find(userId);                // I/O
  const lastEmail = await db.emails.lastFor(userId);       // I/O
  const hoursSince = (Date.now() - lastEmail.sentAt) / 3.6e6;  // hidden clock
  return user.notifications.email && hoursSince > 24;
}
```

### ✅ GOOD: Pure decision, I/O at the edge

```typescript
function shouldSendReminder(
  user: { notifications: { email: boolean } },
  lastEmailSentAt: number,
  now: number,
): boolean {
  if (!user.notifications.email) return false;
  const hoursSince = (now - lastEmailSentAt) / 3.6e6;
  return hoursSince > 24;
}

// Caller (thin shell, mostly untested):
async function checkAndSend(userId: string) {
  const user = await db.users.find(userId);
  const lastEmail = await db.emails.lastFor(userId);
  if (shouldSendReminder(user, lastEmail.sentAt, Date.now())) {
    await mailer.sendReminder(user);
  }
}
```

### Flag as HIGH if

- Business logic directly calls `Date.now()`, `Math.random()`, `process.env`, network, or filesystem
- A function can only be tested by mocking at the module-import level (monkey-patching)
- A class has 5+ untestable dependencies because they're created internally rather than injected
- The PR adds new business logic *without* extracting a pure function from it
- Existing tests use real I/O (HTTP, DB) for what could be a pure function — flag the production code, not just the test

### Don't flag

- I/O inside code that is *itself* the I/O boundary (a database adapter calling the database is fine)
- Top-level CLI entry points or scripts where a seam adds no value
- Configuration loading at startup
- Tests that already exist and work — the seam is fine, even if you'd organize it differently

---

## Lens 5: Cohesion & Coupling

### What to look for

- **Cohesion**: does this module/class/function do one thing, or several unrelated things glued together?
- **Coupling**: does changing X force changes to Y, Z, W? Are the things that change together *located* together?
- **Hidden coupling through shared mutable state**: globals, singletons, module-level vars
- **Coupling through serialization shape**: many modules reach into the same dict/JSON shape, so changing the shape requires editing all of them
- **Train wrecks** (`a.b.c.d.e`): the caller knows too much about `a`'s internals — fragile
- **Feature envy**: function in module X mostly reads/writes data from module Y; logic belongs in Y
- **Misplaced concerns**: business rules in controllers, presentation in models, validation in views

### ❌ BAD: Low cohesion

```typescript
class UserService {
  createUser(data: UserData) { /* ... */ }
  resetPassword(userId: string) { /* ... */ }
  generatePDFInvoice(orderId: string) { /* ??? */ }
  parseCSVExport(file: Buffer) { /* ??? */ }
  sendMarketingEmail(campaign: string) { /* ??? */ }
}
```

### ❌ BAD: Hidden coupling through shape

```typescript
// 8 different modules reach into this shape:
function pricePerUnit(item: any) { return item.pricing.tiers[0].amount; }
function unitName(item: any)     { return item.pricing.tiers[0].unit; }
function maxQty(item: any)       { return item.pricing.tiers[0].maxQty; }
// ...

// Now changing tier shape breaks 8 places.
```

### ✅ GOOD: Cohesive module + single shape owner

```typescript
class Pricing {
  constructor(private tiers: Tier[]) {}
  basePrice() { return this.tiers[0].amount; }
  baseUnit()  { return this.tiers[0].unit; }
  baseMaxQty() { return this.tiers[0].maxQty; }
}

// Only Pricing knows the tier shape.
```

### Flag as HIGH if

- A module's name doesn't predict its contents (the `Utils` smell)
- Adding a feature requires editing N unrelated files because they share a shape, not because they share a behavior
- Business logic lives in a controller/view/handler when the model could own it (see `software-development` skill, fat models / thin controllers)
- A function uses `other.foo`, `other.bar`, `other.baz` more than its own state — feature envy
- Module-level mutable state is read from or written to from outside that module
- A change to internal data structure requires changes outside the module that owns it

### Don't flag

- Big modules that are big because the domain is genuinely big (a payment-processing module has lots of code; that's not bad cohesion)
- Coupling that's inherent to the relationship (a controller couples to its model — that's fine; flag only when the coupling is *unnecessary*)
- One-off helpers that aren't worth a module

---

## Severity Rubric

Default to **HIGH** for cost-named quality findings — these slow every future change and erode the codebase over time.

| Severity | When | Examples |
|----------|------|----------|
| **HIGH** | Named cost; future changes will pay for this | Premature abstraction with no second use; misplaced business logic; hidden time dependency in business rule; type switches scattered across files |
| **MEDIUM** | Named cost is real but bounded; refactor would be marginal | A 60-line function that could be 3 functions but is already readable; a single `if` chain that *could* be a table but isn't large yet |
| **NIT** | Pure taste; no cost beyond aesthetics | Variable name preference; bracket style; ordering of methods |

### Anti-noise rule

**Don't post 8 nits.** Pick the top 2-3 quality findings — the ones that, if fixed, would meaningfully reduce the cost of the next change. A thread full of nits buries the actual signal and trains the author to ignore reviews.

If you find 8 candidate quality issues, that itself is a finding: post one HIGH that describes the systemic pattern, with examples, instead of 8 separate comments.

---

## Anti-Rationalization

The reviewer's failure mode for quality is: *"the author probably had a reason."*

| ❌ Don't | ✅ Do |
|---------|------|
| "There must be a reason this factory exists" | Flag it; let the author explain the reason |
| "Maybe this seam is needed elsewhere" | Search; if it isn't, flag |
| "Everyone names variables this way" | Check; if it's idiosyncratic to this PR, flag |
| "This is probably a stylistic choice" | If it costs the next reader, it's not just style |

The author *did* have reasons. Often they're load-bearing; sometimes they're not. The review is the place to surface the question.

---

## Common False-Positives

Things that look like quality issues but usually aren't:

1. **Short variable names in narrow math/loop scopes** — `i`, `x`, `acc` are fine in 3-line reduces
2. **Long functions in algorithm code** — a parser or solver may legitimately be long; the cost is inherent, not accidental
3. **Duplication that's coincidental, not semantic** — two functions with similar shapes but different reasons-to-change should NOT be merged
4. **"Too many parameters"** — 5 parameters is fine if they're all genuinely required and named clearly; bundling them into an options object is sometimes worse
5. **Domain language that sounds technical** — `transcludeBlockReference` may be exactly the right name in its domain
6. **Repetition driven by the framework** — Django views, React components, REST handlers have shapes the framework imposes
7. **Mutation in performance-critical code** — pure functional style isn't always free; flag only when there's no perf reason
8. **Missing abstraction in code that has only one caller** — wait for the second

If you find yourself flagging one of these, stop and ask: what's the specific cost?

---

## Quick Checklist

When reviewing a diff, ask one question per lens:

- [ ] **Simplicity**: Is there a simpler equivalent? Is anything here *not* yet justified by use?
- [ ] **Readability**: Could a new team member understand this without scrolling/searching?
- [ ] **Extensibility**: When the next variant arrives, where does the change land — one place or many?
- [ ] **Testability**: Can the business rules here be tested without I/O, time, or randomness mocks?
- [ ] **Cohesion/coupling**: Do things that change together live together? Does this module do one thing?

For each "no", name the cost. If you can't, don't post.

---

## The Golden Rules

1. **Name the cost** — every finding answers "what does this cost the next change?"
2. **Default to HIGH** — quality issues compound; treat them seriously
3. **Cap at 2-3 findings** — quality reviews are signal-or-bust; don't post nits in bulk
4. **Don't rationalize** — flag the question; let the author explain
5. **Wait for the second use** — abstraction without a second concrete client is speculation
6. **Pure core, imperative shell** — business rules should be testable without mocks
7. **Things that change together live together** — that's cohesion; everything else is coupling
