
function lib_polehydra_points_on_arc
    (r, points, height = 0, arc_start = 0, arc_degrees = 360) =
    [
        for (current_point = [0 : points - 1])
            let ( degrees =
                arc_start + current_point * arc_degrees / points )
                [ r * sin(degrees), r * cos(degrees), height ]
    ];

function lib_polehydra_connect_points(points, offset = 0) =
    points < 3 ? [] :
    [
        concat(
            [for (i = [0 : len(points) - 1]) i + offset],
            len(points) > 3 ? offset : [] // triangles may not close
        )
    ];

function lib_polehydra__distance_squared(point_a, point_b) =
    pow((point_b[0] - point_a[0]), 2) +
    pow((point_b[1] - point_a[1]), 2) +
    pow((point_b[2] - point_a[2]), 2);

function lib_polehydra_distances_squared
    (source_point, target_points) =
    [
        for (i = [0 : len(target_points) - 1])
            lib_polehydra__distance_squared
                (source_point, target_points[i])
    ];

function lib_polehydra_index_of_smallest(distances) =
    let ( smallest_distance = min(distances) )
    [
        for (i = [0 : len(distances) - 1])
            if (distances[i] == smallest_distance) i
    ][0];

function lib_polehydra__is_closer_to(point_a, point_b, target_point) =
    lib_polehydra__distance_squared(point_a, target_point) <
        lib_polehydra__distance_squared(point_b, target_point);

function lib_polehydra_triangles_between_edges(
    edge_a, edge_b, a_offset, b_offset,
    a_at, b_at, a_end, b_end, a_finished, b_finished
) =
    let (
        next_a_at = (a_at + 1) % len(edge_a),
        next_b_at = (b_at + 1) % len(edge_b)
    )
    lib_polehydra__is_closer_to
        (edge_a[next_a_at], edge_a[a_at], edge_b[next_b_at]) ?
        concat(
            [[
                a_offset + a_at,
                b_offset + b_at,
                a_offset + next_a_at
            ]],
            a_finished ? [] :
                lib_polehydra_triangles_between_edges(
                    edge_a, edge_b, a_offset, b_offset,
                    next_a_at, b_at, a_end, b_end,
                    next_a_at == a_end, b_finished
                )
        )
    :
        concat(
            [[
                a_offset + a_at,
                b_offset + b_at,
                b_offset + next_b_at
            ]],
            b_finished ? [] :
                lib_polehydra_triangles_between_edges(
                    edge_a, edge_b, a_offset, b_offset,
                    a_at, next_b_at, a_end, b_end,
                    a_finished, next_b_at == b_end
                )
        )
    ;

function lib_polehydra__wall_between_edges(edge_a, edge_b, a_offset, b_offset) =
    let (
        first_b_at =
            lib_polehydra_index_of_smallest
                (lib_polehydra_distances_squared(edge_a[0], edge_b))
    ) lib_polehydra_triangles_between_edges(
        edge_a, edge_b, a_offset, b_offset,
        0, first_b_at, 0, first_b_at,
        false, false
    );

bottom = lib_polehydra_points_on_arc(5, 3, 0);
top = lib_polehydra_points_on_arc(3, 9, 9);
all_points_3d = concat(bottom, top);
wall = lib_polehydra__wall_between_edges(bottom, top, 0, len(bottom));
all_faces = concat(
    lib_polehydra_connect_points(bottom, 0),
    wall,
    lib_polehydra_connect_points(top, len(bottom))
);

polyhedron(all_points_3d, all_faces);
