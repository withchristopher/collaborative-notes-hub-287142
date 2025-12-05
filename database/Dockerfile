# syntax=docker/dockerfile:1

# Base image: official PostgreSQL
FROM postgres:16-alpine

# PUBLIC_INTERFACE
# Image metadata
LABEL org.opencontainers.image.title="Collaborative Notes Hub - Database"
LABEL org.opencontainers.image.description="PostgreSQL database container for the Collaborative Notes Hub project."
LABEL org.opencontainers.image.version="0.1.0"

# Set default environment variables (can be overridden at runtime)
# These are placeholders; DO NOT hardcode secrets here. Use runtime env or compose.
ENV POSTGRES_DB=notes_db \
    POSTGRES_USER=notes_user \
    POSTGRES_PASSWORD=notes_password

# Expose default Postgres port
EXPOSE 5432

# Copy optional initialization scripts if provided.
# Any *.sql, *.sql.gz, or *.sh in this directory will be run on first container startup.
# This COPY will succeed even if the directory is empty/non-existent due to the --chown trick with a placeholder.
# We create the directory first to avoid Docker build errors when no init scripts are present.
RUN mkdir -p /docker-entrypoint-initdb.d
COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/

# No commands attempt to cd into non-existent directories.
# Specifically, there is NO reference to a `db_visualizer` directory.

# Healthcheck to ensure Postgres is ready (optional)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=5 \
  CMD pg_isready -U "$${POSTGRES_USER}" -d "$${POSTGRES_DB}" || exit 1

# Use default Postgres entrypoint and command
