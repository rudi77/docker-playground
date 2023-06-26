# NOTE: both flask apps are identical, therefore we can use the same Dockerfile for both

FROM python:3.9
WORKDIR /app
COPY . .
RUN pip install flask
CMD ["python", "app1.py"]  # Override this for app2 in the Docker Compose file
