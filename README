# C2 Relay

This minimal AlpineLinux image runs Apache2 with mod_rewrite enabled. It's intended to quickly deploy a new relay to proxy requests through your C2.
It is useful either to hide the real IP of your C2 or to actively filter all those requests not generated from the agents.  
If you are just looking for a way to redirect all the traffic to your C2, without filter capability: you can use either `socat` or `iptables`. For more information [check here](https://bluescreenofjeff.com/2018-04-12-https-payload-and-c2-redirectors/).

### Custom Logic

After you cloned this repository, everything you need to do is adding a file called `htaccess` which contains the rewrite rules you want to put in place.
This file should never be shared since it will contain information about your C2.

### Template

The file [`htaccess.example`](htaccess.example) contains a simple template that can be used to block all the requests which don't match the User-Agent and the path you configured on the C2.
