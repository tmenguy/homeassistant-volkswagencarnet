"""pytest fixtures."""

import importlib.util
from pathlib import Path
import sys
from unittest.mock import patch

import pytest

# ---------------------------------------------------------------------------
# Exercise the *bundled* volkswagencarnet library
# (custom_components/volkswagencarnet/volkswagencarnet/) during tests instead of
# any pip-installed copy, so editing the inlined sources is reflected
# immediately (fast iteration). It is registered under both the bare
# `volkswagencarnet` name (how the tests and integration import it, e.g.
# `from volkswagencarnet.vw_connection import ...`) and
# `custom_components.volkswagencarnet.volkswagencarnet` (what the integration's
# __init__ does via `from . import volkswagencarnet`) so there is a single set
# of module objects -- patches and isinstance checks stay consistent.
# ---------------------------------------------------------------------------
_PROJECT_ROOT = Path(__file__).resolve().parent.parent
_VWCN_DIR = _PROJECT_ROOT / "custom_components" / "volkswagencarnet" / "volkswagencarnet"

if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

if "volkswagencarnet" not in sys.modules:
    _vwcn_spec = importlib.util.spec_from_file_location(
        "volkswagencarnet",
        str(_VWCN_DIR / "__init__.py"),
        submodule_search_locations=[str(_VWCN_DIR)],
    )
    _vwcn_mod = importlib.util.module_from_spec(_vwcn_spec)
    sys.modules["volkswagencarnet"] = _vwcn_mod
    sys.modules["custom_components.volkswagencarnet.volkswagencarnet"] = _vwcn_mod
    _vwcn_spec.loader.exec_module(_vwcn_mod)


@pytest.fixture(autouse=True)
def auto_enable_custom_integrations(enable_custom_integrations):
    """Enable custom integrations defined in the test dir."""
    yield


@pytest.fixture
def bypass_setup_fixture():
    """Prevent setup."""
    with (
        patch(
            "custom_components.volkswagencarnet.async_setup",
            return_value=True,
        ),
        patch(
            "custom_components.volkswagencarnet.async_setup_entry",
            return_value=True,
        ),
    ):
        yield


@pytest.fixture
def m_connection():
    """Real connection for integration tests."""
    return MockConnection()


class MockConnection:
    """Mock connection for testing."""

    def __init__(self, **kwargs):
        """Init."""
        pass

    async def doLogin(self):
        """No-op login."""
        return True

    async def update(self):
        """No-op update."""
        return True
