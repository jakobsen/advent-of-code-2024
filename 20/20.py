from pathlib import Path
from collections import deque, Counter
import pprint

path = Path(__file__).parent / "test.txt"
raw_input = path.read_text()

g = set()
start = None
end = None
lines = raw_input.splitlines()
n = len(lines)
m = len(lines[0])
for i, line in enumerate(lines):
    for j, tile in enumerate(line):
        match tile:
            case ".":
                g.add((i, j))
            case "S":
                g.add((i, j))
                start = (i, j)
            case "E":
                g.add((i, j))
                end = (i, j)


def get_neighbors(coords: tuple[int, int]) -> list[tuple[int, int]]:
    i, j = coords
    return [(i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)]


def distance(
    g: set[tuple[int, int]],
    start: tuple[int, int],
    end: tuple[int, int],
    cheat_start: int | None = None,
) -> int | None:
    Q = deque()
    seen = set()
    Q.append(start)
    seen.add(start)
    dist = 0
    while Q:
        v = Q.popleft()
        if v == end:
            return dist
        dist += 1
        seen.add(v)
        neighbors = get_neighbors(v)
        Q.extend(n for n in neighbors if n not in seen and n in g)


def in_bounds(coords, n, m):
    i, j = coords
    return i >= 0 and j >= 0 and i < n and j < m


assert start
assert end
base_dist = distance(g, start, end)
cheats = []
for i in range(n):
    for j in range(m):
        possible_cheats = [
            ((i, j), v)
            for v in get_neighbors((i, j))
            if (v not in g or (i, j) not in g) and in_bounds(v, n, m)
        ]
        for cheat in possible_cheats:
            g_ = g.copy()
            g_.update(cheat)
            cheats.append(distance(g_, start, end) - base_dist)
pprint.pp(Counter(cheats))
