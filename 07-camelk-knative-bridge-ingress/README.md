A very basic example of an installation of KNative event using the InMemory channel 
with a simple Kamel integration using everything in default (namespace and broker name)
trying to get every kind of event from the broker
Instead of having a PingSource source we accept CloudEvents from the HTTP Broker

```

minikube  start --vm-driver=hyperkit --cpus=4 --memory=8192

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

minikube  addons enable registry
kamel install

kn broker create default

kubectl apply -f config-br-defaults.yaml

kubectl apply -f imc-channel.yaml

kubectl apply -f pingsource-source.yaml

kubectl apply -f camel-knative.yaml


minikube  addons enable ingress 
minikube  addons enable ingress-dns 

kubectl apply -f ingress.yaml


```


