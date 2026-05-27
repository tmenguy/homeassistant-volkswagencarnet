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

GH_ACCOUNT="tmenguy"
GH_REPO="volkswagencarnet"
GH_BRANCH="master"

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
