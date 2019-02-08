# Apache mod_rewrite C2 Redirector

Using apache with mod_rewrite as a redirector for your Command and Control (C2) infrastructure falls in the red-team's best practicies.
Unfortunatly is a really quite annoing setup. This Docker image is made to help you on quickly deploy new redirectors executing **just one simple command**. If you want to use **HTTPS, you only need to execute one additional command**, since the generation of the certificates has been automated as well.

### TL;DR

Gimme the [commands](#HTTPS_Redirector_-_The_Fast_Way).

### Why Apache with mod_rewrite
If you only want to redirect all the traffic from redirectos to your C2, without regarding from where and whom the requests has been generated, you can simply do it either with `socat` or `iptables`. This kind of setup is known as **dumb pipe**, in other words you can just forward all the traffic or at most only filter it for source IP.
Instead, if your are not only interessed on hiding the C2 real IP, and you want the ability to granulary filter requests you want to forward to your C2... so, you are in the right place. Apache2's module `mod_rwrite` allows you to make custom responses based on your own mod_rewrite's rule set which you can match requests using regex. This is not an how to write rewrite rules, you can find great guides and all the required documentation on internet. Check-out useful links section [below](#Useful_link). 

### Rewrite Ruleset
What is really important for a redirector is the **rewrite ruleset**. These rules reside in a `.htaccess` file that you need to pass to the container with the volume option `-v`. This file contains information about your C2 infrastructure. Hence, **you should never share it**. Information like the real C2's IP and paths used in the C2's profile can be deduced from it.  
The file [`htaccess.example`](htaccess.example) is a sample that you can use as a tamplate. It only forwards to the C2 requests that match the **user-agent** and **resouce paths** of the default [Empire](http://www.powershellempire.com/) profile, all the other requests are redirected to www.google.com.

### How to use it
Using this image you can easely deploy either HTTP or HTTPS redirector. If you need to redirect HTTP and HTTPS traffic, run two different containers with se same image.  
In order to run any kind of redirector you need the `.htaccess` file ready on your filesystem. In the following examples we will consider this file is present in the same directory from where the command is executed.  
**Important:** Whatever protocol you will choose (HTTP or HTTPS) the Apache2 instance will be listening to the container internal port 8000, you will then choose on which port bind it using the Docker's publish option `-p` in the command line. 
- ##### HTTP Redirector
To run a HTTP redirector which uses a rewrite ruleset in `./.htaccess` use:  
`docker container run -p 80:8000 -v $(pwd)/.htaccess:/var/www/html/.htaccess StayPirate/mod_rewrite-Redirector`
- ##### HTTPS Redirector
To run a HTTPS redirector which uses a rewrite ruleset in `./.htaccess`, you also need valid certificates for the domain/s pointing it. To pass these certificates you need to copy them inside a directory, then pass the directory as a volume `-v` mapping it with the container's internal directory `/cert`. Moreover, to let Apache being able to find these files you have to use the following name convention:

 - **privkey.pem** - Private key for the certificate (Apache: [SSLCertificateKeyFile](https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslcertificatekeyfile) - Nignx: [ssl_certificate_key](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate_key)).
 - **fullchain.pem** - All certificates, including server certificate (aka leaf certificate or end-entity certificate) for your domain/s name (Apache >= 2.4.8: [SSLCertificateFile](https://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslcertificatefile) - Nginx: [ssl_certificate](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate)). 

 Lets assume you have put this two file in `./certificate/privkey.pem` and `./certificate/fullchain.pem`, while your rewrite ruleset is `./.htaccess`. To spin the HTTPS Redirector use:  
 `docker container run -p 443:8000 -v $(pwd)/.htaccess:/var/www/html/.htaccess -v $(pwd)/certificate:/cert StayPirate/mod_rewrite-Redirector`

- ##### HTTPS Redirector - The Fast Way
I created another Docker image to automatically generate valid certificates. Of course, it works only under specific conditions.  
The requirements are:
 1. You want to use Let's Encrypt as certification authority.
 2. You have shell access to the redirector.
 3. You have enough privileges to run Docker containers.
 4. The domian/s you want to certify already point to the redirector's IP.
 5. Port 80 free for few seconds. The container needs to use port 80 during the authentication process, then it release the port.
 
 If all the above requirement are sudisfied, you can quickly spin a HTTPS Redirector using the two following commands:  
 `docker container run --rm -v cert:/cert StayPirate/CertifyRedirector domain_to_verify.com`  
 `docker container run -p 443:8000 -v $(pwd)/.htaccess:/var/www/html/.htaccess -v cert:/cert StayPirate/mod_rewrite-Redirector`  
 
 As you may have notice, in this case I'm using named volume. The first container uses certbot to generate and verify certificates for **domain_to_verify.com**, it copy them in a valume named `cert` following the name convention mentioned above, then it exits and delete itself. The second command executes the HTTPS redirector mapping the valume named `cert` with the `/cert` directory inside the container, allowing Apache to find the certificates.  
 You can use the first image to verify more than one domain at the same time, please refer to its [page](https://github.com/StayPirate/CertifyRedirector) for more info.
 
### Internals
If you are wandering why you can use the same container to run either HTTP or HTTPS Apache2 instance, the answare is easy. There is a [script](launcher) which starts when you initialy run the container which check if `/cert` directory is empty or not, if it is empty it set the VirtualHost to work with HTTP while in the other case is set the VirtualHost to work with HTTPS. In both cases Apache will listen on port 8000 and it's your responsability to map it with the desidered port using the `-p` option. For instance if you want to run HTTPS over port 80, just use `-p 80:8000` and pass the certificates with `-v cert:/cert`.

#### Useful links
Here some good links which can help you on writing your rewrite ruleset.
 - [Bluescreenofjeff](https://bluescreenofjeff.com/2018-04-12-https-payload-and-c2-redirectors/) great introduction.
 - [mod_rewrite cheatsheet](https://mod-rewrite-cheatsheet.com/)
 - [Apache mod_rewrite Introduction](https://httpd.apache.org/docs/2.4/en/rewrite/intro.html)
 - [Web Redirection schema](https://httpd.apache.org/docs/2.4/en/rewrite/intro.html)
