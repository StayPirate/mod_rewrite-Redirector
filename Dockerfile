FROM httpd:alpine

COPY ./htaccess /var/www/html/.htaccess

RUN	echo "IncludeOptional conf.d/*.conf" >> /usr/local/apache2/conf/httpd.conf && \
	mkdir /usr/local/apache2/conf.d && \
	echo $'LoadModule rewrite_module modules/mod_rewrite.so \n\
	LoadModule proxy_module modules/mod_proxy.so \n\
	LoadModule proxy_http_module modules/mod_proxy_http.so \n\
	ServerName localhost \n\
	DocumentRoot "/var/www/html" \n\
	ErrorLog /dev/null \n\
	<VirtualHost *:80> \n\
		<Directory /var/www/html> \n\
			AllowOverride FileInfo \n\
			Require all granted \n\
		</Directory> \n\
	</VirtualHost>' >> /usr/local/apache2/conf.d/relay.conf
