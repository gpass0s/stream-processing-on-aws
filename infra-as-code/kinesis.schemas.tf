variable KDA_STREAM_INPUT_SCHEMA {
  type= any
  default = [
    {
      mapping = "$.ssn",
      name = "ssn",
      sql_type = "VARCHAR(32)"
    },
    {
      mapping = "$.streamProcTimestamp",
      name = "streamProcTimestamp",
      sql_type = "VARCHAR(32)"
    },
    {
      mapping = "$.clientAddressEvent",
      name = "clientAddressEvent",
      sql_type = "VARCHAR(8192)"
    },
    {
      mapping  = "$.clientRiskAnalysisEvent",
      name     = "clientRiskAnalysisEvent",
      sql_type = "VARCHAR(8192)"
    },
    {
      mapping  = "$.clientHistoryEvent",
      name     = "clientHistoryEvent",
      sql_type = "VARCHAR(8192)"
    }
  ]
}

variable KDA_REFERENCE_TABLE_SCHEMA {
  type= any
  default = [
    {
      mapping = "$.ssn",
      name = "ssn",
      sql_type = "VARCHAR(32)"
    },
    {
      mapping = "$.accountId",
      name = "accountId",
      sql_type = "VARCHAR(32)"
    },
    {
      mapping = "$.name",
      name = "name",
      sql_type = "VARCHAR(128)"
    },
    {
      mapping = "$.date_of_birth",
      name = "date_of_birth",
      sql_type = "VARCHAR(32)"
    },
    {
      mapping = "$.occupation",
      name = "occupation",
      sql_type = "VARCHAR(32)"
    },
    {
      mapping = "$.annual_income",
      name = "annual_income",
      sql_type = "VARCHAR(32)"
    }
  ]
}
