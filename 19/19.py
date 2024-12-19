import functools
from pathlib import Path
from pprint import pp


@functools.cache
def possible_variants(patterns: tuple[str], design: str) -> int:
    if design == "":
        return 1

    candidates = [pattern for pattern in patterns if design.startswith(pattern)]
    if not candidates:
        return 0

    return sum(
        possible_variants(patterns, design[len(pattern) :]) for pattern in candidates
    )


def parse(path: Path) -> tuple[tuple[str, ...], list[str]]:
    patterns, designs = path.read_text().split("\n\n")
    patterns = tuple(patterns.split(", "))
    designs = [design for design in designs.split("\n") if design]
    return patterns, designs


if __name__ == "__main__":
    path = Path(__file__).parent / "input.txt"
    patterns, designs = parse(path)
    print(sum(possible_variants(patterns, design) for design in designs))
