# Decision Log

A record of the choices made while building this project, and why.

---

## 18 Oct 2026 — Create the GitHub repo before doing any setup

**Decision:** I created the repository on GitHub first, cloned it to my
computer, and did all the setup inside that folder.

**Why:** Version control should be in place from the very first step.
Later stages of the project (pull requests and CI/CD) need a GitHub repo
to work with, so it is simpler to have it connected from the start.

**Alternatives considered:** Building the project locally and adding Git
at the end. I rejected this because it risks pushing secrets (like my
Databricks token) by accident before a .gitignore file exists.

---

## 18 Oct 2026 — Keep the repo root and the dbt project in separate folders

**Decision:** The project has two levels: the outer folder (cam_marketing)
holds the whole project, and the inner folder (cam_marketing/cam_marketing)
holds only the dbt project.

**Why:** Each level has a different job. The outer folder holds things that
apply to the whole project: the Python environment, Git, the README, this
decision log, and later the CI/CD files and data-loading scripts. The inner
folder holds only transformation logic. Keeping them apart stops dbt files
getting mixed up with everything else.

**Alternatives considered:** Putting everything in one folder. This works
for small projects, but it becomes messy once the project includes more
than dbt.

---

## 19 Oct 2026 — Give the project its own Python environment

**Decision:** I excluded this project from a uv workspace in my home folder,
so it now has its own environment (.venv) and its own lockfile (uv.lock)
inside the repo.

**Why:** By accident, the project had joined a shared workspace with my
class project. That meant its lockfile was stored outside the repo, so it
would never reach GitHub. Anyone cloning the repo, including CI, could not
rebuild the exact same environment. It also meant this project could use
packages it never listed, because they were installed for the class project.
That would work on my laptop but fail in CI.

**Alternatives considered:** Leaving both projects in the shared workspace.
I rejected this because a repo must contain everything needed to rebuild it.

---

## 19 Oct 2026 — Keep secrets in a .env file, not in profiles.yml

**Decision:** My Databricks token, host, and other connection details live
in a .env file, which Git ignores. profiles.yml only refers to them by name.

**Why:** profiles.yml can be safely pushed to GitHub (CI will need it later),
because it contains no real secrets. The .env file stays on my computer only.
A file also lasts after I close the terminal, unlike the export command.

**Alternatives considered:** Typing the token directly into profiles.yml
(unsafe, as it would end up on GitHub), or using export every time (the
values disappear when the terminal closes).

## 21 Oct 2026 — Keep Databricks setup SQL in the repo

**Decision:** The SQL I ran by hand in Databricks (creating catalogs,
schemas, and later permissions) is saved in a `setup/` folder, numbered
in the order it must be run.

**Why:** Commands run in the Databricks SQL Editor leave no trace in the
repo. If the workspace is deleted, or someone else needs to rebuild the
project, they would not know what to create. Saving the SQL makes the
setup reproducible, reviewable, and documented, just like the dbt code.
The numbers show the order, because you cannot grant permissions on a
catalog that does not exist yet.

**Alternatives considered:** Only describing the setup in the README.
Rejected because a description can drift from what was actually run;
the SQL file *is* what was run.

## 23 Oct 2026 — Treat null impressions and clicks as zero

**Decision:** In the staging models, null impressions and clicks are
replaced with 0, for both Facebook and Snapchat. Spend has no nulls.

**Why:**
- Null is common: 1.6% of Facebook rows have null impressions, 26.4% have
  null clicks, and 4.0% of Snapchat rows have null clicks.
- The evidence suggests null usually means "no activity": Facebook almost
  never writes an explicit 0 for clicks (42 rows), and null-click rows are
  mostly tiny ads (median 24 impressions vs 2,661 for other rows).
  Null-impression rows also have zero spend and no clicks.
- Totals are not affected either way, because SQL's SUM() ignores nulls.
  Using 0 makes the meaning explicit and avoids surprises in row-level
  calculations.

**Known risk:** 291 Facebook null-click rows have 1,000+ impressions, so
for a few rows "null = 0" is an assumption rather than a fact.

**Related:** Metrics that divide (CTR = clicks ÷ impressions,
CPC = cost per click = spend ÷ clicks, CPM = cost per 1,000 impressions)
return NULL when the denominator is 0, rather than failing or showing 0.

**Alternatives considered:**
- Dropping rows with nulls. Rejected: it would remove 26.4% of Facebook
  rows, and those rows still carry spend, so total spend would be understated.
- Leaving values as null. Workable, since totals are the same, but less
  clear for analysts working row by row.

## 23 Oct 2026 — Unified model grain is ad × day, without country

**Decision:** The unified model has one row per ad per day (Option B).
Snapchat rows, which are per ad per day per country, are summed across
countries. No country column is created for Facebook.

**Why:**
- Consistency: both platforms share the same grain, so they can be
  combined and compared without empty columns.
- The brief's business questions do not ask about country.
- Facebook has no measured country. Campaign names contain country-like
  codes (e.g. `ita_`, `bra_`), but these are labels typed by a person
  describing the intended market, not where the ad was shown. Some are not
  countries at all (`all-eu`, `global`, `NORDICS`, `LATAM`).
- Snapchat proves the gap: its campaign names say ITA, FRA, TUR and others,
  but its measured `ad_country` only shows DE, CH, AT and one US row.
  Putting a name-derived country and a measured country in one column
  would let analysts compare two different things as if they were the same.

**What is kept:** Snapchat's country detail stays in the raw table and its
staging model, so a country-level model can be added later if needed.

**Alternatives considered:**
- Grain of ad × day × country, with country left NULL for Facebook.
  Rejected because half the table would have an empty column, and a
  Facebook-vs-Snapchat comparison by country would be misleading.
- Parsing country from Facebook campaign names. Rejected as unreliable.

## 24 Oct 2026 — How the raw data was loaded

**Decision:** Facebook files were loaded with SQL (`read_files`, every
column as STRING). Snapchat files were loaded through the Databricks upload
screen with default settings, so Databricks chose their column types.
Both methods are recorded in `setup/03_load_raw_data.sql`.

**Why:** The SQL method keeps every value exactly as received, but it
needs more steps. For the small Snapchat files, the upload screen was
simpler, and its guessed types lose no information (BIGINT holds the IDs
exactly). In both cases the dbt staging models convert every column to
its final type, so the end result is the same.

**Trade-off:** The raw layer uses two loading methods, and the Snapchat
types depend on Databricks' guesses. For a recurring pipeline, I would
use one scripted method for all sources.