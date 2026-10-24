"""Private stdin boundary for the read-only sandbox provider bridge."""
import json
from pathlib import Path
import sys
from fulfill import GateError, instant, prepare

try:
    raw = sys.stdin.read(65537)
    if len(raw) > 65536:
        raise GateError("input too large")
    data = json.loads(raw)
    if data["order"]["mode"] != "sandbox" or data["payment"]["method"] != "stripe_test_api_readback":
        raise GateError("sandbox bridge required")
    print(json.dumps(prepare(data["order"], data["payment"], Path(sys.argv[1]), instant(data["now"], "clock"))))
except (GateError, ValueError, KeyError, TypeError, OSError) as exc:
    print(f"NOT PREPARED: {exc}", file=sys.stderr)
    sys.exit(2)
