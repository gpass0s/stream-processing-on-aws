#!/usr/bin/python3.8
# -*- encoding: utf-8 -*-
"""
Created on Tue Mar 24 03:16 BRT 2022
author: https://github.com/gpass0s/
This module flattens all schema events
"""
import boto3
import datetime
import json
import os


kinesis_client = boto3.client('kinesis')


def flatten_event_schema(event, ssn, account_id, event_name_field):

    event_name_fields = {
        "clientAddress": None,
        "clientRiskAnalysis": None,
        "clientHistory": None
    }
    kda_schema_event = {
        "ssn": ssn,
        "accountId": account_id,
        "streamProcTimestamp": datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3],
        event_name_field: json.dumps(event)
    }

    del event_name_fields[event_name_field]

    for key in event_name_fields:
        kda_schema_event[key] = ""

    print(f"[INFO] Event flattened: {kda_schema_event}")
    return kda_schema_event


def send_event_to_kds(data, kds_name):

    print(f"[INFO] Sending event to KDS")

    try:
        kinesis_client.put_record(
            StreamName=kds_name,
            Data=json.dumps(data),
            PartitionKey='1')
    except Exception as e:
        print("[ERROR]:", e)


def lambda_handler(event, context):
    """
    Lambda method that is invoked by SQS
    :param event: message from SQS
    :param context:
    """
    print(f"[INFO] Event received: {event}")
    kds_name = os.environ["KDS_NAME"]

    for record in event['Records']:

        body = json.loads(record['body'])
        event = json.loads(body['Message'])

        event_name = event["eventName"]
        ssn = str(event["data"]["ssn"])
        try:
            account_id = str(event["data"]["accountId"])
        except KeyError:
            account_id = ""

        event_name_field = "".join([w.title() if w != event_name.split("_")[0] else w for w in event_name.split("_")])

        flattened_event = flatten_event_schema(event, ssn, account_id, event_name_field)
        send_event_to_kds(flattened_event, kds_name)
