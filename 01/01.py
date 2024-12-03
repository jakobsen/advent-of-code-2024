from collections import Counter

list1, list2 = [], []
with open("input.txt") as f:
    for line in f:
        x, y = (int(num) for num in line.strip().split())
        list1.append(x)
        list2.append(y)

diffs = [abs(x - y) for x, y in zip(sorted(list1), sorted(list2))]
count = Counter(list2)

print(sum(diffs))

totals = 0
for num in list1:
    totals += num * count.get(num, 0)
print(totals)
