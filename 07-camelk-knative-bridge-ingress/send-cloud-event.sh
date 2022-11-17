#!/bin/sh


MESSAGE="'$(date +%H:%M:%S)'-my new message"

export CLOUD_EVENT='{
    "specversion": "1.0",
    "type": "Microsoft.Storage.BlobCreated",
    "source": "StorageService",
    "id": "9aeb0fdf-c01e-0131-0922-9eb54906e209",
    "time": "2019-11-18T15:13:39.4589254Z",
    "subject": "blobServices/default/containers/{storage-container}/blobs/{new-file}",
    "data": {
        "myMessage" : '"\"$MESSAGE\""'
    }
}'


MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

BROKER_URL="http://$MINIKUBE_IP/default/default"

echo "Sending cloud event to $BROKER_URL"

curl -v -X POST -H 'Accept: application/json' -H 'Content-Type: application/cloudevents+json' -d "$CLOUD_EVENT" "$BROKER_URL"
