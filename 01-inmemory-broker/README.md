A very basic example of an installation of KNative event using the InMemory channel with brokers
First part is [Installing KNative event](https://knative.dev/docs/install/yaml-install/eventing/install-eventing-with-yaml) and [Creating a PingSource source](https://knative.dev/docs/eventing/sources/ping-source)
The In Memory broker is very important as it's the base for a quick developer experience based on a sandbox
that lets our user test the Camel DSL content quickly

```
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-crds.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-core.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/in-memory-channel.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/mt-channel-broker.yaml

kubectl apply -f config-br-defaults.yaml

kubectl apply -f imc-channel.yaml

kubectl apply -f broker.yaml

kubectl apply -f event-display-sink.yaml

kubectl apply -f trigger.yaml

kubectl apply -f pingsource-source.yaml

kubectl logs --tail=25 -l app=event-display


kubectl delete pingsources.sources.knative.dev ping-source-inmemory 

kubectl delete service.serving.knative.dev
```

