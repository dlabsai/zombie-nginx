# NGINX template for Zombie

An Alpine-based Docker container with mainline nginx, configuration generator, and automatic TLS.

## Usage

Assuming you have an application server in a container called `webapp`, that you want to serve, add in your
`docker-compose.yml`:

```yaml
webapp-nginx:
  image: typeai/zombie-nginx
  restart: always
  depends_on:
    - webapp
  volumes:
    - "/path/to/webapp-nginx.yml:/etc/appconf/nginx.yml:ro"
    - "/path/to/certificates/:/etc/nginx/certs"
    - "your-static-files:/var/www/webapp-static:ro"
  environment:
    - "LETSENCRYPT_EMAIL=admin@example.com"
  ports:
    - "0.0.0.0:80:80"
    - "0.0.0.0:443:443"
```

With your `webapp-nginx.yml` looking like this:

```yaml
servers:
  webapp:
    server_name: my-webapp.example.com
    upstream: uwsgi://webapp:12345
    static_files: /var/www/webapp-static
    tls: auto
```

If you have `your-static-files` Docker volume with static files for your web application, and a uWSGI instance (or
something else talking the `uwsgi` protocol) listening on port `12345` in the `webapp` container, this setup will feed
a nice `nginx.conf` to nginx, and server your application via HTTPS with certificate obtained from Let's Encrypt.

## `nginx.yml` options

Each entry in the `servers` section represents a separate virtual host.

- `check_host_header`: optional, bool, default `yes`; whether to close connection on invalid `HTTP_HOST`
- `server_name`: required, string; domain name where your site lives, can be a list of domains separated with space
- `static_files`: optional, string or mapping or array of mappings; maps a location on the virtual host to a mounted
 volume with static files

    - `static_files.location`: required, string: location to serve the files at
    - `static_files.path`: required, string: path where the static files are mounted
    - `static_files.spa`: optional, string: if specified, file to be served for requests not matching any existing
    static file, e.g. `index.html`

    if a string is given, it is interpreted to be `static_files.path`, with `static_files.location` set to `/static.
    You can provide an array of mappings to specify multiple static files mounts.

- `tls`: required, `no`, `auto` or mapping or array of mappings; tells nginx where to find your TLS certificates, to
 get them automatically via Let's Encrypt, or to serve unencrypted HTTP

    - `tls.certificate`: required, string: the path to a full-chain certificate file
    - `tls.key`: required, string: the path to a private key file, matching the certificate
    - `tls.root_chain`: required once per virtual host, string: the path to a root chain file for use with OCSP stapling

    the paths are relative to `/etc/nginx/certs` (or `/path/to/certificates` if you follow the example above). You can
    provide an array of mappings in this format to specify multiple certificates.

- `upstream`: optional, string or mapping; defines an upstream server to forward requests to

    - `upstream.url`: required, string: upstream server's URL with protocol, e.g. `uwsgi://some-host:12345`. Supported
    protocols are `uwsgi` and `http`
    - `upstream.name`: optional, string: name used to identify this upstream server inside nginx config. Must be unique
    across all virtual hosts. If not given, one will be generated automatically
    - `upstream.location`: required, string: location to attach the upstream at

    if a string is given, it is interpreted to be `upstream.url`, with `upstream.location` set to `/`,
    and `upstream.name` `$server_name-upstream`

### Setting nginx options directly

To add or override an nginx option directly in the generated `nginx.conf` file, add desired settings in the
`http_raw_options`, `server_raw_options`, or `upstream_raw_options` array.

```yaml
http_raw_options:
  - keepalive_timeout 10
servers:
  webapp:
    server_name: my-webapp.example.com
    server_raw_options:
      - client_max_body_size 10M
    upstream:
      name: webapp-upstream
      url:  uwsgi://webapp:12345
      location: /
      upstream_raw_options:
        - add_header "Access-Control-Allow-Methods" "GET, POST, OPTIONS"
```

## Known issues

The project was only tested with a few specific setups, and certainly not with every possible combination of settings.

## Contributing

Of course, pull requests are welcome. Keep in mind though that ease of use and as little configuration as possible are
among main goals of this project.
