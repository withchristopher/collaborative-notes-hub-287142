# Database Container (PostgreSQL)

This directory contains the Docker configuration for the PostgreSQL database used by the Collaborative Notes Hub.

## Building

You can build the image using the provided script:

```bash
cd collaborative-notes-hub-287142/database
bash docker-build.sh
```

Environment variables such as database name, user, and password can be set at runtime. Do not hardcode secrets in the Dockerfile; use Docker Compose or `docker run -e` flags.

Default values in the image (override as needed at runtime):
- POSTGRES_DB=notes_db
- POSTGRES_USER=notes_user
- POSTGRES_PASSWORD=notes_password

## Running (example)

```bash
docker run --rm -d \
  --name collab-notes-db \
  -e POSTGRES_DB=notes_db \
  -e POSTGRES_USER=notes_user \
  -e POSTGRES_PASSWORD=notes_password \
  -p 5432:5432 \
  collab-notes-db:latest
```

## Initialization scripts (optional)

If you place SQL or shell scripts in `docker-entrypoint-initdb.d/`, the official Postgres entrypoint will run them on first container startup.

Structure:
```
collaborative-notes-hub-287142/
  database/
    docker-entrypoint-initdb.d/
      001_schema.sql
      002_seed.sql
```

This directory is optional. If it does not exist or is empty, the build still succeeds.

## Note on db_visualizer

Some workflows use a database visualizer tool. There is no requirement to include a `db_visualizer` directory in this container, and no build step will attempt to `cd` into it. If you need such a tool, add it as a separate service or create a directory where appropriate, but it is not required for building this image.
