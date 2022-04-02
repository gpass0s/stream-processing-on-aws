#!/usr/bin/python3.8
# -*- encoding: utf-8 -*-
"""
Created on Tue Feb 22 01:42 BRT 2022
Updated on Tue Mar 01 03:06  BRT 2022
author: https://github.com/gpass0s/
This module implements a fake data producer for the streaming process
"""
import boto3
import csv
import json
import numpy
import os
import random
import threading
import time

from faker import Faker
from dependencies.event_factory import \
    CreateAddressEvent, CreateHistoryEvent, CreateRiskAnalysisEvent


def load_clients_base(csv_path_location):
    clients_base = []  # clients data base
    with open(csv_path_location) as file:
        my_reader = csv.reader(file, delimiter=",")
        next(my_reader, None)  # skip file header
        for row in my_reader:
            client = {"ssn": row[0], "accountId": row[1], "name": row[2]}
            clients_base.append(client)

    return clients_base


def threads_controller(sns_client, sns_topic_arn, fake_data_generator, event_generators, clients_base_chunk):
    while clients_base_chunk:
        events_generation_order = random.sample(range(0, 3), 3)
        client_personal_info = clients_base_chunk.pop(0)

        while events_generation_order:
            generator_position = events_generation_order.pop(0)
            event_generator = event_generators[generator_position]
            event, message_attributes = event_generator.generate_event(fake_data_generator, client_personal_info)
            sns_client.publish(
                TargetArn=sns_topic_arn,
                Message=json.dumps(event, default=str),
                MessageAttributes=message_attributes,
                MessageStructure="string"
            )
            print(f"[INFO] Event created: {event}")
            time.sleep(random.uniform(0.5, 3.5))


def lambda_handler(event, context):
    csv_path_location = os.environ["CSV_PATH_LOCATION"]
    sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
    number_of_threads = int(os.environ["NUMBER_OF_THREADS"])  # threads simulate concurrent accesses
    aws_region = os.environ["REGION"]

    print("[INFO] Starting data producer")
    fake_data_generator = Faker()
    clients_base = load_clients_base(csv_path_location)
    print("[INFO] Client's base loaded from S3")
    clients_base_chunks = numpy.array_split(clients_base, number_of_threads)
    sns_client = boto3.client('sns', region_name=aws_region)

    event_generators = [CreateAddressEvent(), CreateRiskAnalysisEvent(), CreateHistoryEvent()]
    threads = []

    print("[INFO] Starting parallel threads")
    for i in range(number_of_threads):  # start threads
        thread = threading.Thread(target=threads_controller, args=(
            sns_client,
            sns_topic_arn,
            fake_data_generator,
            event_generators,
            clients_base_chunks[i].tolist()
        ))
        thread.start()
        print(f"[INFO] Thread {i} started")
        threads.append(thread)

    for thread in threads:
        thread.join()
