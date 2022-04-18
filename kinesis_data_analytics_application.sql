CREATE OR REPLACE STREAM "INTERMEDIARY_STREAM" (
    ssn VARCHAR(16),
    clientAddressEvent VARCHAR(1024),
    clientRiskAnalysisEvent VARCHAR(512),
    clientHistoryEvent VARCHAR(256)
);
CREATE OR REPLACE STREAM "OUTPUT_STREAM" (
    ssn VARCHAR(16),
    clientAddressEvent VARCHAR(1024),
    clientRiskAnalysisEvent VARCHAR(512),
    clientHistoryEvent VARCHAR(256),
    date_of_birth VARCHAR(16),
    occupation VARCHAR(128),
    annual_income DOUBLE
);

CREATE OR REPLACE PUMP "INTERMEDIARY_STREAM_PUMP" AS
INSERT INTO "INTERMEDIARY_STREAM"
SELECT
    STREAM eventA."ssn",
    eventA."clientAddressEvent",
    eventB."clientRiskAnalysisEvent",
    eventC."clientHistoryEvent"
FROM "INPUT_STREAM_001" OVER (RANGE INTERVAL '15' SECOND PRECEDING) AS eventA
JOIN "INPUT_STREAM_001" OVER (RANGE INTERVAL '15' SECOND PRECEDING) AS eventB
ON eventA."ssn" = eventB."ssn"
JOIN "INPUT_STREAM_001" OVER (RANGE INTERVAL '15' SECOND PRECEDING) AS eventC
ON eventA."ssn" = eventC."ssn"
WHERE eventA."clientAddressEvent" is not null and
      eventB."clientRiskAnalysisEvent" is not null and
      eventC."clientHistoryEvent" is not null;


CREATE OR REPLACE PUMP "OUTPUT_STREAM_PUMP" AS
INSERT INTO "OUTPUT_STREAM"
SELECT
    STREAM tableA."SSN",
    tableA."CLIENTADDRESSEVENT",
    tableA."CLIENTRISKANALYSISEVENT",
    tableA."CLIENTHISTORYEVENT",
    refTable."date_of_birth",
    refTable."occupation",
    refTable."annual_income"
FROM "INTERMEDIARY_STREAM" AS tableA
JOIN "REFERENCE_TABLE" AS refTable
ON tableA."SSN" = refTable."ssn"
