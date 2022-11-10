The simplest example of KNative Event, with just a simple source and a sink

```
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-crds.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-core.yaml

kubectl apply -f event-display-sink.yaml

kubectl apply -f pingsource-source.yaml

kubectl logs --tail=25 -l app=event-display
```






