```bash
docker run -d -e CATTLE_ACCESS_KEY="token-h6s9h" \
 -e CATTLE_SECRET_KEY="g6jmr56wrmrf5jlc2jqjd27cl5lkb8dm9p5g677tj28sk99p6mr4c9"\
 -e CATTLE_URL="http://192.168.48.142:80/v3"\
 --name=rancher-exporter --restart=always \
 -p 9173:9173 infinityworks/prometheus-rancher-exporter
```

```
CATTLE_ACCESS_KEY // Rancher API access Key, if supplied this will be used when authentication is enabled.
CATTLE_SECRET_KEY // Rancher API secret Key, if supplied this will be used when authentication is enabled.
METRICS_PATH // Path under which to expose metrics.
LISTEN_ADDRESS // Port on which to expose metrics.
HIDE_SYS // If set to true then this hides any of Ranchers internal system services from being shown. *If used, ensure false is encapsulated with quotes e.g. HIDE_SYS="false".
LABELS_FILTER // Optional regular expression for filtering service and host labels, defaults to ^io.prometheus.
LOG_LEVEL // Optional - Set the logging level, defaults to Info.
API_LIMIT // Optional - Rancher API resource limit (default: 100)
```
