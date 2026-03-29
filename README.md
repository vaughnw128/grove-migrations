# Grove Migrations

Database schema migrations for my Cloud Native Postgres cluster.

Migrations are run using golang-migrate within Github Actions, which connects to my cluster via Tailscale.

## Usage

1. Create a new migration file:

```bash
migrate create -ext sql -dir ./migrations -seq <migration_name>
``` 

2. Edit the generated SQL files to define the `up` and `down` migrations.

3. Commit the migration files to the repository.

4. The Github Action will automatically run the migrations against the database when changes are pushed to the main branch.