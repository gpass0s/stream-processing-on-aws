#!/usr/bin/python3.8
# -*- encoding: utf-8 -*-
"""
Created on Tue Feb 22 01:42 BRT 2022
author: https://github.com/gpass0s/
This module implements a data producer for the streaming process
"""
import boto3
import csv
import json
import os
import random
import time

from faker import Faker
from dependencies.event_factory import \
    EventFactory, CreateAddressEvent, CreateHistoryEvent, CreateRiskAnalysisEvent


def load_clients_base(csv_path_location):
    clients_base = []  # clients data base
    with open(csv_path_location) as file:
        my_reader = csv.reader(file, delimiter=",")
        next(my_reader, None)  # skip file header
        for row in my_reader:
            client = {"ssn": row[0], "accountId": row[1], "name": row[2]}
            clients_base.append(client)

    return clients_base


def find_a_non_taken_number(
        taken_numbers,
        lower_limit,
        upper_limit
):
    while True:  # While loop to find a non chosen client position
        number = random.randint(lower_limit, upper_limit)
        try:
            taken_numbers[number]
        except KeyError:
            break
    taken_numbers[number] = True
    return number


def lambda_handler(event, context):
    csv_path_location = os.environ["CSV_PATH_LOCATION"]
    client_position_lower_limit = int(os.environ["CLIENTS_BASE_LOWER_LIMIT"])
    client_position_upper_limit = int(os.environ["CLIENTS_BASE_UPPER_LIMIT"])
    sns_topic_arn = os.environ["SNS_TOPIC_ARN"]

    fake_data_generator = Faker()
    clients_base = load_clients_base(csv_path_location)
    sns_client = boto3.client('sns', region="us-east-1")
    client_positions_already_taken = {}

    event_generators = [
        CreateAddressEvent(),
        CreateRiskAnalysisEvent(),
        CreateHistoryEvent(),
    ]

    while True:  # While loop to generate events indefinitely
        client_position = find_a_non_taken_number(
            client_positions_already_taken,
            client_position_lower_limit,
            client_position_upper_limit
        )

        client_personal_info = clients_base[client_position]
        document_number = str(random.randint(pow(10, 6), (pow(10, 7) - 1)))
        taken_generators = {}

        while True:  # While loop to create events randomly
            generator_position = find_a_non_taken_number(taken_generators, 0, 2)
            event_generator = event_generators[generator_position]
            # generates an event in factory
            event = event_generator.generate_event(
                fake_data_generator,
                document_number,
                client_personal_info
            )
            # publishes message in SNS
            sns_client.publish(
                TargetArn=sns_topic_arn,
                Message=json.dumps({"default": json.dumps(event)}),
                MessageStructure="json"
            )
            time.sleep(random.uniform(0.5, 3.5))
            if len(taken_generators) > 2:
                break

        if len(client_positions_already_taken) >= client_position_upper_limit - client_position_upper_limit:
            break
