# Use official Python runtime as a parent image
FROM python:3.12-slim

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port (FastAPI default)
EXPOSE 8000

# Ensure start.sh is executable
RUN chmod +x start.sh

# Run the application via start script
CMD ["./start.sh"]
