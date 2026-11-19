import csv
import json
import mimetypes
import statistics
import sys
import time
from pathlib import Path

import httpx

HERE = Path(__file__).parent
URL = "http://127.0.0.1:8000/stt"

# python eval/run_eval.py           -> the 40 tuned sentences
# python eval/run_eval.py heldout   -> the 10 unseen sentences
which = sys.argv[1] if len(sys.argv) > 1 else "main"
if which == "heldout":
    CSV_NAME, CLIPS_DIR, OUT_NAME = "expected_heldout.csv", "clips_heldout", "transcripts_heldout.json"
else:
    CSV_NAME, CLIPS_DIR, OUT_NAME = "expected.csv", "clips", "transcripts.json"

with open(HERE / CSV_NAME, encoding="utf-8-sig", newline="") as f:
    rows = list(csv.DictReader(f))

results = {}
latencies = []

with httpx.Client(timeout=60) as client:
    for row in rows:
        num = row["file"].strip()
        found = list((HERE / CLIPS_DIR).glob(num + ".*"))
        if not found:
            print(f"{num}  no clip found")
            continue

        clip = found[0]
        mime = mimetypes.guess_type(clip.name)[0] or "audio/wav"
        started = time.perf_counter()
        try:
            resp = client.post(
                URL,
                files={"audio": (clip.name, clip.read_bytes(), mime)},
                data={"language_code": "indic-auto"},
            )
            seconds = time.perf_counter() - started
            if resp.status_code != 200:
                print(f"{num}  error {resp.status_code}: {resp.text[:120]}")
                continue
            body = resp.json()
        except httpx.HTTPError as e:
            print(f"{num}  request failed: {e}")
            continue

        text = (body.get("transcript") or "").strip()
        results[num] = {
            "transcript": text,
            "language": body.get("detected_language_code"),
            "seconds": round(seconds, 2),
        }
        latencies.append(seconds)
        print(f"{num}  {seconds:4.2f}s  {text}")
        time.sleep(0.3)

(HERE / OUT_NAME).write_text(
    json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8"
)

print()
print(f"{len(results)} of {len(rows)} clips transcribed")
if latencies:
    latencies.sort()
    p95 = latencies[min(len(latencies) - 1, int(len(latencies) * 0.95))]
    print(f"Median {statistics.median(latencies):.2f}s, 95th percentile {p95:.2f}s")