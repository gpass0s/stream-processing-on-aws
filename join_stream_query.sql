CREATE OR REPLACE STREAM "CREDIT_ONBOARDING_OUTPUT_STREAM" (dct_number VARCHAR(15),
                                                succeeded VARCHAR(4096),
                                                person_risk_information VARCHAR(4096),
                                                account_created VARCHAR(4096));
-- A ordem das colunas no select precisa manter a ordem da criação das colunas do outputstream
-- Select all columns from source stream
CREATE OR REPLACE PUMP "CREDIT_ONBOARDING_OUTPUT_STREAM_PUMP" AS
INSERT INTO "CREDIT_ONBOARDING_OUTPUT_STREAM"
SELECT STREAM tbA."dct_number", tbA."succeeded", tbB."person_risk_information", tbC."account_created"
FROM "CREDIT_ONBOARDING_INPUT_STREAM_001" OVER (RANGE INTERVAL '15' SECOND PRECEDING) AS tbA
JOIN "CREDIT_ONBOARDING_INPUT_STREAM_001" OVER (RANGE INTERVAL '15' SECOND PRECEDING) AS tbB
ON tbA."dct_number" = tbB."dct_number"
JOIN "CREDIT_ONBOARDING_INPUT_STREAM_001" OVER (RANGE INTERVAL '15' SECOND PRECEDING) AS tbC
ON tbA."dct_number" = tbC."dct_number"
WHERE   tbA."succeeded" is not null and
        tbB."person_risk_information" is not null and
        tbC."account_created" is not null