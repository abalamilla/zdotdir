#!/usr/bin/env zsh

# Oracle Instant Client configuration
export ORACLE_HOME="$HOME/oracle/instantclient_23_3"
export PATH="$ORACLE_HOME:$PATH"
export DYLD_LIBRARY_PATH="$ORACLE_HOME:$DYLD_LIBRARY_PATH"

# Optional: Set locale for SQL*Plus
export NLS_LANG="AMERICAN_AMERICA.UTF8"
