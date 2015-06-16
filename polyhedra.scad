
function point_on_arc(r, degrees, h) = 
    [ r * sin(degrees), r * cos(degrees), h ];

function points_on_arc (
        r,
        total_points,
        h
) =
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

function wall_between_planes(a, b) =
    triangles_between(
        connect_points(a, 0)[0],
        connect_points(b, len(a))[0]
    );

sides = 9;
bottom = points_on_arc(3, sides, 0);
top = points_on_arc(3, sides, 9);
all_points_3d = concat(bottom, top);
wall = wall_between_planes(bottom, top);
all_faces = concat(
    connect_points(bottom, 0),
    wall,
    connect_points(top, len(bottom))
);

echo(all_points_3d);
echo(all_faces);
polyhedron(all_points_3d, all_faces);
