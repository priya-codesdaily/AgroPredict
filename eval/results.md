# Parser accuracy: tuned set

| Group | Correct |
|---|---|
| Hindi | 17 of 20 (85%) |
| English | 9 of 10 (90%) |
| Hinglish | 8 of 10 (80%) |
| **All** | **34 of 40 (85%)** |

Crop correct: 37 of 40
Quantity and unit correct: 36 of 40
Median request time: 1.77 s

## Failures

- 03 (Hindi): heard "कितना क्विंटल टमाटर बेचना है?"
    expected Tomato 10 quintal  |  got Tomato - quintal
- 10 (Hindi): heard "बीस किलो केला है।"
    expected Bitter Gourd 20 kg  |  got - 20 kg
- 19 (Hindi): heard "क्विंटल धान है।"
    expected Rice 3 quintal  |  got Rice - quintal
- 25 (English): heard "आई हैव फ़ाइव क्विंटल बी।"
    expected Wheat 5 quintal  |  got - 5 quintal
- 34 (Hinglish): heard "ਫਿਫਟੀ ਕਿਲੋ ਪਿਆਜ਼ ਹੈ।"
    expected Onion 50 kg  |  got - - 
- 38 (Hinglish): heard "मेरे पास फ़िफ्टी क्विंटल ओनियन है।"
    expected Onion 15 quintal  |  got Onion 50 quintal
