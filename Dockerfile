FROM httpd:alpine

LABEL description="Apache2 dockerized image with mod_rewrite, based on Alpine Linux. Used to filter and redirect either HTTP or HTTPS traffic through a C2. "

COPY conf.d/ /usr/local/apache2/conf.d/
COPY launcher /usr/local/bin/

RUN	echo "IncludeOptional conf.d/*.conf" >> /usr/local/apache2/conf/httpd.conf && \
		sed -e '/Listen/s/^#*/#/' -i /usr/local/apache2/conf/httpd.conf && \
		chmod +x /usr/local/bin/launcher && \
		mkdir /cert
		
EXPOSE 8000
		
CMD ["launcher"]
