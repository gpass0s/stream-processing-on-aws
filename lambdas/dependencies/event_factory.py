#!/usr/bin/python3.8
# -*- encoding: utf-8 -*-
"""
Created on Tue Feb 22 01:42 BRT 2022
Updated on Tue Mar 01 02:25  BRT 2022
author: https://github.com/gpass0s/
This module implements an event factory
"""
import random
import datetime

from abc import ABC, abstractmethod
from faker import Faker


class EventFactory(ABC):

    @abstractmethod
    def generate_event(
            self,
            fake_data_generator: Faker,
            client_personal_info: dict
    ) -> dict:
        pass


class CreateAddressEvent(EventFactory):

    def generate_event(
            self,
            fake_data_generator: Faker,
            client_personal_info: dict
    ) -> dict:
        event = {}
        data = {}

        fake_hash = f"{fake_data_generator.hexify()}{fake_data_generator.hexify()}{fake_data_generator.hexify()}"
        event["eventId"] = fake_hash
        timestamp = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]
        event["timestamp"] = timestamp
        event["eventName"] = "client_address"

        data["ssn"] = client_personal_info["ssn"]
        data["clientName"] = client_personal_info["name"]
        data["accountId"] = client_personal_info["accountId"]

        number_of_addresses_distribution = [1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3]
        number_of_addresses = number_of_addresses_distribution[random.randint(0, 10)]
        addresses = []
        for i in range(number_of_addresses):
            address = {"country": "US"}
            state_abbr = fake_data_generator.state_abbr()
            address["street"] = fake_data_generator.address().split("\n")[0]
            address["city"] = fake_data_generator.city()
            address["zip_code"] = fake_data_generator.zipcode_in_state(state_abbr)
            address["state"] = state_abbr
            addresses.append(address)

        data["addresses"] = addresses
        event["data"] = data

        message_attributes = {
            "eventId": {
                "StringValue": fake_hash,
                "DataType": "String"
            },
            "timestamp": {
                "StringValue": timestamp,
                "DataType": "String"
            },
            "eventName": {
                "StringValue": "client_address",
                "DataType": "String"
            }
        }

        return event, message_attributes


class CreateRiskAnalysisEvent(EventFactory):

    def generate_event(
            self,
            fake_data_generator: Faker,
            client_personal_info: dict
    ) -> dict:
        event = {}
        data = {}

        fake_hash = f"{fake_data_generator.hexify()}{fake_data_generator.hexify()}{fake_data_generator.hexify()}"
        event["eventId"] = fake_hash
        timestamp = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]
        event["timestamp"] = timestamp
        event["eventName"] = "client_risk_analysis"

        data["ssn"] = client_personal_info["ssn"]
        data["yearMonthReference"] = datetime.datetime.now().strftime("%Y%m")
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

        message_attributes = {
            "eventId": {
                "StringValue": fake_hash,
                "DataType": "String"
            },
            "timestamp": {
                "StringValue": timestamp,
                "DataType": "String"
            },
            "eventName": {
                "StringValue": "client_risk_analysis",
                "DataType": "String"
            }
        }

        return event, message_attributes


class CreateHistoryEvent(EventFactory):

    def generate_event(
            self,
            fake_data_generator: Faker,
            client_personal_info: dict
    ) -> dict:
        event = {}
        data = {}

        fake_hash = f"{fake_data_generator.hexify()}{fake_data_generator.hexify()}{fake_data_generator.hexify()}"
        event["eventId"] = fake_hash
        timestamp = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]
        event["timestamp"] = timestamp
        event["eventName"] = "client_history"

        data["ssn"] = client_personal_info["ssn"]
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

        message_attributes = {
            "eventId": {
                "StringValue": fake_hash,
                "DataType": "String"
            },
            "timestamp": {
                "StringValue": timestamp,
                "DataType": "String"
            },
            "eventName": {
                "StringValue": "client_history",
                "DataType": "String"
            }
        }

        return event
