#!/usr/bin/env bash
mkdir -p /opt/prometheus/conf
/opt/consul-template   -consul-addr ${CONSUL_ADDR}:${CONSUL_PORT}   -template "/opt/prometheus.ctmpl:/opt/prometheus/conf/prometheus.yml"   -retry 30s   -once
