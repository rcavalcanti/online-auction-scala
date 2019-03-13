allowed_host="$(minikube ip)"

secret_bidding=659987c499b5c81688abff1dfffc21c6-be47183810f74972134ee87a1816b2f6
secret_item=659987c499b5c81688abff1dfffc21c6-be47183810f74972134ee87a1816b2f6
secret_user=659987c499b5c81688abff1dfffc21c6-be47183810f74972134ee87a1816b2f6
secret_search=659987c499b5c81688abff1dfffc21c6-be47183810f74972134ee87a1816b2f6
secret_web=659987c499b5c81688abff1dfffc21c6-be47183810f74972134ee87a1816b2f6

export service_cassandra=_cql._tcp.reactive-sandbox-cassandra.default.svc.cluster.local
export service_kafka=_broker._tcp.reactive-sandbox-kafka.default.svc.cluster.local
export service_elasticsearch=_http._tcp.reactive-sandbox-elasticsearch.default.svc.cluster.local

rp generate-kubernetes-resources biddingimpl:1.0.0-SNAPSHOT \
  --generate-pod-controllers --generate-services \
  --env JAVA_OPTS="-Dplay.http.secret.key=$secret_bidding -Dplay.filters.hosts.allowed.0=$allowed_host" \
  --pod-controller-replicas 2 \
  --external-service "cas_native=$service_cassandra" \
  --external-service "kafka_native=$service_kafka" > service-bidding.yml


rp generate-kubernetes-resources itemimpl:1.0.0-SNAPSHOT \
  --generate-pod-controllers --generate-services \
  --env JAVA_OPTS="-Dplay.http.secret.key=$secret_item -Dplay.filters.hosts.allowed.0=$allowed_host" \
  --pod-controller-replicas 2 \
  --external-service "cas_native=$service_cassandra" \
  --external-service "kafka_native=$service_kafka" > service-item.yml

# Deploy user-impl

rp generate-kubernetes-resources userimpl:1.0.0-SNAPSHOT \
  --generate-pod-controllers --generate-services \
  --env JAVA_OPTS="-Dplay.http.secret.key=$secret_user -Dplay.filters.hosts.allowed.0=$allowed_host" \
  --pod-controller-replicas 2 \
  --external-service "cas_native=$service_cassandra" \
  --external-service "kafka_native=$service_kafka" > service-user.yml

# Deploy search-impl

rp generate-kubernetes-resources searchimpl:1.0.0-SNAPSHOT \
  --generate-pod-controllers --generate-services \
  --env JAVA_OPTS="-Dplay.http.secret.key=$secret_search -Dplay.filters.hosts.allowed.0=$allowed_host" \
  --pod-controller-replicas 2 \
  --external-service "cas_native=$service_cassandra" \
  --external-service "kafka_native=$service_kafka" \
  --external-service "elastic-search=$service_elasticsearch" > service-search.yml

# Deploy webgateway

rp generate-kubernetes-resources webgateway:1.0.0-SNAPSHOT \
  --generate-pod-controllers --generate-services \
  --env JAVA_OPTS="-Dplay.http.secret.key=$secret_web -Dplay.filters.hosts.allowed.0=$allowed_host" > web-gateway.yml

  rp generate-kubernetes-resources \
  --generate-ingress --ingress-name online-auction \
  webgateway:1.0.0-SNAPSHOT \
  searchimpl:1.0.0-SNAPSHOT \
  userimpl:1.0.0-SNAPSHOT \
  itemimpl:1.0.0-SNAPSHOT \
  biddingimpl:1.0.0-SNAPSHOT > ingress.yml