using FuzzySets, Test

x = [1, 4.5]
y = [3.5, 4]
@test FuzzySets.distance(x, y) == 2.5495097567963922