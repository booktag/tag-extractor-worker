import json
import os
import random
import re
from pathlib import Path

import fsspec
import spacy
from dotenv import load_dotenv, find_dotenv

# Load .env into process environment
load_dotenv()

print(os.getenv("AWS_PROFILE"))

print("Testing spacy models:")
try:
    nlp = spacy.load("en_core_web_md")
    doc = nlp("This is a quick smoke test for SpaCy running inside Alpine.")
    print("SpaCy loaded successfully.")
    print("Tokens:", [t.text for t in doc])
    print("Entities:", [(e.text, e.label_) for e in doc.ents])
except Exception as e:
    print("SpaCy test failed:", e)

envKeys = ('JOB_ID', 'ARTIFACTS_ROOT_PATH', 'DICTIONARIES_PATH')

print("Environment variables:")
for key, value in os.environ.items():
    if key.startswith(envKeys):
        print(f"{key} = {value}")

env_path = Path(find_dotenv())
# Base dir of your .env file
ENV_BASE_DIR = env_path.parent.resolve()


def resolve_env_path(key: str, default: str = None) -> str | None:
    """Normalize a path for local or S3 storage.
    Returns a clean absolute path string suitable for fsspec.
    - Keeps s3:// and other URIs untouched
    - Converts relative local paths to absolute paths
    - Handles Windows and Linux forms
    """
    raw = os.getenv(key, default)
    if not raw:
        return None

    if not raw:
        raise ValueError("Empty path string")

    # 1️⃣ Detect remote or URI scheme (s3://, gs://, etc.)
    if re.match(r"^[a-zA-Z0-9]+://", raw):
        return raw  # leave S3 and other schemes as-is

    # 2️⃣ Create Path object
    p = Path(raw)

    if not p.is_absolute():
        p = ENV_BASE_DIR / p

    return str(Path(p).resolve())


def read_dictionary(filename: str):
    """Read JSON file from local or S3."""
    path = f"{DICTIONARIES_PATH}/{filename}"
    with fsspec.open(path, "r") as f:
        return json.load(f)


def write_artifacts(filename: str, data):
    """Write JSON file to local or S3."""
    path = f"{ARTIFACTS_ROOT_PATH}/artifacts/{filename}"
    with fsspec.open(path, "w",
                     s3_additional_kwargs={"ContentType": "application/json"}) as f:
        json.dump(data, f, indent=2)


JOB_ID = os.environ.get('JOB_ID')
DICTIONARIES_PATH = resolve_env_path("DICTIONARIES_PATH")
ARTIFACTS_ROOT_PATH = resolve_env_path("ARTIFACTS_ROOT_PATH")

print("Read dictionaries from:", DICTIONARIES_PATH)
dictionary = read_dictionary("dictionary.json")
print("Dictionary:", json.dumps(dictionary, indent=2))

print(f"Write {JOB_ID} artifacts to: {ARTIFACTS_ROOT_PATH}/artifacts")
write_artifacts(f"{JOB_ID}.json", {
    "current": random.randint(1, 100),
    "max": random.randint(1, 100)
})
print("===Completed===")
