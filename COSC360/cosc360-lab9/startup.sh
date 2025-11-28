#!/bin/sh
flask --app app_1 run --host 0.0.0.0 --port 80 &
flask --app app_2 run --host 0.0.0.0 --port 8080
