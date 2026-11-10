#!/usr/bin/env python3
"""Accept only explicit loopback or Unix-socket libpq connection strings."""

from __future__ import annotations

import shlex
import sys
from urllib.parse import parse_qs, unquote, urlsplit


LOOPBACK_HOSTS = {"localhost", "127.0.0.1", "::1"}


def is_local_host(value: str) -> bool:
    decoded = unquote(value).strip()
    return decoded.lower() in LOOPBACK_HOSTS or decoded.startswith("/")


def is_nested_conninfo(value: str) -> bool:
    decoded = unquote(value).strip().lower()
    return decoded.startswith(("postgres://", "postgresql://")) or "=" in decoded


def validate_uri(dsn: str) -> None:
    parsed = urlsplit(dsn)
    if parsed.scheme not in {"postgres", "postgresql"}:
        raise ValueError("unsupported PostgreSQL URI scheme")
    query = parse_qs(parsed.query, keep_blank_values=True)
    if "service" in query:
        raise ValueError("libpq service indirection is not allowed")
    if any(is_nested_conninfo(value) for value in query.get("dbname", [])):
        raise ValueError("nested dbname connection strings are not allowed")
    hosts: list[str] = []
    if parsed.hostname:
        hosts.append(parsed.hostname)
    hosts.extend(query.get("host", []))
    hosts.extend(query.get("hostaddr", []))
    if not hosts or any(not is_local_host(host) for host in hosts):
        raise ValueError("URI host is not explicit loopback or a Unix socket")


def validate_keyword_dsn(dsn: str) -> None:
    values: dict[str, list[str]] = {}
    for token in shlex.split(dsn, posix=True):
        if "=" not in token:
            raise ValueError("invalid libpq keyword token")
        key, value = token.split("=", 1)
        values.setdefault(key.lower(), []).append(value)
    if "service" in values:
        raise ValueError("libpq service indirection is not allowed")
    if any(is_nested_conninfo(value) for value in values.get("dbname", [])):
        raise ValueError("nested dbname connection strings are not allowed")
    hosts = values.get("host", []) + values.get("hostaddr", [])
    if not hosts or any(not is_local_host(host) for host in hosts):
        raise ValueError("keyword DSN host is not explicit loopback or a Unix socket")


def main() -> None:
    if len(sys.argv) != 2 or not sys.argv[1].strip():
        raise SystemExit("usage: validate-local-postgres-dsn.py DSN")
    dsn = sys.argv[1].strip()
    try:
        if dsn.startswith(("postgres://", "postgresql://")):
            validate_uri(dsn)
        else:
            validate_keyword_dsn(dsn)
    except (ValueError, UnicodeError) as error:
        print(f"invalid isolated PostgreSQL target: {error}", file=sys.stderr)
        raise SystemExit(1) from error
    print("isolated-local-database")


if __name__ == "__main__":
    main()
