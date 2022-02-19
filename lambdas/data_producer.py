#!/usr/bin/python3.8
# -*- encoding: utf-8 -*-
"""
Created on Thu Feb 17 01:45 BRT 2022
author: https://github.com/gpass0s/
This module implements a data producer for the streaming process
"""
import boto3
import csv
import datetime
import json
import os
import random
import time

from faker import Faker


def load_clients_base(csv_path_location):
    clients_base = []  # clients data base
    with open(csv_path_location) as file:
        my_reader = csv.reader(file, delimiter=",")
        next(my_reader, None)  # skip file header
        for row in my_reader:
            client = {"ssn": row[0], "accountId": row[1], "name": row[2]}
            clients_base.append(client)

    return clients_base


def create_client_address_event(fake_data_generator, document_number, client_personal_info):
    event = {}
    data = {}

    fake_hash = f"{fake_data_generator.hexify()}{fake_data_generator.hexify()}{fake_data_generator.hexify()}"
    event["event_id"] = fake_hash
    event["timestamp"] = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
    event["eventName"] = "client_address"

    data["documentNumber"] = document_number
    data["clientName"] = client_personal_info["name"]
    data["accountId"] = client_personal_info["accountId"]

    number_of_addresses_distribution = [1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3]
    number_of_addresses = number_of_addresses_distribution[random.randint(0, 10)]
    addresses = []
    for i in range(number_of_addresses):
        address = {}
        address["country"] = "US"
        state_abbr = fake_data_generator.state_abbr()
        address["street"] = fake_data_generator.address().split("\n")[0]
        address["city"] = fake_data_generator.city()
        address["zip_code"] = fake_data_generator.zipcode_in_state(state_abbr)
        address["state"] = state_abbr
        addresses.append(address)

    data["addresses"] = addresses
    event["data"] = data

    return event


def create_client_risk_analysis_event(fake_data_generator, document_number, client_personal_info):
    event = {}
    data = {}

    fake_hash = f"{fake_data_generator.hexify()}{fake_data_generator.hexify()}{fake_data_generator.hexify()}"
    event["event_id"] = fake_hash
    event["timestamp"] = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
    event["eventName"] = "client_risk_analysis"

    data["ssn"] = client_personal_info["ssn"]
    data["documentNumber"] = document_number
    data["yearMonthReference"] = datetime.now().strftime("%Y%m")
    risk_origin_distribution = ["M", "M", "M", "M", "N", "N", "N", "L", "O", "P"]
    data["riskOrigin"] = risk_origin_distribution[random.randint(0, 9)]
    data["riskModality"] = random.randint(1300, 1320)
    data["financialInstitutionRisk"] = random.randint(600, 650)
    data["judicialCaseQuantity"] = random.randint(0, 9)
    origin_distribution = ["internal", "internal", "internal", "external"]
    data["checkOrigin"] = origin_distribution[random.randint(0, 3)]
    data["totalOverDueCredit"] = round(random.uniform(0, 10000), 2)
    data["riskScore"] = round(random.uniform(0, 0.99), 4)

    event["data"] = data

    return event


def create_client_history(fake_data_generator, document_number):
    event = {}
    data = {}

    fake_hash = f"{fake_data_generator.hexify()}{fake_data_generator.hexify()}{fake_data_generator.hexify()}"
    event["event_id"] = fake_hash
    event["timestamp"] = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
    event["eventName"] = "client_history"

    data["documentNumber"] = document_number
    creation_date = fake_data_generator.date_between_dates(
        datetime.date(2019, 1, 1),
        datetime.date.today()
    )
    data["creation"] = creation_date.strftime("%Y-%m-%d")
    data["access"] = random.randint(1, 500)
    data["currentBalance"] = round(random.uniform(0, 10000), 2)
    data["lastAccessDate"] = fake_data_generator.date_between_dates(
        creation_date,
        datetime.date.today()
    ).strftime("%Y-%m-%d")

    event["data"] = data

    return event


def find_a_non_taken_client_position(
        client_positions_already_taken,
        client_position_lower_limit,
        client_position_upper_limit
):
    while True:  # While loop to find a non chosen client position
        client_position = random.randint(client_position_lower_limit, client_position_upper_limit)
        try:
            client_positions_already_taken[client_position]
        except KeyError:
            break
    client_positions_already_taken[client_position] = True
    return client_position


def lambda_handler(event, context):

    csv_path_location = os.environ["CSV_PATH_LOCATION"]
    client_position_lower_limit = int(os.environ["CLIENTS_BASE_LOWER_LIMIT"])
    client_position_upper_limit = int(os.environ["CLIENTS_BASE_UPPER_LIMIT"])
    sns_topic_arn = os.environ["SNS_TOPIC_ARN"]

    fake_data_generator = Faker()
    clients_base = load_clients_base(csv_path_location)
    sns_client = boto3.client('sns', region="us-east-1")
    client_positions_already_taken = {}

    while True: # While loop to generate events indefinitely

        client_position = find_a_non_taken_client_position(
            client_positions_already_taken,
            client_position_lower_limit,
            client_position_upper_limit
        )
        client_personal_info = clients_base[client_position]
        document_number = random.randint(pow(10, 6), (pow(10, 7) - 1))
        
    client_address_event = create_client_address_event(
        fake_data_generator,
        document_number,
        client
    )

    response = sns_client.publish(
        TargetArn=sns_topic_arn,
        Message=json.dumps({"default": json.dumps(client_address_event)}),
        MessageStructure="json"
    )
    client_risk_analysis_event = create_client_risk_analysis_event(
        fake_data_generator,
        document_number,
        client
    )
    client_history_event = create_client_history(
        fake_data_generator,
        document_number
    )


