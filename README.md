# docker-playground
A docker playground for any docker experiments

# Subdomain Mapping

This is a simple example which shows the subdomain mapping to a Docker container with Nginx as a reverse proxy works.

- Created Flask Applications: Created two simple Flask applications app1.py and app2.py. Each application listens on port 8000 and responds with a simple message to signify which application you are accessing. Here is the code for app1 which is exactly the same for app2. The only difference is the return string!
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, from App 1!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
```

- Created a Dockerfile: The Dockerfile we created sets up an environment to run the Flask applications. It starts with a base image of Python 3.9, sets a working directory in the Docker image, copies the current directory (which includes the Flask applications) into the Docker image, installs the Flask dependency, and finally sets a default command to start app1.py.
```Dockerfile
# NOTE: both flask apps are identical, therefore we can use the same Dockerfile for both
FROM python:3.9
WORKDIR /app
COPY . .
RUN pip install flask
CMD ["python", "app1.py"]  # Override this for app2 in the Docker Compose file
```

- Created Nginx Configuration Files: For each Flask application, we created an Nginx configuration file (app1.conf and app2.conf). Each configuration file sets up a server block that listens on port 80 and specifies the server_name as app1.localhost or app2.localhost. Inside each server block, a location block proxies all incoming requests to the corresponding Flask application running in a separate Docker container.
```nginx
server {
    listen 80;
    server_name app1.localhost;

    location / {
        proxy_pass http://web1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

- Created a Docker Compose File: The Docker Compose file defines three services: web1 and web2 for the Flask applications, and nginx for the Nginx reverse proxy. The web1 and web2 services are built using the Dockerfile we created earlier, and they override the default command to start the correct Flask application. The nginx service uses the official, latest Nginx image and mounts the local nginx directory to the /etc/nginx/conf.d directory in the container. This will automatically load all conf files (app1.conf and app2.conf)
```yml
version: '3'
services:
  web1:
    build: .
    command: ["python", "app1.py"]
    ports:
      - 8001:8000
  web2:
    build: .
    command: ["python", "app2.py"]
    ports:
      - 8002:8000
  nginx:
    image: nginx:latest
    ports:
      - 80:80
    volumes:
      - ./nginx:/etc/nginx/conf.d
    depends_on:
      - web1
      - web2
```

- __Optional__: modify the Hosts File: To make app1.localhost and app2.localhost resolve to the localhost IP address for testing purposes, we added entries to the system's hosts file. Open the hosts file with administrative privileges. On Unix-like systems, you can use sudo nano /etc/hosts (or replace nano with your preferred text editor). On Windows, you would open Notepad as an administrator and then open C:\Windows\System32\Drivers\etc\hosts. </br>
Add the following entries to the file:
```sh
127.0.0.1 app1.localhost
127.0.0.1 app2.localhost
```
