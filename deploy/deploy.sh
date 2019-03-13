kubectl apply -f service-bidding.yml
kubectl apply -f service-item.yml
kubectl apply -f service-search.yml
kubectl apply -f service-user.yml
kubectl apply -f web-gateway.yml

kubectl apply -f ingress.yml
kubectl apply -f rbac.yml