# Collaborative Notes Hub - Database

This folder provisions and manages the PostgreSQL database for the Collaborative Notes Hub.

What this setup includes:
- PostgreSQL database: myapp
- User: appuser (password set by startup.sh)
- Port: 5000 (as provisioned and saved in db_connection.txt)
- Extensions: uuid-ossp, pgcrypto
- Tables:
  - notes: main notes storage
  - note_history: audit/history for note changes
- Indexes:
  - GIN index on notes.tags
  - btree index on notes.updated_at DESC
- Triggers:
  - trg_set_updated_at to maintain updated_at on updates
- Sample data: three initial notes created for testing

How to connect:
- Using saved connection (recommended):
  - cat db_connection.txt
  - Example: psql postgresql://appuser:dbuser123@localhost:5000/myapp
- Standard psql flags:
  - psql -h localhost -U appuser -d myapp -p 5000

Operational notes:
- All schema provisioning is executed one statement at a time via psql -c.
- The authoritative connection info is stored in db_connection.txt; use this to avoid port/user drift.
- If you rerun database/startup.sh it will ensure the same user/db/port and regenerate db_connection.txt and db_visualizer/postgres.env.
- To back up and restore, use:
  - ./backup_db.sh
  - ./restore_db.sh

Environment variables for other containers:
- DATABASE_URL (backend and integrations):
  - postgresql://appuser:dbuser123@localhost:5000/myapp
  - Prefer reading from database/db_connection.txt to keep consistency.
- db_visualizer.env:
  - Source db_visualizer/postgres.env for a lightweight DB inspection server.

Schema overview:

notes
- id uuid PK DEFAULT gen_random_uuid()
- title text NOT NULL
- content text NOT NULL
- tags text[] DEFAULT '{}'
- is_archived boolean NOT NULL DEFAULT false
- created_at timestamptz NOT NULL DEFAULT now()
- updated_at timestamptz NOT NULL DEFAULT now()

note_history
- id uuid PK DEFAULT gen_random_uuid()
- note_id uuid NOT NULL REFERENCES notes(id) ON DELETE CASCADE
- title text NOT NULL
- content text NOT NULL
- tags text[] DEFAULT '{}'
- changed_at timestamptz NOT NULL DEFAULT now()
- changed_by text DEFAULT 'system'
- change_type text NOT NULL

Indexes
- CREATE INDEX idx_notes_tags ON notes USING GIN (tags);
- CREATE INDEX idx_notes_updated_at ON notes (updated_at DESC);

Triggers
- set_updated_at() plpgsql -> BEFORE UPDATE ON notes sets updated_at=now()
- CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON notes FOR EACH ROW EXECUTE FUNCTION set_updated_at();

Port reconciliation:
- The database is provisioned on port 5000 as per startup.sh and db_connection.txt.
- Running metadata may show the database container exposed at another port, but the actual PostgreSQL server listens on 5000 inside this environment. Always use the connection string in db_connection.txt for the correct endpoint.

Seeding:
- Initial sample notes are inserted individually to validate the schema and make the UI usable immediately.

If you need to reset data:
- Drop tables manually (use the connection above), then re-run the individual statements as needed, or run restore_db.sh with a prepared backup.

