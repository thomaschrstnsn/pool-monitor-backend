# https://hub.docker.com/r/grafana/grafana/tags
FROM grafana/grafana:11.0.1

# https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/
ENV GF_ANALYTICS_REPORTING_ENABLED=false \
    GF_AUTH_ANONYMOUS_ENABLED=false \
    GF_AUTH_BASIC_ENABLED=true \
    GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_SECURITY_ADMIN_USER=admin \
    GF_SECURITY_ALLOW_EMBEDDING=true \
    GF_SECURITY_DISABLE_GRAVATAR=true \
    GF_USERS_ALLOW_SIGN_UP=false \
    GF_USERS_DEFAULT_LANGUAGE=detect \
    GF_DATE_FORMATS_USE_BROWSER_LOCALE=true \
    DATABASE_PORT=5432 \
    DATABASE_SSL_MODE=disable


USER grafana

COPY datasource.yml /etc/grafana/provisioning/datasources/
# COPY dashboards.yml /etc/grafana/provisioning/dashboards/
# COPY dashboards/*.json /dashboards/

EXPOSE 3000
