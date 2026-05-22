#!/bin/sh
# Initialize Davinci system database on SQL Server (requires sqlcmd)
if [ -z "$DAVINCI3_HOME" ]; then
  echo "DAVINCI3_HOME is not set"
  exit 1
fi
SERVER="${SQLSERVER_HOST:-localhost}"
DB="${SQLSERVER_DB:-davinci}"
USER="${SQLSERVER_USER:-sa}"
PASS="${SQLSERVER_PASSWORD:-your_password}"
sqlcmd -S "$SERVER" -U "$USER" -P "$PASS" -Q "IF DB_ID('$DB') IS NULL CREATE DATABASE [$DB]"
sqlcmd -S "$SERVER" -U "$USER" -P "$PASS" -d "$DB" -i "$DAVINCI3_HOME/bin/davinci.sqlserver.sql"
