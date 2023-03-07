An example to showcase event transformation using NS actual template.
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

export sink_topic_name2=outbound
rhoas kafka topic create --name $sink_topic_name2
```

## Setup your Kube install

```
minikube start --driver=docker

# Enable registry
minikube addons enable registry

# Install CamelK
kamel install

kubectl apply -f integration.yaml

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
{
    "specversion": "1.0",
    "id": "O234-345-890",
    "source": "https://reactive-coffee-shop.io/1234/order",
    "type": "me.escoffier.coffee.Order",
    "subject": "order",
    "time": "2020-11-25T09:05:00Z",
    "datacontenttype": "application/json",
    "data": {
        "version": "1.0.0",
        "id": "be2bf55d-52bf-4042-93bf-814f9bd915c5",
        "environment_url": "http://100.0.0.0//api/integrations/v1.0/endpoints",
        "bundle": "console",
        "application": "integrations",
        "context": {
            "display_name": "ConsoleIntegration",
            "inventory_id": "1"
        },
        "events": [{
            "metadata": {
                "test-metadata-key": "test-metadata-value"
            },
            "payload": {
                "test-payload-key": "test-payload-value"
            }
        }]
    },
    "custom-attribute": "some custom value"
}
```
In line version
```
{"specversion":"1.0","id":"O234-345-890","source":"https://reactive-coffee-shop.io/1234/order","type":"me.escoffier.coffee.Order","subject":"order","time":"2020-11-25T09:05:00Z","datacontenttype":"application/json","data":{"version":"1.0.0","id":"be2bf55d-52bf-4042-93bf-814f9bd915c5","environment_url":"http://100.0.0.0//api/integrations/v1.0/endpoints","bundle":"console","application":"integrations","context":{"display_name":"ConsoleIntegration","inventory_id":"1"},"events":[{"metadata":{"test-metadata-key":"test-metadata-value"},"payload":{"test-payload-key":"test-payload-value"}}]},"custom-attribute":"some custom value"}
```

Below output should be generated on `kcat` consumer
```
<http://100.0.0.0//api/integrations/v1.0/endpoints/insights/inventory/1|ConsoleIntegration> triggered 1 event from console/integrations. <http://100.0.0.0//api/integrations/v1.0/endpoints/insights/integrations|Open integrations>
```

In this application below NS template has been used
```
{#if body.data.context.display_name??}
<{body.data.environment_url}{#if body.data.bundle == "openshift" and body.data.application == "advisor"}/openshift/insights/advisor/clusters/{body.data.context.display_name}{#else}/insights/inventory/{#if body.data.context.inventory_id??}{body.data.context.inventory_id}{#else}?hostname_or_id={body.data.context.display_name}{/if}{/if}|{body.data.context.display_name}> triggered {body.data.events.size()} event{#if body.data.events.size() > 1}s{/if}{#else}
{body.data.events.size()} event{#if body.data.events.size() > 1}s{/if} triggered{/if} from {body.data.bundle}/{body.data.application}. <{body.data.environment_url}/{#if body.data.bundle == "application-services" and body.data.application == "rhosak"}application-services/streams{#else}{#if body.data.bundle == "openshift"}openshift/{/if}insights/{body.data.application}{/if}|Open {body.data.application}>
```