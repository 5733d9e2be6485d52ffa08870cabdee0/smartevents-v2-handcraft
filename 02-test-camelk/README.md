A very basic example of an installation of KNative event using the InMemory channel with broker with the default name
First part is [Installing KNative event](https://knative.dev/docs/install/yaml-install/eventing/install-eventing-with-yaml) and [Creating a PingSource source](https://knative.dev/docs/eventing/sources/ping-source)

minikube addons enable registry

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-crds.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-core.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/in-memory-channel.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/mt-channel-broker.yaml

kamel install --global --force

kubectl apply -f config-br-defaults.yaml

kubectl apply -f imc-channel.yaml

kubectl create namespace test-camelk

kubectl apply -f broker.yaml

kubectl apply -f pingsource-source.yaml

kubectl apply -f camel-knative.yaml

kubectl -n test-camelk logs --tail=25 -l app=event-display



kubectl delete pingsources.sources.knative.dev ping-source-inmemory -n test-camelk

kubectl delete service.serving.knative.dev


