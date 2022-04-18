variable KDA_STREAM_INPUT_SCHEMA {
  type= any
  default = [
    {
      mapping = "$.ssn",
      name = "ssn",
      sql_type = "VARCHAR(16)"
    },
    {
      mapping = "$.clientAddressEvent",
      name = "clientAddressEvent",
      sql_type = "VARCHAR(1024)"
    },
    {
      mapping  = "$.clientRiskAnalysisEvent",
      name     = "clientRiskAnalysisEvent",
      sql_type = "VARCHAR(512)"
    },
    {
      mapping  = "$.clientHistoryEvent",
      name     = "clientHistoryEvent",
      sql_type = "VARCHAR(256)"
    }
  ]
}

variable KDA_REFERENCE_TABLE_SCHEMA {
  type= any
  default = [
    {
      mapping = "$.ssn",
      name = "ssn",
      sql_type = "VARCHAR(16)"
    },
    {
      mapping = "$.accountId",
      name = "accountId",
      sql_type = "VARCHAR(16)"
    },
    {
      mapping = "$.name",
      name = "name",
      sql_type = "VARCHAR(128)"
    },
    {
      mapping = "$.date_of_birth",
      name = "date_of_birth",
      sql_type = "VARCHAR(16)"
    },
    {
      mapping = "$.occupation",
      name = "occupation",
      sql_type = "VARCHAR(128)"
    },
    {
      mapping = "$.annual_income",
      name = "annual_income",
      sql_type = "DOUBLE"
    }
  ]
}
