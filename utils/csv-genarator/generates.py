#!/usr/bin/python3.8
# -*- encoding: utf-8 -*-
"""
Created on Tue Feb 16 01:45 BRT 2022
author: https://github.com/gpass0s/
This generates the csv reference table
"""
import pandas as pd
import random

from faker import Faker

if __name__ == "__main__":
    fake = Faker()
    reference_table_list = []
    for i in range(9999):
        row_dict = {}
        row_dict["ssn"] = str(fake.ssn())
        row_dict["name"] = fake.name()
        row_dict["date_of_birth"] = str(fake.date_of_birth().strftime("%Y-%m-%d"))
        row_dict["occupation"] = fake.job().strip('"')
        row_dict["annual_income"] = round(random.uniform(40000,110000),2)
        reference_table_list.append(row_dict)

    reference_table_df = pd.DataFrame(reference_table_list)
    reference_table_df.to_csv("../clients_annual_income.csv", index=False)
