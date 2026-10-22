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