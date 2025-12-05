# Database (PostgreSQL)

This directory represents the database service for the application.

## Connection Info

If a `db_connection.txt` file is provided/generated here, it should include the host, port, database name, user, and password. The backend may parse this file to construct a `DATABASE_URL` if it is not otherwise set via environment variables.

Typical local defaults:
- Host: localhost
- Port: 5001 (or as specified in `db_connection.txt`)
- Database: notesdb (example)
- User/Password: as configured locally

Ensure the backend’s `DATABASE_URL` matches the actual connection parameters.
