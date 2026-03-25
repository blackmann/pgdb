# berry

`berry` is a bash-only Postgres branch manager with a small TUI powered by [`gum`](https://github.com/charmbracelet/gum).

## Install

Install `berry` from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/blackmann/pgdb/main/install.sh | bash
```

## What it does

- `berry list` shows databases on the current Postgres instance
- `berry branch` lets you choose a source database, pick an existing branch or create a new one, then prints the URL to use
- `berry delete` lets you choose a branch database and remove it with confirmation
- `berry url <database>` prints a Postgres URL for any database

Branch databases follow this naming convention:

```text
<source_db>__<branch_name>
```

Example:

```text
app__feature_login
```

## Requirements

- `bash`
- `psql`
- `gum` for interactive commands

Install `gum` on macOS with:

```bash
brew install gum
```

## Environment

`berry` accepts an optional base connection URL:

```bash
export DBURL=postgresql://postgres:postgres@localhost:5432/app
```

You can also use `DATABASE_URL` as a fallback.

If neither is set, `berry` falls back to whatever `psql` would use by default on your machine.

## Usage

List visible databases:

```bash
./berry list
```

`berry list` groups branch databases under their parent with a small tree view and shows database sizes in a right-aligned column.

Sample output:

```text
Databases
◆ adeton                 124.00mb
├─ adeton/campaigns      8.00mb
╰─ adeton/plans          22.00mb
◆ otr                    1.20gb
◆ ussdk                  310.00mb

System
postgres                 7.28mb
```

List branches for one database:

```bash
./berry list --branches app
```

Sample output:

```text
app/feature_login       8.00mb
app/bugfix_auth         22.00mb
```

Create or switch to a branch:

```bash
./berry branch
```

Sample output:

```text
Branch ready: adeton/plans
postgresql://postgres@127.0.0.1:5432/adeton__plans
```

Delete a branch:

```bash
./berry delete
```

Sample output:

```text
Deleted branch: adeton/plans
```

Print a URL directly:

```bash
./berry url app/feature_login
```

Sample output:

```text
postgresql://postgres@127.0.0.1:5432/app__feature_login
```

## Notes

- `berry branch` clones databases with `CREATE DATABASE ... WITH TEMPLATE ...`
- source databases must not be template databases
- branch creation is naming-based and stateless in v1
- branch names are shown as `source/branch` in the UI, while the real Postgres database name remains `source__branch`
- when `DBURL` is set, `berry` reuses it as the base for the printed branch URL
- when `DBURL` is not set, `berry` tries to infer a fuller URL from the active Postgres connection and falls back to `postgresql://localhost/database_name`
- if the source database is busy, `berry` stops and tells you to retry after closing connections
