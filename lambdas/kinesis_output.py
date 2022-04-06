#!/usr/bin/python3.8
# -*- encoding: utf-8 -*-
"""
Created on Wed Mar 31 02:11 BRT 2022
author: https://github.com/gpass0s/
This module prints the kinesis data analytics output
"""
import json
import base64


def lambda_handler(event, context):

    for record in event['Records']:
        # load event
        body = record["kinesis"]
        encrypted_data = body["data"]
        event = base64.b64decode(encrypted_data).decode("utf-8")
        print(f"[INFO] Aggregated event: {event}")
