A very basic example of an installation of KNative event using the InMemory channel 
with a simple Kamel integration usin everything in default (namespace and broker name)

```
minikube addons enable registry

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

kamel install

kubectl apply -f config-br-defaults.yaml

kubectl apply -f imc-channel.yaml

kubectl apply -f broker.yaml

kubectl apply -f camel-knative.yaml

kubectl apply -f event-display-sink.yaml

kubectl apply -f trigger.yaml

kubectl logs --tail=25 -l app=event-display
```


