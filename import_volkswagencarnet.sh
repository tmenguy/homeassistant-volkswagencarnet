#!/bin/bash
# Refresh the bundled (inlined) copy of the volkswagencarnet library inside the
# integration, mirroring import_pyatmo.sh / import_renault_api.sh in the
# netatmo / renault custom components.
#
# Why: the integration normally depends on the pip package `volkswagencarnet`.
# Bundling a local copy under custom_components/volkswagencarnet/volkswagencarnet/
# lets you edit the library and run the integration / tests immediately, with no
# reinstall (fast testing turnaround).
#
# Source of truth: the fork https://github.com/tmenguy/volkswagencarnet
# (branch master), package directory `volkswagencarnet/`. Push your library
# changes there, then run this script from the repository root to pull them in.
GH_RAW_BASE="https://raw.githubusercontent.com"

# Source of the library code. Defaults to the fork's main line (branch master).
# To temporarily pull a different branch -- e.g. an upstream PR under review --
# override any of these on the command line, without editing this file:
#
#   GH_ACCOUNT=RaHehl GH_BRANCH=fix/auth-vw-identity-flow bash import_volkswagencarnet.sh
#
# That example is robinostlund/volkswagencarnet PR #329. Find a PR's head repo
# owner and branch with:
#
#   gh pr view <N> --repo robinostlund/volkswagencarnet --json headRepositoryOwner,headRefName
#
# Run with no overrides to go back to master.
GH_ACCOUNT="${GH_ACCOUNT:-tmenguy}"
GH_REPO="${GH_REPO:-volkswagencarnet}"
GH_BRANCH="${GH_BRANCH:-master}"

## Gather volkswagencarnet and modify
path="custom_components/volkswagencarnet/volkswagencarnet"
mkdir -p ${path}
rm -f ${path}/*.py
rm -f ${path}/*.typed

gh_path="${GH_RAW_BASE}/${GH_ACCOUNT}/${GH_REPO}/${GH_BRANCH}/volkswagencarnet"
files="__init__.py vw_connection.py vw_const.py vw_dashboard.py vw_exceptions.py vw_utilities.py vw_vehicle.py"

for file in ${files}; do
  wget ${gh_path}/${file} -O ${path}/${file}
  # The library already uses package-relative imports (e.g. `from .vw_const import ...`),
  # but rewrite any absolute self-imports defensively so the bundled copy never
  # reaches for a pip-installed volkswagencarnet.
  gsed -i 's/from volkswagencarnet /from . /g' ${path}/${file}
  gsed -i 's/from volkswagencarnet\./from ./g' ${path}/${file}
  gsed -i 's/from \.\./from \./g' ${path}/${file}
done

echo "Bundled volkswagencarnet refreshed at ${path}"
