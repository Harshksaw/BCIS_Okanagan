FROM python:3-alpine
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .
EXPOSE 80 8080
CMD ["/bin/sh", "startup.sh"]
