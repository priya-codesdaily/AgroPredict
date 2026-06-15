# 📋 Field Research Notes — AgroPredict

> These notes document the informal conversations and observations that shaped AgroPredict's features. This is not formal academic research — it is product discovery through direct farmer conversations.

---

## Research Scope

| | |
|---|---|
| **Location** | Odisha & Jharkhand (border region) |
| **Participants** | Farmers, family members managing farm sales, local market visitors |
| **Method** | Informal conversations, direct observation, app testing sessions |
| **Goal** | Understand the selling challenges farmers face after harvest |
| **Personal context** | Grew up in a farming family — father grows crops, mother handles selling decisions |

---

## Key Findings

### Finding 1 — Farmers focus on profit, not price

Most farmers think about how much money reaches their hands after the trip — not just the mandi rate displayed on a board.

**Observation:** A farmer with 20 quintals of rice would rather sell at ₹1600/qtl at a nearby mandi than ₹1800/qtl at one 350km away — if transport costs ₹3500.

**Impact on product:** Built the transport profit calculator. GPS auto-fills the distance. App calculates net profit before the farmer makes the trip.

---

### Finding 2 — Farmers think in crop varieties, not general crop names

Asking "which crop?" is not enough. Farmers identify their produce by variety — and prices differ significantly between varieties.

**Observations:**
- "Which rice?" — first question from my mother on first use
- Basmati, Sona Masuri, Common rice have different market rates
- Different mango varieties (Alphonso, Langra, Dussehri) sell at different prices

**Impact on product:** Added variety selector. Farmers can now specify Rice — Basmati, Rice — Common, etc. Feature was shipped within 24 hours of feedback.

---

### Finding 3 — Voice is easier than typing

Several farmers said reading was difficult. Typing crop names in English was a barrier. Hindi voice input reduced friction significantly.

**Direct feedback:** *"Padhne mein dikkat hota hai"* (Reading is difficult for me)

**Impact on product:** Added voice input for crop name entry. Added voice output — app reads the advice aloud in Hindi so farmers hear the result without needing to read the screen.

---

### Finding 4 — Farmers rarely compare markets

Almost every farmer sells at the nearest local mandi — not because it's the best price, but because they have no easy way to compare alternatives.

**Observation:** Farmers in our area were selling mangoes at ₹1500/qtl locally. The same crop was fetching ₹1800/qtl at Berhampur — 347km away. After transport cost calculation, the trip was still profitable by ₹200/qtl.

**Impact on product:** Built the mandi comparison system. Shows all nearby mandis with prices, distances, and a BEST badge on the highest-value option.

---

### Finding 5 — Market information directly creates earning opportunity

Farmers who knew about price differences made better decisions. The information gap was the primary problem — not lack of access to markets.

**Impact on product:** The entire app is built around this insight. Price transparency is the core value proposition.

---

### Finding 6 — Small farmers lack market connections

Larger farmers have contacts, agents, and networks. Small farmers often sell to whoever arrives first — with little negotiating power.

**Impact on product:** The mandi comparison feature helps level this information gap without requiring personal connections.

---

## Product Decisions Table

| Observation | Feature Built |
|---|---|
| Farmers care about profit after transport | Transport profit calculator |
| Farmers think in varieties | Crop variety selector |
| Reading difficulty in the field | Voice output on advice screen |
| No easy way to compare mandis | Multi-mandi comparison with distance |
| Data freshness matters for trust | Price date shown on every result |
| Hindi more accessible than English | Full Hindi UI |

---

## Current Limitations

- Geographic coverage limited to mandis in our curated database (~70+ cities)
- Sample size is small — conversations with farmers in Odisha and Jharkhand
- Distance is estimated from GPS coordinates, not actual road distance
- Price data freshness varies by mandi — some update daily, some less frequently
- Features are still being tested and improved based on ongoing feedback

---

## Next Research Areas

Based on farmer conversations, these are the next areas to investigate:

- **Shared transport** — farmers already coordinate informally; an app feature could formalise this
- **Weather impact** — rain affects transport decisions for perishable crops
- **Price history** — farmers want to know if today's price is high or low compared to recent weeks
- **Buyer discovery** — finding who is buying is often harder than finding the price

---

## Notes on Method

These conversations were informal. I visited farms, asked questions, watched farmers interact with the app, and noted what confused them or what they asked for. No formal survey was conducted. The insights here are qualitative observations, not statistically representative findings.

The goal was not to produce research — it was to build something that actually helps.

---

*Last updated: June 2026 · Anshu Priya · github.com/priya-codesdaily*
