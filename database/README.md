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
  - Then copy/paste the exact psql command contained in the file.
  - Example currently saved: psql postgresql://appuser:dbuser123@localhost:5000/myapp
- Standard psql flags (ensure the port matches db_connection.txt):
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
  - Use the exact string in database/db_connection.txt (strip the leading `psql `) for consistency.
  - Example: postgresql://appuser:dbuser123@localhost:5000/myapp
- db_visualizer.env:
  - Source db_visualizer/postgres.env for a lightweight DB inspection server.

Schema overview (as provisioned):

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
- CREATE INDEX IF NOT EXISTS idx_notes_tags ON notes USING GIN (tags);
- CREATE INDEX IF NOT EXISTS idx_notes_updated_at ON notes (updated_at DESC);

Triggers
- Function: set_updated_at() plpgsql -> BEFORE UPDATE ON notes sets updated_at=now()
- Trigger: CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON notes FOR EACH ROW EXECUTE FUNCTION set_updated_at();

Port reconciliation:
- The database is provisioned on port 5000 as per startup.sh and db_connection.txt.
- Running metadata may show the database container exposed at another port. Always use the connection string in db_connection.txt for the correct endpoint to avoid mismatches.

Seeding:
- Initial sample notes are inserted individually to validate the schema and make the UI usable immediately (three sample notes inserted).

If you need to reset data:
- Drop tables manually (use the connection above), then re-run the individual statements as needed, or run restore_db.sh with a prepared backup.

Provisioning summary (executed now via psql -c, one statement at a time):
- CREATE EXTENSION IF NOT EXISTS pgcrypto;
- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
- CREATE TABLE IF NOT EXISTS notes (...);
- CREATE TABLE IF NOT EXISTS note_history (...);
- CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;
  - Note: when running interactively, ensure proper quoting of the dollar-quoted body. If your shell injects characters, prefer: write to a temp file and run psql -f.
- DROP TRIGGER IF EXISTS trg_set_updated_at ON notes;
- CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON notes FOR EACH ROW EXECUTE FUNCTION set_updated_at();
- CREATE INDEX IF NOT EXISTS idx_notes_tags ON notes USING GIN (tags);
- CREATE INDEX IF NOT EXISTS idx_notes_updated_at ON notes (updated_at DESC);
- GRANT USAGE, CREATE ON SCHEMA public TO appuser;
- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO appuser;
- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO appuser;
- INSERT sample notes (3 rows, one INSERT per statement).

Exact one-liners executed (port/user taken from db_connection.txt):
- $(cat db_connection.txt) -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
- $(cat db_connection.txt) -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
- $(cat db_connection.txt) -c "CREATE TABLE IF NOT EXISTS notes ( id uuid PRIMARY KEY DEFAULT gen_random_uuid(), title text NOT NULL, content text NOT NULL, tags text[] DEFAULT '{}', is_archived boolean NOT NULL DEFAULT false, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now() );"
- $(cat db_connection.txt) -c "CREATE TABLE IF NOT EXISTS note_history ( id uuid PRIMARY KEY DEFAULT gen_random_uuid(), note_id uuid NOT NULL REFERENCES notes(id) ON DELETE CASCADE, title text NOT NULL, content text NOT NULL, tags text[] DEFAULT '{}', changed_at timestamptz NOT NULL DEFAULT now(), changed_by text DEFAULT 'system', change_type text NOT NULL );"
- Function creation, if quoting issues occur:
  - Write SQL to file and execute:
    - cat > /tmp/create_fn.sql <<'SQL'
      CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS $$
      BEGIN
        NEW.updated_at = now();
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      SQL
    - $(cat db_connection.txt | sed 's/^psql //') -f /tmp/create_fn.sql
- $(cat db_connection.txt) -c "DROP TRIGGER IF EXISTS trg_set_updated_at ON notes;"
- $(cat db_connection.txt) -c "CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON notes FOR EACH ROW EXECUTE FUNCTION set_updated_at();"
- $(cat db_connection.txt) -c "CREATE INDEX IF NOT EXISTS idx_notes_tags ON notes USING GIN (tags);"
- $(cat db_connection.txt) -c "CREATE INDEX IF NOT EXISTS idx_notes_updated_at ON notes (updated_at DESC);"
- $(cat db_connection.txt) -c "GRANT USAGE, CREATE ON SCHEMA public TO appuser;"
- $(cat db_connection.txt) -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO appuser;"
- $(cat db_connection.txt) -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO appuser;"

Seed data (each as its own statement):
- $(cat db_connection.txt) -c "INSERT INTO notes (title, content, tags) VALUES ('Welcome note', 'This is your first note in Collaborative Notes Hub.', ARRAY['welcome','first']);"
- $(cat db_connection.txt) -c "INSERT INTO notes (title, content, tags) VALUES ('Team meeting', 'Notes from the weekly team sync. Action items included.', ARRAY['meeting','team']);"
- $(cat db_connection.txt) -c "INSERT INTO notes (title, content, tags, is_archived) VALUES ('Product roadmap', 'Q1 roadmap highlights: discovery, MVP, feedback loop.', ARRAY['product','roadmap'], false);"

Port consistency
- Always use the exact connection in database/db_connection.txt. If any runtime metadata shows a different exposed port, prefer db_connection.txt to avoid mismatches.
