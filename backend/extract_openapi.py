import json
from main import app

# Generate OpenAPI schema (JSON)
openapi_json = app.openapi()

# Save as JSON
with open("openapi.json", "w") as f:
    json.dump(openapi_json, f, indent=2)

print("OpenAPI spec generated in openapi.json")
