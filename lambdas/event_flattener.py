#!/usr/bin/python3.8
# -*- encoding: utf-8 -*-
"""
Created on Wed Mar 23 03:16 BRT 2022
Updated on Fri Mar 25 16:06 BRT 2022
author: https://github.com/gpass0s/
This module flattens all schema events
"""
import boto3
import datetime
import json
import os


_kds_client = boto3.client('kinesis')
_kds_name = os.environ["KDS_NAME"]


def lambda_handler(event, context):
    """
        Lambda method that is invoked by SQS
        :param event: message from SQS
        :param context:
    """
    print(f"[INFO] Event received: {event}")

    for record in event['Records']:
        # load event
        body = json.loads(record['body'])
        event = json.loads(body['Message'])

        # extract key field
        event_name = event["eventName"]
        ssn = str(event["data"]["ssn"])

        # create event name field
        event_name_field = \
            "".join([w.title() if w != event_name.split("_")[0] else w for w in event_name.split("_")]) + "Event"

        # flatten and standardize event schema
        flattened_event = {
            "ssn": ssn,
            event_name_field: json.dumps(event)
        }

        # send the new event to kinesis data stream
        _kds_client.put_record(StreamName=_kds_name, Data=json.dumps(flattened_event), PartitionKey="1")
        print(f"[INFO] Event successfully sent to kinesis data stream")
