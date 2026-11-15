# Kshetraajeev (क्षेत्राजीव)
 
> **Built for farmers who sell crops without knowing where the best price is.**
 
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Data](https://img.shields.io/badge/Data-AGMARKNET%20Gov%20API-2D6A4F)](https://agmarknet.gov.in)
[![Platform](https://img.shields.io/badge/Platform-Android-brightgreen)](https://github.com/priya-codesdaily/agropredict/releases)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)
 
---
 

Speak in your own language. Find out which mandi pays you the most after travel cost. Hear the answer spoken back.

```
Farmer (Hindi):   "मेरे पास बीस क्विंटल धान है"
App understood:   Crop: Rice, Quantity: 20 quintal       (farmer confirms)
App answers:      Berhampur is the best market. Rs. 1800 per quintal.
                  About Rs. 31,853 for 20 quintal after travel cost.
                  (spoken aloud in Hindi by Gnani Timbre; sample prices)
```

Built for the Great Indian AI Internship Challenge by Gnani.ai.
[Demo video]  · [Farmer documentary] https://youtu.be/2PWweDEcCpc?si=wcsmTyvgURWisKxc · [Portfolio](https://priya-codesdaily.github.io) · [LinkedIn post]


## Where this came from

My family grows crops every season, and every season we face the same problem: where to sell, and where to get the best price. Many times we lost money because we sold without knowing. I thought, if my family faces this, maybe other farmers face it too.

My mother handles the selling at home. She was the first person to test the app.

## How I built it

1. **A dummy app.** I first made a simple 3-screen prototype to test the idea: enter a crop, see prices, get advice.
2. **Farm visits.** From May to July 2026 I visited farms in Jharkhand and Odisha, asked farmers what they grow and what problems they face, and watched them use the app.
3. **Built from their feedback.** What I heard changed what I built (see the table below). When my mother asked "which rice?", I added crop varieties within 24 hours.
4. **A new name.** AgroPredict became Kshetraajeev. The name describes the land and the person who works it, the farmer and cultivator. I wanted the name to sound like the farmer, not like a technology product.
5. **Gnani voice, November 2026.** A farmer told me reading is difficult. I had already made a Hindi interface, and Gnani's speech models now let farmers speak and listen instead.

## Why

Farmers do not lack effort. They lack information: where to sell, to whom, whether the trip is worth the cost, and whether the price is fair. So many sell to the nearest mandi, or to whoever arrives first.

A supplier goes wherever the profit is, because he already knows the buyers and the margins. A farmer fears the trip: he does not know whether the price will be better, whether transport will eat the profit, or who will buy at the other end.

Sometimes the farther mandi still wins. In my research, mangoes were selling locally at Rs. 1,500 per quintal and fetching Rs. 1,800 at Berhampur, 347 km away. After estimated transport the trip was still about Rs. 200 per quintal better.

## What farmers told me

I spoke with **25 farmers and 2 market agents (27 people)** between May and July 2026. About 60% were in Jharkhand and 40% in Odisha. These were informal conversations, farm visits and app-testing sessions, not a formal survey. **13 farmers appear in the documentary**, the ones who were comfortable on camera.

Notes: [FIELD_RESEARCH.md](FIELD_RESEARCH.md).

| What I heard | What I built |
|---|---|
| "Kaunsi chawal?" (Which rice?) | Variety selector, shipped within 24 hours |
| "Padhne mein dikkat hota hai" (Reading is difficult for me) | Hindi interface, then Gnani voice in and out |
| "Profit nahi hota, mehnat ka faal nahi milta" | Profit calculator with transport cost |
| "Kitna kg mein?" | Rs/kg toggle |
| Farmers call friends to compare prices | Multi-mandi comparison |
| Neighbours informally split transport cost | Shared transport calculator |

I also heard about two problems that are not solved yet. When many farmers harvest together, prices fall and perishables like mango and tomato must be sold fast. And in the rainy season, transport is hard and spoilage speeds up.

## Why voice

> "Padhne mein dikkat hota hai." (Reading is difficult for me.)
> A farmer, during field research

I built a Hindi interface, and it helped farmers who read Hindi comfortably. But a Hindi screen still has to be read. Many farmers, especially in small villages, find reading difficult, and many have only basic Hindi or English or are not used to apps.

With voice, a farmer says one sentence and listens to the answer. Gnani's speech models understand Hindi, English and mixed speech, so a farmer does not need to type a crop name or read a screen.

Farmers did not ask me for AI or charts. They asked for simple, reliable information they can act on right away. So AI has one job here: let a farmer ask in their own words and hear a clear answer.

## How Gnani works in Kshetraajeev

Gnani handles the voice. It does not decide anything about money.

1. The farmer taps the mic and the app records a short clip (16 kHz mono WAV).
2. The app sends the clip to my backend (`POST /stt`). The backend forwards it to **Gnani Prisma** with the Gnani key and gets back the text, the detected language and the processing time.
3. The app reads the text and finds the crop, the quantity and the unit, then shows "I understood: Rice, 20 quintal".
4. The farmer taps Yes, or tries again if it was misheard.
5. The app compares mandis and picks the one with the best net return. This is plain Dart code.
6. The app writes a short sentence from those numbers, in Hindi or English.
7. The app sends the sentence to the backend (`POST /tts`). **Gnani Timbre** returns audio, the backend repairs the WAV header, and the app plays it.

```
Flutter app (Chrome or Android)
   records the voice as WAV
          |
          v
FastAPI backend  (holds the Gnani key, never in the app)
   POST /stt  -->  Gnani Prisma   speech to text
   POST /tts  -->  Gnani Timbre   text to speech
          |
          v
Flutter app: find crop and quantity, ask the farmer to confirm,
compare mandis, net return = price x quintals - distance x Rs. 12/km,
write the answer, speak it
```

| Gnani model | Endpoint | Used for |
|---|---|---|
| Prisma (speech to text), model `prisma-v3.0` | `POST /stt/v3` | Turns the spoken sentence into text. Language is auto-detected. |
| Timbre (text to speech), model `timbre-v2.5` | `POST /api/v1/tts/inference` | Speaks the recommendation. |

- No SDK. The backend calls the REST endpoints directly with `httpx`.
- Prisma's REST endpoint takes clips up to 30 seconds, so the app records one question at a time.
- Timbre streams WAV audio with the length left unset, which browsers refuse to play. The backend repairs the header first.
- Because the money calculation is plain code, the same input always gives the same answer.

## What changed after adding Gnani

| | Before | After |
|---|---|---|
| Voice input | The phone's built-in engine, one crop word into a text box | A whole sentence in Hindi, English or mixed; crop and quantity picked out |
| Voice output | The phone's voice reading generic advice | Gnani Timbre speaks an answer built from the farmer's own quantity |
| Steps for the farmer | Type the crop, pick a variety, find the Profit tab, enter distance and quantity | Say one sentence, tap Yes |
| Who it helps | Farmers who can read a Hindi screen | Also farmers who find reading difficult |
| Speed | n/a | About 0.3 s of processing for a short Hindi clip in my test |

## What it does

| Part | What it does |
|---|---|
| Speak screen | Record, transcribe, understand, confirm, answer, and replay the answer |
| Understanding | 11 crops in Hindi and English; numbers as digits or common Hindi and English words; units quintal and kg |
| Best market | Net return = modal price x quintals - distance x Rs. 12. Without a quantity or location it falls back to the highest price. |
| Full details | Overview, Profit and Markets tabs, in Hindi or English, with a Rs/kg toggle |
| Nearest mandi | GPS distance to 55 hand-built mandi locations on the Jharkhand-Odisha border |
| Shared transport | Calculator for splitting a vehicle with neighbours |
| Backend | `GET /health`, `POST /stt`, `POST /tts` |

## Examples

| You say | The app does |
|---|---|
| "मेरे पास बीस क्विंटल धान है" | Rice, 20 quintal. After you confirm: best market with earnings after travel cost, spoken in Hindi. |
| "I have twenty kg rice" | Rice, 20 kg. English answer, spoken in English. |
| "In which mandi is tomato higher in price?" | Tomato, quantity not mentioned. Shows the best price without an earnings figure. |
| A sentence with no crop in it | Says it could not find a crop and suggests what to say. |

## Screenshots

| Home | Confirm what was heard | Best market answer |
|---|---|---|
| ![Home](docs/screenshots/home.png) | ![Confirm](docs/screenshots/confirm.png) | ![Answer](docs/screenshots/answer.png) |

## Try it in ten minutes

You need Python 3.11+, the Flutter SDK, Chrome, and a Gnani API key (free at app.gnani.ai).

```bash
git clone https://github.com/priya-codesdaily/agropredict && cd agropredict/backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env        # then put your GNANI_API_KEY in .env
uvicorn main:app --reload --port 8000
```

In a second terminal, from the project root:

```bash
flutter pub get
flutter run -d chrome
```

Open `http://127.0.0.1:8000/health`. You should see `"gnani_key_loaded": true`. In the app, tap SPEAK, allow the microphone, and say "मेरे पास बीस क्विंटल धान है". You should see **Crop: Rice, Quantity: 20 quintal**. Tap Yes and the app answers and speaks.

No data.gov.in key is needed. Without one the app shows sample prices and labels them **SAMPLE DATA**. On an Android phone, put your laptop's address in `lib/services/voice_service.dart`.

Key files: `backend/main.py`, `lib/services/voice_service.dart`, `lib/screens/voice_screen.dart`, `lib/logic/decision_engine.dart`.

## Limits

- Prices are **sample data** unless a live data.gov.in key is configured, and the app says so on screen.
- Distance is a straight line, and transport is a flat Rs. 12 per km. Real roads are longer. For example, Rourkela shows about 23 km, while Google Maps says 43 km by road.
- Mandi coverage is limited to my hand-built list.
- Understanding is rule-based: 11 crops and a limited set of number words.
- English speech can come back in Devanagari letters. The app understands common crop, number and unit words in both scripts, but unusual words may be missed.
- Very short, single-word speech can be detected as the wrong language. Full sentences work much better.
- Odia is **not supported yet**. I have not been able to confirm Odia through the API.
- Timbre is marked beta by Gnani.
- Speech accuracy has not been measured on a large test set.
- Buyer and supplier contacts are not built, and they are the most important missing piece.
- The research is informal conversations with 27 people, not a statistical study. Not every farmer is comfortable with apps, and the effect on real earnings has not been measured.
- Audio is sent to Gnani for transcription. The backend does not store it.

## Roadmap

Buyer and supplier contacts, Odia voice, live prices, seasonal price trends, weather-aware selling advice, shared-transport matching between nearby farmers, and a pilot with 15 to 30 farmers.

## About

Made by Anshu Priya, a BCA student on the Odisha-Jharkhand border. The price comparison, profit calculator, variety selector and Hindi interface existed before this challenge, as AgroPredict. The voice flow, backend, new name and new home screen were built during the challenge.

AI use: Claude (Anthropic) helped with code, debugging and documentation. The field research, the documentary and the product decisions are my own.












