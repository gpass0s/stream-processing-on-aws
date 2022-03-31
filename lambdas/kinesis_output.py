#!/usr/bin/python3.8
# -*- encoding: utf-8 -*-
"""
Created on Wed Mar 31 02:11 BRT 2022
author: https://github.com/gpass0s/
This module prints the kinesis data analytics output
"""
import json


def lambda_handler(event, context):

    for record in event['Records']:
        # load event
        body = json.loads(record['body'])
        event = json.loads(body['Message'])
        print(f"[INFO] Aggregated event: {event}")
