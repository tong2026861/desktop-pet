# -*- coding: utf-8 -*-
"""去除 girl.png 白色背景：从四边泛洪填充，保留角色内部白色"""
from PIL import Image
from collections import deque
import sys

SRC = r"C:\Users\tongguangdong\WorkBuddy\2026-10-26-19-32-50\whale-pet\girl.png"
DST = r"C:\Users\tongguangdong\WorkBuddy\2026-10-26-19-32-50\whale-pet\girl_alpha.png"

img = Image.open(SRC).convert("RGBA")
w, h = img.size
px = img.load()

def is_bg(p):
    # 接近白色或极接近白色的浅灰(容差)
    r, g, b, a = p
    return r > 235 and g > 235 and b > 235

# BFS 从四边所有背景点开始
visited = [[False]*w for _ in range(h)]
q = deque()
for x in range(w):
    for y in (0, h-1):
        if is_bg(px[x, y]) and not visited[y][x]:
            visited[y][x] = True; q.append((x, y))
for y in range(h):
    for x in (0, w-1):
        if is_bg(px[x, y]) and not visited[y][x]:
            visited[y][x] = True; q.append((x, y))

count = 0
while q:
    x, y = q.popleft()
    px[x, y] = (0, 0, 0, 0)
    count += 1
    for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
        nx, ny = x+dx, y+dy
        if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx] and is_bg(px[nx, ny]):
            visited[ny][nx] = True
            q.append((nx, ny))

img.save(DST)
print(f"done: cleared {count} px of {w*h}, saved {DST}")
