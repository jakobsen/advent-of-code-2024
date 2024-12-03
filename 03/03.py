import re
from heapq import heappop, heappush
from pathlib import Path
from typing import Literal, NamedTuple


class Instruction(NamedTuple):
    start_idx: int
    behavior: Literal["do", "don't"]


code = Path("./input.txt").read_text()
instructions = []
for m in re.finditer(r"do\(\)", code):
    heappush(instructions, Instruction(m.start(), "do"))

for m in re.finditer(r"don't\(\)", code):
    heappush(instructions, Instruction(m.start(), "don't"))

mul_instructions = re.finditer(r"mul\((\d+),(\d+)\)", code)

current_instruction = Instruction(0, "do")
next_instruction = heappop(instructions)
part1 = 0
part2 = 0
for m in mul_instructions:
    left, right = (int(x) for x in m.groups())
    part1 += left * right

    idx = m.start()
    while next_instruction is not None and idx > next_instruction.start_idx:
        current_instruction = next_instruction
        if instructions:
            next_instruction = heappop(instructions)
        else:
            next_instruction = None
    if current_instruction.behavior == "don't":
        continue
    part2 += int(left) * int(right)


print(part1)
print(part2)
