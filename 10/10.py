from pathlib import Path
from collections import deque


grid = [[int(x) for x in line] for line in Path("input.txt").read_text().split()]
trailheads = [(i, j) for (i, line) in enumerate(grid) for (j, x) in enumerate(line) if x == 0]


def bfs(start: tuple[int, int], grid: list[list[int]]) -> list[int]:
    seen = set([start])
    Q = deque([start])
    while Q:
        v = Q.popleft()
        seen.add(v)
        for coords in get_neighbours(v, grid):
            Q.append(coords)
    return [grid[i][j] for (i, j) in seen]


def rank(tile: tuple[int, int], grid: list[list[int]]) -> int:
    i, j = tile
    if grid[i][j] == 9:
        return 1
    neighbours = get_neighbours(tile, grid)
    if not neighbours:
        return 0
    return sum(rank(neighbour, grid) for neighbour in neighbours)


def get_neighbours(coords: tuple[int, int], grid: list[list[int]]) -> list[tuple[int, int]]:
    i, j = coords
    n = len(grid)
    m = len(grid[0])
    height = grid[i][j]
    neighbours = []
    for dy, dx in [(-1, 0), (0, 1), (1, 0), (0, -1)]:
        if 0 <= i + dy < n and 0 <= j + dx < m and grid[i+dy][j+dx] == height + 1:
            neighbours.append((i+dy, j+dx))
    return neighbours


p1 = 0
for trailhead in trailheads:
    p1 += sum(x == 9 for x in bfs(trailhead, grid))
print(f"Part 1: {p1}")

p2 = sum(rank(trailhead, grid) for trailhead in trailheads)
print(f"Part 2: {p2}")
