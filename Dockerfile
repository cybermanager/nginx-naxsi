FROM bitnami/minideb:bullseye

ENV latestNginx="1.22.1"
ENV latestNaxsi="1.3"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install wget g++ gcc libpcre3-dev zlib1g-dev libxml2-dev libxslt1-dev libgd-dev libgeoip-dev make libssl1.1 jq -y && \
    apt-get update && \
    apt-get install libssl-dev -y

RUN cd /tmp && \
    wget -q http://nginx.org/download/nginx-${latestNginx}.tar.gz && \
    wget -q https://github.com/nbs-system/naxsi/archive/${latestNaxsi}.tar.gz && \
    tar xzf nginx-${latestNginx}.tar.gz && \
    tar xzf ${latestNaxsi}.tar.gz

RUN cd /tmp/nginx-${latestNginx} && \
    ./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --add-module=../naxsi-${latestNaxsi}/naxsi_src/ --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_xslt_module=dynamic --with-stream=dynamic --with-stream_ssl_module --with-mail=dynamic --with-mail_ssl_module && \
    make && \
    make install

RUN mkdir -p /var/lib/nginx/body && \
    chown -R 1001:1001 /var/lib/nginx/body && \
    chown -R 1001:1001 /var/lib/nginx

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN cp /tmp/naxsi-${latestNaxsi}/naxsi_config/naxsi_core.rules /etc/nginx/

RUN mkdir -p /run && \
    touch /run/nginx.pid && \
    chown -R 1001:1001 /run/nginx.pid

EXPOSE 80

STOPSIGNAL SIGQUIT

USER 1001

CMD ["nginx", "-g", "daemon off;"]