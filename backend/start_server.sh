#!/bin/bash
cd "$(dirname "$0")"
# Activate root venv
source ../.venv/bin/activate
# Run app
uvicorn main:app --reload --host 0.0.0.0 --port 8000
