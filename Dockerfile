FROM httpd:alpine

LABEL description="Dockerized image of Apache2 with mod_rewrite, based on AlpineLinux. Use it to redirect/filter HTTP traffic to the C2."

ENV LISTENING_PORT 80

COPY ./htaccess /var/www/html/.htaccess

RUN	echo "IncludeOptional conf.d/*.conf" >> /usr/local/apache2/conf/httpd.conf && \
	sed -e '/Listen/s/^#*/#/' -i /usr/local/apache2/conf/httpd.conf && \
	mkdir /usr/local/apache2/conf.d && \
	echo -e 'LoadModule rewrite_module modules/mod_rewrite.so \n\
	LoadModule proxy_module modules/mod_proxy.so \n\
	LoadModule proxy_http_module modules/mod_proxy_http.so \n\
	ServerName localhost \n\
	DocumentRoot "/var/www/html" \n\
	ErrorLog /dev/null \n\
	Listen '$LISTENING_PORT' \n\
	<VirtualHost *:'$LISTENING_PORT'> \n\
		<Directory /var/www/html> \n\
			AllowOverride FileInfo \n\
			Require all granted \n\
		</Directory> \n\
	</VirtualHost>' >> /usr/local/apache2/conf.d/redirector.conf
