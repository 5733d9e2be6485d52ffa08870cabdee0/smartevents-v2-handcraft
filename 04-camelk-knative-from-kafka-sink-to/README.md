A very basic example of an installation of KNative event using the InMemory channel
with a simple Kamel integration using everything in default (namespace and broker name)

## Use the RHOAS CLI to Create a Kafka Topic

```shell
rhoas kafka use --id c90o45mmk6hbcp2irvg0

# Create a topic and take note of the name
rhoas kafka topic create --name $topic_name

# Create a service account and take note of the client id and secret
rhoas service-account create

# Give permissions to your service account to produce/consume to all topics
rhoas kafka acl grant-access --producer --consumer --service-account $service_account_id --topic all --group all
```

## Setup your Kube install

```
minikube addons enable registry

kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-crds.yaml

kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-core.yaml

# Make sure all pods become Ready (can take minute or so)
kubectl get pods -n knative-serving

kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.8.0/kourier.yaml

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
  
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-crds.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/eventing-core.yaml

# Make sure all pods become Ready (can take minute or so)
kubectl get pods -n knative-eventing

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/in-memory-channel.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/mt-channel-broker.yaml

kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.8.0/eventing-kafka-controller.yaml

kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.8.0/eventing-kafka-sink.yaml

kamel install

kubectl apply -f config-br-defaults.yaml

kubectl apply -f imc-channel.yaml

kubectl apply -f broker.yaml

# Ensure the broker has a valid URL
kubectl get broker default 

# Create the secret to connect to the Kafka Cluster
# Replace <my_user> with the Service Account client id
# Replace <my_password> with the Service Account secret

kubectl create secret --namespace default generic kafka-sink-auth \
  --from-literal=protocol=SASL_SSL \
  --from-literal=sasl.mechanism=PLAIN \
  --from-literal=user=<my_user> \
  --from-literal=password=<my_password>

# Change the name of the topic in the KafkaSink configuration to the one you created

kubectl apply -f kafka-sink.yaml

# Ensure that the Kafka Sink is exposed via a URL

kubectl get kafkasink

kubectl apply -f pingsource-source.yaml

kubectl apply -f camel-knative.yaml
```

## Verify the Events are flowing to Kafka

Make sure you have [kcat](https://github.com/edenhill/kcat) installed

```shell
export BOOTSTRAP_SERVER=rhose-loca-c--o--mmk-hbcp-irvga.bf2.kafka.rhcloud.com:443
export USER=<service account client id>
export PASSWORD=<service account secret>
export KAFKA_TOPIC=<kafka_topic>

kcat -t "$KAFKA_TOPIC" -b "$BOOTSTRAP_SERVER"   -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN   -X sasl.username="$USER"   -X sasl.password="$PASSWORD" -C
```

You should now see the events flow to the Kafka Topic e.g:

```shell
{"message":"Hello world!"}
{"message":"Hello world!"}
{"message":"Hello world!"}
{"message":"Hello world!"}
{"message":"Hello world!"}
% Reached end of topic rblake-testing [0] at offset 4100
```


