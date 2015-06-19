use <../polehydra.scad>

lib_polehydra_toroid([
    lib_polehydra_points_on_arc(6, 3, 0),
    lib_polehydra_points_on_arc(6, 30, 5),
    lib_polehydra_points_on_arc(6, 30, 6),
    lib_polehydra_points_on_arc(5.4, 30, 7),
    lib_polehydra_points_on_arc(3, 8, 9),
    lib_polehydra_points_on_arc(3, 20, 12, 15),
    lib_polehydra_points_on_arc(6, 20, 15),
    lib_polehydra_points_on_arc(6, 20, 18),
    lib_polehydra_points_on_arc(5, 20, 18),
    lib_polehydra_points_on_arc(3, 12, 14),
    lib_polehydra_points_on_arc(2, 6, 12),
    lib_polehydra_points_on_arc(3, 3, 0),
]);
