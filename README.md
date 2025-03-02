# WordPress Nginx

This config kit contains the Nginx configurations used in the [Install WordPress on Ubuntu 22.04](https://spinupwp.com/install-wordpress-ubuntu/) guide. It contains best practices from various sources, including the [WordPress Codex](https://codex.wordpress.org/Nginx) and [H5BP](https://github.com/h5bp/server-configs-nginx). The following example sites are included:

* [single-site.com](sites-available/single-site.com) - WordPress single site install
* [single-site-with-caching.com](sites-available/single-site-with-caching.com) - WordPress single site install with FastCGI caching
* [single-site-no-ssl.com](sites-available/single-site-no-ssl.com) - WordPress single site install (no SSL or page caching)

## Usage

### Site configuration

Symlink the default file from _sites-available_ to _sites-enabled_, which will setup a catch-all server block. This will ensure unrecognised domains return a 444 response.

`ln -s ../sites-available/default ./nginx/sites-enabled/default`

Copy one of the example configurations from _sites-available_ to _sites-available/yourdomain.com_:

`cp ./nginx/sites-available/single-site.com ./nginx/sites-available/yourdomain.com`

Edit the site accordingly, paying close attention to the server name and paths.

To enable the site, symlink the configuration into the _sites-enabled_ directory:

`ln -s ../sites-available/yourdomain.com ./nginx/sites-enabled/yourdomain.com`

Restart Nginx:

`docker compose restart nginx`


## Directory Structure

This config kit has the following structure, which is based on the conventions used by a default Nginx install on Debian:

```
.
├── conf.d
├── global
    └── server
├── sites-available
├── sites-enabled
```

__conf.d__ - configurations for additional modules.

__global__ - configurations within the `http` block.

__global/server__ - configurations within the `server` block. The `defaults.conf` file should be included on the majority of sites, which contains sensible defaults for caching, file exclusions and security. Additional `.conf` files can be included as needed on a per-site basis.

__sites-available__ - configurations for individual sites (virtual hosts).

__sites-enabled__ - symlinks to configurations within the `sites-available` directory. Only sites which have been symlinked are loaded.

