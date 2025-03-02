# Define path to cache and memory zone. The memory zone should be unique.
# keys_zone=single-site-with-caching.com:100m creates the memory zone and sets the maximum size in MBs.
# inactive=60m will remove cached items that haven't been accessed for 60 minutes or more.
fastcgi_cache_path /tmp/single-site-with-caching.com/cache levels=1:2 keys_zone=single-site-with-caching.com:100m inactive=60m;

server {
	# Ports to listen on
	listen 443 ssl;
	listen [::]:443 ssl;
	http2 on;

	# Server name to listen for
	server_name single-site-with-caching.com;

	# Path to document root
	root /var/www/html;

	# Paths to certificate files.
	ssl_certificate /etc/letsencrypt/live/single-site-with-caching.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/single-site-with-caching.com/privkey.pem;

	# File to be used as index
	index index.php;

	# Default server block rules
	include global/server/defaults.conf;

	# Fastcgi cache rules
	include global/server/fastcgi-cache.conf;

	# SSL rules
	include global/server/ssl.conf;

	location / {
		try_files $uri $uri/ /index.php?$args;
	}

	location ~ \.php$ {
		try_files $uri =404;
		include global/fastcgi-params.conf;

		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass wordpress:9000;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param PATH_INFO $fastcgi_path_info;

		# Skip cache based on rules in global/server/fastcgi-cache.conf.
		fastcgi_cache_bypass $skip_cache;
		fastcgi_no_cache $skip_cache;

		# Define memory zone for caching. Should match key_zone in fastcgi_cache_path above.
		fastcgi_cache single-site-with-caching.com;

		# Define caching time.
		fastcgi_cache_valid 60m;
	}
}

# Redirect http to https
server {
	listen 80;
	listen [::]:80;
	server_name single-site-with-caching.com www.single-site-with-caching.com;

	return 301 https://single-site-with-caching.com$request_uri;
}

# Redirect www to non-www
server {
	listen 443 ssl;
	listen [::]:443 ssl;
	http2 on;
	
	server_name www.single-site-with-caching.com;

	return 301 https://single-site-with-caching.com$request_uri;
}