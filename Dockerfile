FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy server and the data folder
COPY server.py .
COPY data/ /app/data/

# Open port 7860 (Hugging Face default)
EXPOSE 7860

# Start Extreme V5 API using Uvicorn
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "7860"]
