FROM nginx
COPY src/index.html /usr/share/nginx/html
RUN chmod 744 /usr/share/nginx/html/index.html
