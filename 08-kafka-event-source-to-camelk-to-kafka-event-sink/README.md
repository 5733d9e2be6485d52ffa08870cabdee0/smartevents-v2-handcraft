Demonstrates using a `KafkaSource`, a `Broker`, a Camel-K `Integration` and finally a `KafkaSink` to process events
using Knative and Camel-K

## Use the RHOAS CLI to Create a Source and Sink Kafka Topic

```shell
rhoas kafka use --id c90o45mmk6hbcp2irvg0

# Create a source and sink topic and take note of the names
rhoas kafka topic create --name $source_topic_name
rhoas kafka topic create --name $sink_topic_name

# Create a service account and take note of the client id and secret
rhoas service-account create

# Give permissions to your service account to produce/consume to all topics
rhoas kafka acl grant-access --producer --consumer --service-account $service_account_id --topic all --group all

# Give permissions to your service account to create consumer groups
rhoas kafka acl create --group "*" --operation "all" --permission "allow" --user $service_account_id
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

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/in-memory-channel.yaml

kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.8.0/mt-channel-broker.yaml

kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.8.0/eventing-kafka-controller.yaml

kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.8.0/eventing-kafka-sink.yaml

kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/knative-v1.8.0/eventing-kafka-source.yaml

# Make sure all pods become Ready (can take minute or so)
kubectl get pods -n knative-eventing

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

# Change the name of the topic in the `KafkaSink` configuration to the sink topic you created

kubectl apply -f kafka-sink.yaml

# Ensure that the Kafka Sink is exposed via a URL

kubectl get kafkasink

# Change the name of the topic in the `KafkaSource` configuration to the source topic you created
kubectl apply -f kafka-source.yaml

# Ensure that the Kafka Source is exposed via a URL

kubectl get kafkasource

# Apply the Integration
kubectl apply -f camel-knative.yaml
```

## Produce events to your source topic

Make sure you have [kcat](https://github.com/edenhill/kcat) installed

```shell
export BOOTSTRAP_SERVER=rhose-loca-c--o--mmk-hbcp-irvga.bf2.kafka.rhcloud.com:443
export USER=<service account client id>
export PASSWORD=<service account secret>
export SOURCE_KAFKA_TOPIC=<source_kafka_topic>

kcat -t "$SOURCE_KAFKA_TOPIC" -b "$BOOTSTRAP_SERVER"   -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN   -X sasl.username="$USER"   -X sasl.password="$PASSWORD" -p

{"message":"hello world from producer"}

CTRL-D to send
```

## Verify the Events are flowing to Kafka

Make sure you have [kcat](https://github.com/edenhill/kcat) installed

```shell
export BOOTSTRAP_SERVER=rhose-loca-c--o--mmk-hbcp-irvga.bf2.kafka.rhcloud.com:443
export USER=<service account client id>
export PASSWORD=<service account secret>
export SINK_KAFKA_TOPIC=<sink_kafka_topic>

kcat -t "$SINK_KAFKA_TOPIC" -b "$BOOTSTRAP_SERVER"   -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN   -X sasl.username="$USER"   -X sasl.password="$PASSWORD" -C
```

You should now see the events flow to the Kafka Topic e.g:

```shell
{"message":"hello world from producer"}
```


