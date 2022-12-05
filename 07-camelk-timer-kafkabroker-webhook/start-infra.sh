#!/bin/sh

# Knative operator doesn't work properly with Docker driver that why I started minikube with Podman
minikube start --driver=docker  --cpus 4 --memory 15g

# Enable registry
minikube addons enable registry

# Setup Knative Serving
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-core.yaml
while [[ $(kubectl get pods -l app=controller -n knative-serving -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for Knative Serving Controller" && sleep 1; done

# Setup Knative Eventing
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-crds.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-core.yaml
while [[ $(kubectl get pods -l app=eventing-controller -n knative-eventing -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for Knative Eventing Controller" && sleep 1; done

# Setup Kourier gateway
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.8.0/kourier.yaml
while [[ $(kubectl get pods -l app=3scale-kourier-gateway -n kourier-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for Kourier gateway" && sleep 1; done

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'


# Enable Knative Kafka Broker
kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.8.2/eventing-kafka-controller.yaml
kubectl apply --filename https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.8.2/eventing-kafka-broker.yaml
while [[ $(kubectl get pods -l app=kafka-controller -n knative-eventing -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for Knative Kafka Controller" && sleep 1; done

kubectl create ns smart-events

kamel install -n smart-events

# Create Smart Event Knative Kafka Broker

kubectl apply -f smart-events-kafka-broker.yaml

kubectl apply -f timed-greeter-kamelet.yaml
while [[ $(kubectl get kamelets.camel.apache.org timed-greeter -n smart-events -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for 'timed-greeter' kamelet to ready" && sleep 1; done

kubectl apply -f timed-greeter-binding.yaml
while [[ $(kubectl get kameletbindings.camel.apache.org timed-greeter-binding-knative-broker -n smart-events -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for 'timed-greeter-binding-knative-broker' kamelet binding to be ready" && sleep 1; done

# Update kafka Connection details and Webhook URI into kafka-source-binding.yaml

kubectl apply -f kafka-source-binding.yaml
while [[ $(kubectl get kameletbindings.camel.apache.org kafka-source-binding -n smart-events -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for 'kafka-source-binding' kamelet binding to be ready" && sleep 1; done


echo "Setup Completed..."