Set-Content -Path "C:\Users\hp\Desktop\agropredict\README.md" -Encoding UTF8 -Value @'
# AgroPredict 🌾

AgroPredict is a Flutter-based agricultural decision-support app built after talking directly with farmers in rural Odisha and Jharkhand.

The idea started from a simple problem I saw around me:

> Farmers work hard growing crops, but selling decisions are often made without enough market information.

So I started building a tool that helps farmers compare mandi prices, estimate profit, and make better selling decisions.

## What it does

- Live mandi prices using AGMARKNET government data
- GPS-based nearby mandi suggestions with real distance
- Profit estimation after transport cost
- Smart SELL / WAIT advice with reasoning
- Crop variety selection (from real farmer feedback)
- Voice input support for accessibility
- Hindi-friendly interface

## How it started

My mother is a farmer. She used this app without any guidance.
Her first question was — "which rice?" — because farmers think in varieties, not just crop names.

That one question became a feature the next day.

This is how this project works — real feedback, real improvements.

## Tested with

Farmers in Odisha and Jharkhand across multiple sessions.
A government block office worker in our district heard about it and reached out to test it.

## Tech

Flutter · Dart · AGMARKNET API · Geolocator · speech_to_text · fl_chart

## Status

Still evolving. Still talking to farmers. Still shipping.

Built with Flutter ❤️
'@
