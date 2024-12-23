from pathlib import Path
from collections import defaultdict

ns = defaultdict(set)
for line in Path("input.txt").read_text().split():
    a, b = line.split("-")
    ns[a].add(b)
    ns[b].add(a)

triplets = set()
for a in ns:
    for b in ns[a]:
        in_common = ns[a] & ns[b]
        for c in in_common:
            triplets.add(tuple(sorted([a, b, c])))
ans = 0
for t in triplets:
    for x in t:
        if x.startswith("t"):
            ans += 1
            break
print("Part 1:", ans)


def find_clique(graph, start_node):
    clique = set([start_node])
    for v in graph:
        should_add = True
        for u in clique:
            should_add = should_add and v in graph[u]
        if should_add:
            clique.add(v)
    return clique


largest_clique = set()
for node in ns:
    candidate = find_clique(ns, node)
    if len(candidate) > len(largest_clique):
        largest_clique = candidate
print("Part 2:", ",".join(sorted([x for x in largest_clique])))
