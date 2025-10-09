FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# For `flask run`
ENV FLASK_APP=app.py

EXPOSE 777
CMD ["flask", "run", "--host=0.0.0.0", "--port=777"]
