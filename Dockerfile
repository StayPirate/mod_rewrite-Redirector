FROM httpd-custom

LABEL description="Dockerized image of Apache2 with mod_rewrite, based on AlpineLinux. Use it to redirect/filter HTTP or HTTPS traffic to the C2."

COPY conf.d/ /usr/local/apache2/conf.d/
COPY launcher /usr/local/bin/

RUN	echo "IncludeOptional conf.d/*.conf" >> /usr/local/apache2/conf/httpd.conf && \
		sed -e '/Listen/s/^#*/#/' -i /usr/local/apache2/conf/httpd.conf && \
		chmod +x /usr/local/bin/launcher && \
		mkdir /cert
		
EXPOSE 8000
		
CMD ["launcher"]
