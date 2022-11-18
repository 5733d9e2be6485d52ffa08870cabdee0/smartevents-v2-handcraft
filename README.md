For macOS create the cluster in this way (otherwise the ingress won't work)

```shell
minikube  start --vm-driver=hyperkit --cpus=4 --memory=8192
```
KNative Install
```shell
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-crds.yaml

kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-core.yaml

kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.8.0/kourier.yaml

kubectl patch configmap/config-network \
--namespace knative-serving \
--type merge \
--patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-crds.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-core.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/in-memory-channel.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/mt-channel-broker.yaml
```

Kamel 

```
minikube  addons enable registry
kamel install
```

kn broker create default

kubectl apply -f config-br-defaults.yaml

kubectl apply -f imc-channel.yaml

kubectl apply -f camel-knative.yaml

```
minikube  addons enable ingress
minikube  addons enable ingress-dns
``` 