# Snowflake Native App: Customer Data UDF Sharing

A Snowflake Native Application that demonstrates **secure data sharing with User-Defined Functions (UDFs)** without data replication. This app showcases how to share live data through secure views while providing custom transformation functions to consumers.

## 🎯 What This App Does

This Native App provides:
- **Data Sharing via Reference** - No data duplication, consumers access live data
- **JavaScript UDF** - `REVERSE_STRING()` function for string transformation
- **Python UDF** - `REVERSE_STRING_PYTHON()` alternative implementation
- **Secure View** - Pre-built view combining shared data with UDF transformations
- **Consumer-Ready Package** - Fully deployable app for internal or external users

---

## 📋 Prerequisites

### Required Snowflake Permissions
- `CREATE APPLICATION PACKAGE` privilege
- `CREATE DATABASE` privilege
- Ability to grant `REFERENCE_USAGE` on source databases
- Access to an existing warehouse
- Source data: A table with customer data (CUSTID, NAME columns)

### Required Files
- `manifest.yml` - App configuration file
- `setup.sql` - App initialization script (creates UDFs and views)
- `build_app.sql` - Complete build and deployment script

---

## 🚀 Quick Start Installation

### Step 1: Prepare Your Source Data

Ensure you have a source table with the following structure:

```sql
-- Example: Your source database and table
-- YOURDB.PUBLIC.CUSTOMERS with columns: CUSTID, NAME
SELECT * FROM YOURDB.PUBLIC.CUSTOMERS LIMIT 5;
```

### Step 2: Update Configuration

Edit `build_app.sql` and update these values:

**Line 32-33:** Update the database name for REFERENCE_USAGE grant:
```sql
GRANT REFERENCE_USAGE ON DATABASE YOUR_DATABASE_NAME 
    TO SHARE IN APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG;
```

**Line 41:** Update the source table reference:
```sql
CREATE OR REPLACE SECURE VIEW CUSTOMER_REVERSE_APP_PKG.SHARED_DATA.CUSTOMERS AS
SELECT * FROM YOUR_DATABASE.YOUR_SCHEMA.YOUR_TABLE;
```

### Step 3: Upload App Files to Snowflake

Using Snowsight UI or SnowSQL:

**Option A: Using Snowsight UI**
1. Open Snowsight
2. Navigate to Data » Databases
3. Create the stage using the build script
4. Upload `manifest.yml` and `setup.sql` to the stage

**Option B: Using SnowSQL**
```bash
# Update the file paths to your local directory
PUT file:///path/to/manifest.yml @CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT.APP_STAGE;
PUT file:///path/to/setup.sql @CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT.APP_STAGE;
```

### Step 4: Run the Build Script

Execute `build_app.sql` in Snowsight or SnowSQL:
```sql
-- Run the entire build_app.sql file
-- This will:
-- 1. Create the Application Package
-- 2. Create the stage for app files
-- 3. Grant reference usage on your database
-- 4. Create shared data schema and secure view
-- 5. Register version V1
-- 6. Configure release channel
-- 7. Create and test the application
```

---

## 🔧 Configuration Details

### Application Package Structure

```
CUSTOMER_REVERSE_APP_PKG/
├── STAGE_CONTENT/
│   └── APP_STAGE/
│       ├── manifest.yml
│       └── setup.sql
└── SHARED_DATA/
    └── CUSTOMERS (Secure View)
```

### Installed Application Structure

```
CUSTOMER_REVERSE_APP/
└── APP_CODE/
    ├── REVERSE_STRING() - JavaScript UDF
    ├── REVERSE_STRING_PYTHON() - Python UDF
    └── CUST_WITH_JS_UDF - Secure View with transformations
```

---

## 📖 Usage Examples

### After Installation - Testing the App

**1. Query the Transformed Data View:**
```sql
SELECT * FROM CUSTOMER_REVERSE_APP.APP_CODE.CUST_WITH_JS_UDF;
-- Returns: CUSTID, CUSTNAME, REVERSED_CUSTNAME
```

**2. Use the JavaScript UDF Directly:**
```sql
SELECT CUSTOMER_REVERSE_APP.APP_CODE.REVERSE_STRING('SNOWFLAKE') AS REVERSED;
-- Returns: EKALFWONS
```

**3. Use the Python UDF Directly:**
```sql
SELECT CUSTOMER_REVERSE_APP.APP_CODE.REVERSE_STRING_PYTHON('HELLO') AS REVERSED;
-- Returns: OLLEH
```

---

## 🌐 Consumer Installation

When sharing this app with consumers (other Snowflake accounts):

### Provider Steps:
1. Complete the installation steps above
2. Share the Application Package through Snowflake Marketplace or Private Listing
3. Grant consumers access to install from the package

### Consumer Steps:
```sql
-- Consumer runs this in their account
CREATE APPLICATION MY_CUSTOMER_APP 
    FROM APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG;

-- Test the installation
SELECT * FROM MY_CUSTOMER_APP.APP_CODE.CUST_WITH_JS_UDF;
SELECT MY_CUSTOMER_APP.APP_CODE.REVERSE_STRING('TEST');
```

---

## 🔐 Security & Data Sharing Details

### Data Sharing Method: REFERENCE_USAGE

**Benefits:**
- ✅ **No Data Replication** - Consumers access live data in real-time
- ✅ **Zero Data Movement** - Data stays in provider account
- ✅ **Automatic Updates** - Consumers always see current data
- ✅ **Cost Efficient** - No storage costs for consumers
- ✅ **Single Source of Truth** - Provider maintains data governance

### Security Features:

**Secure Views:**
- All data access is through secure views (query text hidden from consumers)
- Provider controls exactly what data is shared
- Row-level and column-level security can be implemented

**Application Roles:**
- `APP_USER` role grants least-privilege access
- Only granted permissions: USAGE on schema, USAGE on functions, SELECT on views

**UDF Security:**
- JavaScript and Python UDFs run in isolated environments
- Functions cannot access external resources or APIs
- Code is compiled and versioned with the app

---

## 📊 Step-by-Step Build Process

The `build_app.sql` script executes these steps in order:

| Step | Action | Description |
|------|--------|-------------|
| 1 | Create Application Package | Container for the app |
| 2 | Create Stage | Storage for app files |
| 3 | Upload Files | manifest.yml and setup.sql |
| 4 | Grant Reference Usage | Enable data sharing without copy |
| 5 | Create Shared Schema | Organize shared objects |
| 6 | Create Secure View | Define what data to share |
| 7 | Verify Stage Files | Confirm uploads successful |
| 8 | Register Version | Create version V1 |
| 9 | Configure Release | Set up DEFAULT channel |
| 10 | Create Application | Install for testing |
| 11 | Test Application | Verify functionality |

---

## 🧪 Testing & Validation

### Verify Stage Contents:
```sql
LIST @CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT.APP_STAGE;
-- Should show: manifest.yml, setup.sql
```

### Check Package Versions:
```sql
SHOW VERSIONS IN APPLICATION PACKAGE CUSTOMER_REVERSE_APP_PKG;
-- Should show: V1 with DEFAULT channel
```

### Validate Data Access:
```sql
-- Test that data is live (not copied)
-- Update source table and query app view again
UPDATE YOURDB.PUBLIC.CUSTOMERS SET NAME = 'Updated Name' WHERE CUSTID = 1;
SELECT * FROM CUSTOMER_REVERSE_APP.APP_CODE.CUST_WITH_JS_UDF WHERE CUSTID = 1;
-- Should show the updated data immediately
```

---

## 🧹 Cleanup

To remove the application and package:

```sql
-- Remove the installed application
DROP APPLICATION IF EXISTS CUSTOMER_REVERSE_APP;

-- Remove the application package
DROP APPLICATION PACKAGE IF EXISTS CUSTOMER_REVERSE_APP_PKG;
```

---

## 🆘 Troubleshooting

### Issue: "Cannot grant REFERENCE_USAGE"
**Solution:** Ensure you have appropriate privileges on the source database:
```sql
GRANT REFERENCE_USAGE ON DATABASE YOUR_DB TO ROLE YOUR_ROLE;
```

### Issue: "Stage files not found"
**Solution:** Verify files were uploaded correctly:
```sql
LIST @CUSTOMER_REVERSE_APP_PKG.STAGE_CONTENT.APP_STAGE;
```

### Issue: "View query failed"
**Solution:** Check that the source table exists and column names match (CUSTID, NAME):
```sql
DESC TABLE YOURDB.PUBLIC.CUSTOMERS;
```

### Issue: "Application installation failed"
**Solution:** Review the manifest.yml syntax and ensure setup.sql is valid SQL

---

## 📚 Additional Resources

- [Snowflake Native Apps Documentation](https://docs.snowflake.com/en/developer-guide/native-apps/native-apps-about)
- [Data Sharing with Reference Usage](https://docs.snowflake.com/en/user-guide/data-sharing-provider)
- [JavaScript UDFs](https://docs.snowflake.com/en/developer-guide/udf/javascript/udf-javascript)
- [Python UDFs](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python)

---

## 📝 Notes

- **Version Management:** Update version numbers (V1, V2, etc.) when releasing updates
- **Data Governance:** Consider implementing row-level security based on consumer account
- **Performance:** UDFs execute on Snowflake's compute - monitor query performance
- **Compliance:** Data sharing via REFERENCE_USAGE maintains data residency in provider account

---

**Built for Snowflake Native Apps Framework** 
*Demonstrating secure data sharing with custom transformations*
