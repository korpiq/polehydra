
function point_on_arc(r, degrees, h) = 
    [ r * sin(degrees), r * cos(degrees), h ];

function points_on_arc (r, total_points, h) =
    [
        for (current_point = [0 : total_points - 1])
            point_on_arc( r, current_point * 360 / total_points, h )
    ];

function points_in_2d(points) =
    [ for (point = points) [ point[0], point[1] ] ];

function connect_points(points, offset) =
    [
        concat(
            [for (i = [0 : len(points) - 1]) i + offset],
            len(points) > 3 ? offset : [] // triangles may not close
        )
    ];

function triangle_pair(first_a, first_b, max_a, max_b) =
    let (
        next_a = (first_a + 1) % max_a,
        next_b = (first_b + 1 >= max_b ? max_a : first_b + 1)
    )
    [
        [ first_a, next_a, first_b ],
        [ next_a, first_b, next_b ]
    ];

function triangles_between(point_numbers_a, point_numbers_b) =
    let (
        skip_end_of_a = (len(point_numbers_a) > 3 ? 1 : 0),
        skip_end_of_b = (len(point_numbers_b) > 3 ? 1 : 0),
        max_a = len(point_numbers_a) - skip_end_of_a,
        max_b = len(point_numbers_b) - skip_end_of_b + max_a
    )
    [
        for (i = [0:len(point_numbers_a) - 2])
            for (triangle = triangle_pair(
                point_numbers_a[i],
                point_numbers_b[i],
                max_a, max_b
            )) triangle
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

function wall_between_planes(a, b) =
    triangles_between(
        connect_points(a, 0)[0],
        connect_points(b, len(a))[0]
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
