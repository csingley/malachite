#!/usr/bin/env python3
"""GPU job scheduler: a theme sample, not real code.

Every kind of token the theme has to tell apart appears below, often twice
(once as code, once as text), so that colliding colors are easy to spot.
"""
from __future__ import annotations

import asyncio
import re
import subprocess
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Optional

# TODO: this is a TODO comment, the tag should stand out
# NOTE: a NOTE comment; FIXME and HACK and WARN are the other tags
# A plain comment, which should be quiet but readable.

MAX_RETRIES = 3                      # constant (upper case) and a number
TIMEOUT_S = 2.5e1                    # float with an exponent
MASK = 0xFF_FF                       # hex literal
GAMMA = 1_000 + 3j                   # underscore int and a complex literal
DEBUG = False                        # boolean
DEFAULT_DEVICE = None                # None
NODE_PATTERN = re.compile(r"^gpu-(?P<rack>\d+)-(?P<slot>[a-z]+)$")   # a raw regex string
KEYWORD_AS_TEXT = "def class return if else for while"   # keywords inside a string


class State(Enum):
    """Job state. A docstring, which is a string but means documentation."""

    PENDING = "pending"
    RUNNING = "running"
    FAILED = "failed"


@dataclass(frozen=True)
class Job:
    name: str
    gpus: int = 1
    tags: list[str] = field(default_factory=list)
    owner: Optional[str] = None

    @property
    def label(self) -> str:
        return f"{self.name}:{self.gpus}"          # an f-string with interpolation

    def describe(self, *args: object, verbose: bool = False, **kwargs: object) -> str:
        """Method with *args and **kwargs: parameters versus plain variables."""
        parts = [self.name, str(self.gpus)]
        if verbose and (extra := kwargs.get("extra")):       # walrus operator
            parts.append(f"{extra!r:>12} ({len(args)} args)")   # conversion and format spec
        return "-".join(parts)


def retry(times: int = MAX_RETRIES):
    """A decorator factory: the @name below is a decorator, not an operator."""

    def wrap(func):
        def inner(*args, **kwargs):
            for attempt in range(1, times + 1):
                try:
                    return func(*args, **kwargs)
                except (OSError, ValueError) as exc:
                    print(f"retry {attempt}/{times}: {exc}")
                finally:
                    pass
            raise RuntimeError("out of retries")

        return inner

    return wrap


@retry(times=2)
def query_gpus(host: str, *, timeout: float = TIMEOUT_S) -> list[dict[str, str]]:
    """Function definition (the name) versus the calls inside it."""
    out = subprocess.run(
        ["ssh", host, "gpu-query", "--field=name,memory.used", "--format=csv"],
        capture_output=True,
        text=True,
        timeout=timeout,
        check=True,
    ).stdout
    rows = [line.split(",") for line in out.splitlines()[1:]]
    return [{"name": n.strip(), "used": u.strip()} for n, u in rows if n]


async def schedule(jobs: list[Job], pool: Optional[asyncio.Queue] = None) -> dict[str, State]:
    results: dict[str, State] = {}
    total = sum(j.gpus for j in jobs)                    # builtins: sum, len, range, print
    for index, job in enumerate(jobs):
        if job.gpus > total:                              # control flow keywords
            results[job.name] = State.FAILED
            continue
        elif not NODE_PATTERN.match(job.name):
            print("bad name", job.name, file=None)
        else:
            await asyncio.sleep(0)                        # await is a keyword too
            results[job.name] = State.RUNNING
    return results


def classify(code: int) -> str:
    match code:                                           # soft keywords: match, case
        case 0:
            return "ok"
        case 1 | 2:
            return "warn"
        case _:
            return "error"


class Registry:
    _instance: "Registry | None" = None       # a type in a string annotation

    def __init__(self, root: Path = Path("/var/lib/gpu")) -> None:
        self.root = root
        self.jobs: dict[str, Job] = {}

    def add(self, job: Job) -> None:
        self.jobs[job.name] = job            # attribute access: self.jobs
        assert job.gpus >= 0, "gpus must not be negative"

    def __repr__(self) -> str:               # dunder: special method name
        return f"Registry({len(self.jobs)} jobs)"


if __name__ == "__main__":
    reg = Registry()
    reg.add(Job("train-llm", gpus=8, tags=["nightly", "big"]))
    square = lambda x: x * x                 # lambda, an operator, a name
    print(square(7) // 2 ** 3 % 5, not DEBUG and True or False)
    result = asyncio.run(schedule(list(reg.jobs.values())))
    print(f"{len(result)} job(s):", ", ".join(f"{k}={v.value}" for k, v in result.items()))

# ---- lines the UI-state script looks for -------------------------------------------------
undefined_name + 1                           # DIAG: error  (undefined name)
unused = 42                                  # DIAG: warn   (unused variable)
value = int("7")                             # DIAG: info   (prefer a constant)
legacy = list(range(3))                      # DIAG: hint   (could be a comprehension)
SEARCH_TARGET = "retry retry retry"          # SEARCH: retry
