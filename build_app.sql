-- ============================================================================
-- NATIVE APP: CUSTOMER_REVERSE_APP
-- Complete End-to-End Script (Using Data Shares - No Data Replication)
-- Contains: REVERSE_STRING JavaScript UDF + CUST_WITH_JS_UDF Secure View
-- Contains: REVERSE_STRING_PYTHON UDF (Python version of the UDF)
-- ============================================================================


-- ============================================================================
-- STEP 1: CREATE APPLICATION PACKAGE
-- ============================================================================
CREATE APPLICATION PACKAGE IF NOT EXISTS CUSTOMER_REVERSE_APP_PKG;

-- ============================================================================
-- STEP 2: CREATE STAGE FOR APP FILES
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT;

CREATE OR REPLACE STAGE CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT.APP_STAGE;

-- ============================================================================
-- STEP 4: UPLOAD app config files to stage : APP_STAGE (can use Snowsight UI as well)
-- ============================================================================

-- PUT file:///Users/.../manifest.yml @CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT.APP_STAGE; 
-- PUT file:///Users/.../setup.sql @CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT.APP_STAGE;


-- ============================================================================
-- STEP 5: GRANT REFERENCE_USAGE ON SOURCE DATABASE (Data Share - No Copy)
-- ============================================================================
GRANT REFERENCE_USAGE ON DATABASE DELETETHIS 
    TO SHARE IN APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG;

-- ============================================================================
-- STEP 5: CREATE SHARED DATA SCHEMA WITH VIEW (References Live Data)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS CUSTOMER_REVERSE_APP_PKG.SHARED_DATA;

CREATE OR REPLACE SECURE VIEW CUSTOMER_REVERSE_APP_PKG.SHARED_DATA.CUSTOMERS AS
SELECT * FROM YOURDB.PUBLIC.CUSTOMERS;  -- < CHANGE THIS TO YOUR DATABASE AND TABLE

GRANT USAGE ON SCHEMA CUSTOMER_REVERSE_APP_PKG.SHARED_DATA 
    TO SHARE IN APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG;

GRANT SELECT ON VIEW CUSTOMER_REVERSE_APP_PKG.SHARED_DATA.CUSTOMERS 
    TO SHARE IN APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG;


-- ============================================================================
-- STEP 6: VERIFY STAGE FILES
-- ============================================================================
LIST @CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT.APP_STAGE;

-- ============================================================================
-- STEP 7: REGISTER VERSION
-- ============================================================================
ALTER APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG
    REGISTER VERSION V1
    USING '@CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT.APP_STAGE';

-- ============================================================================
-- STEP 8: CONFIGURE RELEASE CHANNEL FOR LISTING
-- ============================================================================
ALTER APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG
    MODIFY RELEASE CHANNEL DEFAULT
    ADD VERSION V1;

ALTER APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG
    MODIFY RELEASE CHANNEL DEFAULT
    SET DEFAULT RELEASE DIRECTIVE
    VERSION = V1
    PATCH = 0;

-- ============================================================================
-- STEP 9: CREATE THE APPLICATION (for testing)
-- ============================================================================
DROP APPLICATION IF EXISTS CUSTOMER_REVERSE_APP;

CREATE APPLICATION CUSTOMER_REVERSE_APP
    FROM APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG
    USING VERSION V1;

-- ============================================================================
-- STEP 10: TEST THE APPLICATION
-- ============================================================================
SELECT * FROM CUSTOMER_REVERSE_APP.APP_CODE.CUST_WITH_JS_UDF;

SELECT CUSTOMER_REVERSE_APP.APP_CODE.REVERSE_STRING('NICKSRERE') AS REVERSED;

SELECT CUSTOMER_REVERSE_APP.APP_CODE.REVERSE_STRING_PYTHON('NICKSRERE') AS REVERSED;

-- ============================================================================
-- CONSUMER INSTALLATION (run in consumer account after sharing)
-- ============================================================================
-- CREATE APPLICATION MY_CUSTOMER_APP 
--     FROM APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG;
--
-- SELECT * FROM MY_CUSTOMER_APP.APP_CODE.CUST_WITH_JS_UDF;
-- SELECT MY_CUSTOMER_APP.APP_CODE.REVERSE_STRING('TEST');

-- ============================================================================
-- CLEANUP (optional - uncomment to remove)
-- ============================================================================
-- DROP APPLICATION IF EXISTS CUSTOMER_REVERSE_APP;
-- DROP APPLICATION PACKAGE IF EXISTS CUSTOMER_REVERSE_APP_PKG;
