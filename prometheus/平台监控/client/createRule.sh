#!/usr/bin/env bash
mkdir -p /opt/prometheus/rules
/opt/consul-template   -consul-addr ${CONSUL_ADDR}:${CONSUL_PORT}   -template "/opt/ctmpl/rule.ctmpl:/opt/prometheus/rules/ecs.rule"   -retry 30s   -once



