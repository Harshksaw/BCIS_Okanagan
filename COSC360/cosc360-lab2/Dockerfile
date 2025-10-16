FROM python:3-alpine
WORKDIR /app
COPY requirements.txt ./
RUN apk add --no-cache curl && pip install -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["flask", "run", "--host", "0.0.0.0", "--port", "5000"]
