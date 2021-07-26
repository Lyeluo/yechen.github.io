#!/usr/bin/env bash
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-admin.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-admin.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-auth-proxy.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-auth-proxy.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-ca.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-ca.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-cloud-controller.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-cloud-controller.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-controller.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-controller.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-k3s-controller.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-k3s-controller.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-kube-apiserver.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-kube-apiserver.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-kubelet.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-kube-proxy.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-kube-proxy.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-scheduler.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/client-scheduler.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/request-header-ca.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/request-header-ca.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/server-ca.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/server-ca.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/service.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/serving-kube-apiserver.crt && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/serving-kube-apiserver.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/serving-kubelet.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/dynamic-cert.json && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/k3s.yaml && \
docker exec -it rancher /usr/bin/etcdctl --endpoints=127.0.0.1:2379 del /registry/secrets/kube-system/k3s-serving && \
docker restart rancher && docker logs -f rancher



docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/*.key && \
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/*.crt &&\
docker exec -it rancher rm -rf /var/lib/rancher/k3s/server/tls/dynamic-cert.json &&\
docker exec -it rancher /usr/bin/etcdctl --endpoints=127.0.0.1:2379 del /registry/secrets/kube-system/k3s-serving && \
docker restart rancher && docker logs -f rancher
