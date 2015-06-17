
function point_on_arc(r, degrees, h) = 
    [ r * sin(degrees), r * cos(degrees), h ];

function points_on_arc(r, total_points, h) =
    [
        for (current_point = [0 : total_points - 1])
            point_on_arc( r, current_point * 360 / total_points, h )
    ];

function connect_points(points, offset) =
    [
        concat(
            [for (i = [0 : len(points) - 1]) i + offset],
            len(points) > 3 ? offset : [] // triangles may not close
        )
    ];

function distance_squared(point_a, point_b) =
    pow((point_b[0] - point_a[0]), 2) +
    pow((point_b[1] - point_a[1]), 2) +
    pow((point_b[2] - point_a[2]), 2);

function distances_squared(source_point, target_points) =
    [
        for (i = [0 : len(target_points) - 1])
            distance_squared(source_point, target_points[i])
    ];

function index_of_smallest(distances) =
    let ( smallest_distance = min(distances) )
    [
        for (i = [0 : len(distances) - 1])
            if (distances[i] == smallest_distance) i
    ][0];

function is_closer_to(point_a, point_b, target_point) =
    distance_squared(point_a, target_point) <
        distance_squared(point_b, target_point);

function triangles_between_edges(
    edge_a, edge_b, a_offset, b_offset,
    a_at, b_at, a_end, b_end, a_finished, b_finished
) =
    let (
        next_a_at = (a_at + 1) % len(edge_a),
        next_b_at = (b_at + 1) % len(edge_b)
    )
    is_closer_to(edge_a[a_at], edge_a[next_a_at], edge_b[next_b_at]) ?
        concat(
            [[
                a_offset + a_at,
                b_offset + b_at,
                b_offset + next_b_at
            ]],
            b_finished ? [] :
                triangles_between_edges(
                    edge_a, edge_b, a_offset, b_offset,
                    a_at, next_b_at, a_end, b_end,
                    a_finished, next_b_at == b_end
                )
        )
    :
        concat(
            [[
                a_offset + a_at,
                b_offset + b_at,
                a_offset + next_a_at
            ]],
            a_finished ? [] :
                triangles_between_edges(
                    edge_a, edge_b, a_offset, b_offset,
                    next_a_at, b_at, a_end, b_end,
                    next_a_at == a_end, b_finished
                )
        )
    ;

function wall_between_edges(edge_a, edge_b, a_offset, b_offset) =
    let (
        first_b_at =
            index_of_smallest(distances_squared(edge_a[0], edge_b))
    ) triangles_between_edges(
        edge_a, edge_b, a_offset, b_offset,
        0, first_b_at, 0, first_b_at,
        false, false
    );

bottom = points_on_arc(5, 3, 0);
top = points_on_arc(3, 9, 9);
all_points_3d = concat(bottom, top);
wall = wall_between_edges(bottom, top, 0, len(bottom));
all_faces = concat(
    connect_points(bottom, 0),
    wall,
    connect_points(top, len(bottom))
);

polyhedron(all_points_3d, all_faces);
