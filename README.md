Polehydra
=========

OpenScad library providing functions and modules to make it easier to generate polyhedrons.

Usage
-----

	use <lib/polehydra.scad>

	list_of_edges = [
		lib_polehydra_points_on_arc(r=3, points=10, height=0),
		lib_polehydra_points_on_arc(r=9, points=30, height=4),
		lib_polehydra_points_on_arc(r=3, points=10, height=9)
	];

	lib_polehydra_spheroid(list_of_edges);

See examples/ directory for more examples.

