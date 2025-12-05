# Project Repository

This is the initial README file for the project.

## Database Container Build Notes (Fix Applied)

- All orchestrators must build the database image from the database directory root only: `collaborative-notes-hub-287142/database`.
- Removed legacy references that attempted to `cd` into `collaborative-notes-hub-287142/database/db_visualizer`. That directory does not exist and is not required.
- Build locally:
  - `cd collaborative-notes-hub-287142/database && bash docker-build.sh`
- Run locally:
  - `docker run --rm -d --name collab-notes-db -e POSTGRES_DB=notes_db -e POSTGRES_USER=notes_user -e POSTGRES_PASSWORD=notes_password -p 5432:5432 collab-notes-db:latest`
- Health check:
  - `docker exec -it collab-notes-db pg_isready -U notes_user -d notes_db`
- Test via psql (if installed):
  - `psql -h localhost -U notes_user -d notes_db -p 5432 -c "SELECT version();"`