# 🌾 AgroPredict
### AI-Powered Crop Price Intelligence for Indian Farmers

![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![Data](https://img.shields.io/badge/Data-Government%20API-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)

> Built by a farmer's daughter. For 140 million farmers who deserve the same market intelligence that big traders already have.

---

## 🎯 The Problem

A farmer in Odisha harvests his mango crop. He has two choices:

- Sell today at whatever the local trader offers
- Wait — and risk the crop spoiling

He has no data. No prediction. No idea that the same mango sells for ₹12,000/quintal just 2 districts away.

**This is the daily reality of 140 million Indian farmers.**

> *"The greatest value loss for farmers occurs not on the field but in the marketplace. Price discovery, not yield, is the biggest unsolved problem in Indian agriculture."*

---

## 📱 Demo

| Home Screen | Live Prices | Smart Advice |
|-------------|-------------|--------------|
| ![Home](assets/screenshots/dashboard.jpeg) | ![Prices](assets/screenshots/evidence.jpeg) | ![Advice](assets/screenshots/timer.jpeg) |

---

## 🚀 Features

| Feature | Description |
|---------|-------------|
| 📊 Live Mandi Prices | Real-time data from AGMARKNET government API |
| 🤖 Smart Sell Advice | "Best price at Ahmedgarh APMC — sell there now" |
| 🚛 Transport Calculator | Net profit after travel cost — "Worth it / Not worth it" |
| 🏆 Best Mandi Finder | Automatically identifies highest paying market |
| 🇮🇳 Hindi Language | Complete Hindi UI with one tap toggle |
| 🎤 Voice Input | Speak crop name — works in Hindi and English |
| 📈 Price Comparison | Bar chart comparing prices across 10+ mandis |

---

## 🧠 Intelligence Logic

\\\dart
// Smart advice — not just "highest price"
// Considers price variance across mandis

double percentAboveAvg = ((maxPrice - avgPrice) / avgPrice) * 100;

if (percentAboveAvg > 20) return 'SELL';      // Clear opportunity
if (avgPrice > 2500 && variance < 10) return 'SELL';  // Stable high price  
if (avgPrice < 1500 && variance < 10) return 'WAIT';  // Low — wait for better
if (percentAboveAvg > 10) return 'WAIT';      // Better price coming

// Transport Profit Logic
double netProfit = (price × quantity) - (distance × costPerKm);
bool worthIt = netProfit > (totalRevenue × 0.7);
\\\

---

## 🛠 Tech Stack

\\\
Frontend:      Flutter (Dart)
Data Source:   AGMARKNET API (Ministry of Agriculture, India)
Charts:        fl_chart
Storage:       shared_preferences
Voice:         speech_to_text
HTTP:          http package
Platform:      Android (tested on real device)
\\\

---

## 📊 Data Source

\\\
API: AGMARKNET — data.gov.in
Provider: Ministry of Agriculture, Government of India
Update frequency: Daily
Coverage: 3,000+ mandis across India
Fields: Crop, State, District, Market, Min/Max/Modal Price
Cost: Free (Open Government Data)
\\\

---

## 📲 Installation

\\\ash
git clone https://github.com/priya-codesdaily/agropredict.git
cd agropredict
flutter pub get
flutter run
\\\

---

## 🏗️ Architecture

\\\
lib/
├── main.dart
├── models/
│   └── crop_model.dart          # Data structure
├── services/
│   └── mandi_service.dart       # API + logic engine
└── screens/
    ├── home_screen.dart         # Search + voice input
    └── price_result_screen.dart # Results + calculator
\\\

---

## 🔮 Roadmap

- [x] Live AGMARKNET API integration
- [x] Smart sell advice engine
- [x] Transport profit calculator
- [x] Hindi language support
- [x] Voice input (Hindi + English)
- [ ] GPS-based nearest mandi
- [ ] 7-day price trend analysis
- [ ] Python ML price prediction (XGBoost)
- [ ] Weather alerts integration
- [ ] WhatsApp farmer notifications
- [ ] Offline mode with cached prices
- [ ] Odia + Telugu language support

---

## 📈 Impact Potential

\\\
Target farmers:        140 Million (India alone)
Post-harvest loss:     30% reducible with better decisions
Income improvement:    5%+ with better sell timing
AgriTech market 2025:   Billion
Expansion potential:   Bangladesh, Kenya, Vietnam, Nigeria
\\\

---

## 🌍 Why This Matters Globally

The same problem exists in:
- **Bangladesh** — Rice and jute price uncertainty
- **Kenya** — Maize and tea market intelligence
- **Vietnam** — Rice export pricing
- **Nigeria** — Cassava and yam price discovery

Same codebase. Different data source. Different language. **Same impact.**

---

## 👩‍💻 Developer

**Anshu Priya** — Self-taught Flutter Developer | BCA Student | Age 20 | Odisha, India

> *"My family grows mangoes. My mother taught me that value addition beats raw selling. I built AgroPredict so every farmer can make the same smart decisions."*

[![Portfolio](https://img.shields.io/badge/Portfolio-priya--codesdaily.github.io-blue)](https://priya-codesdaily.github.io)
[![GitHub](https://img.shields.io/badge/GitHub-priya--codesdaily-black?logo=github)](https://github.com/priya-codesdaily)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-a--priya--dev-blue?logo=linkedin)](https://linkedin.com/in/a-priya-dev)

---

> 💡 *AgroPredict is not just a project. It is the tool my father never had. Today I am building it for 140 million farmers just like him.*
