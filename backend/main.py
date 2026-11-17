import os
from pathlib import Path

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from pydantic import BaseModel

load_dotenv(Path(__file__).parent / ".env")

GNANI_KEY = os.getenv("GNANI_API_KEY")
STT_URL = "https://api.vachana.ai/stt/v3"
TTS_URL = "https://api.vachana.ai/api/v1/tts/inference"

app = FastAPI(title="Kshetraajeev backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def require_key():
    if not GNANI_KEY:
        raise HTTPException(status_code=500, detail="GNANI_API_KEY is not set")


def fix_wav_header(audio: bytes) -> bytes:
    if len(audio) < 44 or audio[:4] != b"RIFF":
        return audio
    data = bytearray(audio)
    data[4:8] = (len(data) - 8).to_bytes(4, "little")
    data[40:44] = (len(data) - 44).to_bytes(4, "little")
    return bytes(data)


@app.get("/health")
def health():
    return {"status": "ok", "gnani_key_loaded": bool(GNANI_KEY)}


@app.post("/stt")
async def speech_to_text(
    audio: UploadFile = File(...),
    language_code: str = Form("indic-auto"),
):
    require_key()
    content = await audio.read()
    files = {
        "audio_file": (
            audio.filename or "audio.wav",
            content,
            audio.content_type or "audio/wav",
        )
    }
    data = {"model": "prisma-v3.0", "language_code": language_code}

    try:
        async with httpx.AsyncClient(timeout=60) as client:
            resp = await client.post(
                STT_URL,
                headers={"X-API-Key-ID": GNANI_KEY},
                files=files,
                data=data,
            )
    except httpx.RequestError:
        raise HTTPException(status_code=502, detail="Could not reach Gnani")

    if resp.status_code != 200:
        raise HTTPException(status_code=502, detail=resp.text[:300])
    return resp.json()


class TTSRequest(BaseModel):
    text: str
    language: str = "hi-IN"
    voice: str = "Nalini"


@app.post("/tts")
async def text_to_speech(body: TTSRequest):
    require_key()
    payload = {
        "text": body.text,
        "voice": body.voice,
        "model": "timbre-v2.5",
        "language": body.language,
        "speed": 1.0,
        "audio_config": {
            "sample_rate": 48000,
            "num_channels": 1,
            "sample_width": 2,
            "encoding": "linear_pcm",
            "container": "wav",
        },
    }

    try:
        async with httpx.AsyncClient(timeout=60) as client:
            resp = await client.post(
                TTS_URL,
                headers={"X-API-Key-ID": GNANI_KEY},
                json=payload,
            )
    except httpx.RequestError:
        raise HTTPException(status_code=502, detail="Could not reach Gnani")

    if resp.status_code != 200:
        raise HTTPException(status_code=502, detail=resp.text[:300])
    return Response(content=fix_wav_header(resp.content), media_type="audio/wav")
DATA_GOV_KEY = os.getenv("DATA_GOV_API_KEY")
MANDI_URL = "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"


@app.get("/prices")
async def prices(crop: str, state: str = "", limit: int = 100):
    if not DATA_GOV_KEY:
        raise HTTPException(status_code=500, detail="DATA_GOV_API_KEY is not set")

    params = {
        "api-key": DATA_GOV_KEY,
        "format": "json",
        "limit": limit,
        "filters[commodity]": crop,
    }
    if state:
        params["filters[state]"] = state

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            resp = await client.get(MANDI_URL, params=params)
    except httpx.RequestError:
        raise HTTPException(status_code=502, detail="Could not reach data.gov.in")

    if resp.status_code != 200:
        raise HTTPException(status_code=502, detail=resp.text[:300])
    return {"records": resp.json().get("records", [])}