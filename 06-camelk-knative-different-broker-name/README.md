A very basic example of an installation of KNative event using the InMemory channel 
with a simple Kamel integration using default namespace and a different broker name
trying to get every kind of event from the broker
This is identical to 05-camelk-native-from-without-filtering but with a name for the broker 
Check the trigger created and you'll see there's no filtering

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

kubectl apply -f pingsource-source.yaml

kubectl apply -f camel-knative.yaml


```


