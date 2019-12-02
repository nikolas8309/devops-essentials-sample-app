FROM nginx
COPY src/index.html /usr/share/nginx/html
RUN ls -a /usr/share/nginx/html