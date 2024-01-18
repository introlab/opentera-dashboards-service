FROM nginx

COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/opentera.conf /etc/nginx/opentera.conf
COPY ./nginx/opentera-dashboards-service.conf /etc/nginx/opentera-dashboards-service.conf

# Create self signed certificate for 10 years
RUN mkdir /certificates
RUN openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /certificates/nginx-selfsigned.key -out /certificates/nginx-selfsigned.crt -subj "/C=CA/ST=QC/L=Montreal/O=IntRoLab/OU=Dev/CN=proxy.local"

# Create CA certificate
RUN openssl genrsa -out /certificates/ca.key 2048
RUN openssl req -x509 -new -nodes -key /certificates/ca.key -sha256 -days 3650 -out /certificates/ca.crt -subj "/C=CA/ST=QC/L=Montreal/O=IntRoLab/OU=Dev/CN=proxy.local"
