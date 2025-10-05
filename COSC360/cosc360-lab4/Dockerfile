FROM python:3-alpine
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
EXPOSE 777
CMD ["flask", "run", "--host", "0.0.0.0", "--port", "5000"]
