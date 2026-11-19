# Parser accuracy: unseen set

| Group | Correct |
|---|---|
| Hindi | 3 of 4 (75%) |
| English | 3 of 3 (100%) |
| Hinglish | 2 of 3 (67%) |
| **All** | **8 of 10 (80%)** |

Crop correct: 9 of 10
Quantity and unit correct: 9 of 10
Median request time: 1.75 s

## Failures

- 44 (Hindi): heard "क्या एक क्विंटल आम बेचना है?"
    expected Mango 11 quintal  |  got Mango 1 quintal
- 48 (Hinglish): heard "मेरे पास फोर्टी क्विंटल पेड़ी है।"
    expected Rice 40 quintal  |  got - 40 quintal
