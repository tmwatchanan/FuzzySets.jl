function u_pcm(x, c, η; m)
    d_squared = FuzzySets.euclidean_distance(x, c; squared=true)
    u = 1 / (1 + (d_squared / η)^(1 / (m - 1)))
    u
end
