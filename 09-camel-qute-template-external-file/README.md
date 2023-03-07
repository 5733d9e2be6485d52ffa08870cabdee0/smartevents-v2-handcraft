An example to showcase how to provide qute template as external file.
## Use the RHOAS CLI to Create a Kafka Topic

```shell
rhoas kafka use --id c90o45mmk6hbcp2irvg0

# Create a topic and take note of the name
rhoas kafka topic create --name $topic_name

# Create a service account and take note of the client id and secret
rhoas service-account create

# Give permissions to your service account to produce/consume to all topics
rhoas kafka acl grant-access --producer --consumer --service-account $service_account_id --topic all --group all

# Create Source Kafka topic
export source_topic_name=inbound
rhoas kafka topic create --name $source_topic_name

# Create Sink Kafka topic
export sink_topic_name=outbound
rhoas kafka topic create --name $sink_topic_name
```

### Run application

```
mvn clean package

mvn quarkus:dev
```

## Verify the Events are flowing to Kafka

Make sure you have [kcat](https://github.com/edenhill/kcat) installed

```shell
export BOOTSTRAP_SERVER=rhose-loca-c--o--mmk-hbcp-irvga.bf2.kafka.rhcloud.com:443
export USER=<service account client id>
export PASSWORD=<service account secret>

kcat -t "$sink_topic_name" -b "$BOOTSTRAP_SERVER"   -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN   -X sasl.username="$USER"   -X sasl.password="$PASSWORD" -C

kcat -t "$source_topic_name" -b "$BOOTSTRAP_SERVER"   -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN   -X sasl.username="$USER"   -X sasl.password="$PASSWORD" -P
```

You should now see the events flow to the Kafka Topic e.g:
Send below event to `kcat` producer
```
World
```

Below output should be generated on `kcat` consumer
```
Hello World
```

In this application below template
```
Hello {body}
```