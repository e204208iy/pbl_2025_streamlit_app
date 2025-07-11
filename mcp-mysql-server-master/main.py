from typing import Any, Dict
import os 
import logging

import MySQLdb  
from mcp.server.fastmcp import FastMCP


# Create MCP server instance
mcp = FastMCP("mysql-server")

# Database connection configuration
DB_CONFIG = {
    "host": "127.0.0.1",
    "user": "root",
    "passwd": "password", 
    "db": "test_db",  
    "port": 3306,
}

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("mysql-mcp-server")


# Connect to MySQL database
def get_connection():
    logger.debug("Attempting to establish database connection...")
    try:
        return MySQLdb.connect(**DB_CONFIG)
        logger.info("Database connection successful.")
    except MySQLdb.Error as e:
        logger.error(f"Database connection failed: {e}", exc_info=True)
        raise


@mcp.resource("mysql://schema")
def get_schema() -> Dict[str, Any]:
    """Provide database table structure information"""
    logger.info("Executing get_schema resource...")
    conn = get_connection()
    cursor = None
    try:
        # Create dictionary cursor
        cursor = conn.cursor(MySQLdb.cursors.DictCursor)

        logger.debug("Fetching table list...")
        # Get all table names
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        table_names = [list(table.values())[0] for table in tables]
        logger.debug(f"Found tables: {table_names}")

        # Get structure for each table
        schema = {}
        for table_name in table_names:
            logger.debug(f"Describing table: {table_name}")
            cursor.execute(f"DESCRIBE `{table_name}`")
            columns = cursor.fetchall()
            table_schema = []
            
            for column in columns:
                table_schema.append({
                    "name": column["Field"],
                    "type": column["Type"],
                    "null": column["Null"],
                    "key": column["Key"],
                    "default": column["Default"],
                    "extra": column["Extra"]
                })
            
            schema[table_name] = table_schema
        
        logger.info("Successfully retrieved schema.")
        return {
            "database": DB_CONFIG["db"],
            "tables": schema
        }
    except Exception as e:
        # --- デバッグログ追加 ---
        logger.error(f"An error occurred in get_schema: {e}", exc_info=True)
        raise
    finally:
        if cursor:
            cursor.close()
        conn.close()
        logger.debug("get_schema resource finished and connection closed.")



def is_safe_query(sql: str) -> bool:
    """Basic check for potentially unsafe queries"""
    sql_lower = sql.lower()
    unsafe_keywords = ["insert", "update", "delete", "drop", "alter", "truncate", "create"]
    return not any(keyword in sql_lower for keyword in unsafe_keywords)


@mcp.tool()
def query_data(sql: str) -> Dict[str, Any]:
    """Execute read-only SQL queries"""
    if not is_safe_query(sql):
        return {
            "success": False,
            "error": "Potentially unsafe query detected. Only SELECT queries are allowed."
        }
    logger.info(f"Executing query_data tool with SQL: {sql}")
    conn = get_connection()
    cursor = None
    try:
        # Create dictionary cursor
        cursor = conn.cursor(MySQLdb.cursors.DictCursor)
        logger.debug(f"Executing SQL: {sql}")

        # Start read-only transaction
        cursor.execute("SET TRANSACTION READ ONLY")
        cursor.execute("START TRANSACTION")
        
        try:
            cursor.execute(sql)
            results = cursor.fetchall()
            conn.commit()
            
            # Convert results to serializable format
            return {
                "success": True,
                "results": results,
                "rowCount": len(results)
            }
        except Exception as e:
            conn.rollback()
            logger.error(f"Error executing query '{sql}': {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e)
            }
    finally:
        if cursor:
            cursor.close()
        conn.close()
        logger.debug("query_data tool finished and connection closed.")



@mcp.resource("mysql://tables")
def get_tables() -> Dict[str, Any]:
    """Provide database table list"""
    logger.info("Executing get_tables resource...")
    conn = get_connection()
    cursor = None
    try:
        # Create dictionary cursor
        cursor = conn.cursor(MySQLdb.cursors.DictCursor)
        
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        table_names = [list(table.values())[0] for table in tables]
        logger.info(f"Successfully retrieved tables: {table_names}")

        return {
            "database": DB_CONFIG["db"],
            "tables": table_names
        }
    finally:
        if cursor:
            cursor.close()
        conn.close()
        logger.debug("get_tables resource finished and connection closed.")


def validate_config():
    """Validate database configuration"""
    required_vars = ["DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME"]
    missing = [var for var in required_vars if not os.getenv(var)]
    
    if missing:
        logger.warning(f"Missing environment variables: {', '.join(missing)}")
        logger.warning("Using default values, which may not work in production.")


def main():
    validate_config()
    print(f"MySQL MCP server started, connected to {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['db']}")


if __name__ == "__main__":
    mcp.run()
