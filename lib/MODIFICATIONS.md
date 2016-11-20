This engine makes many modifications to its base libraries. The original creators of these libraries are free to copy and implement any changes that have made to their library. Many changes to these libraries are made to make them work together, or to implement more features.

#### Simple Tiled Implementation
 * Support for Tile Collections.
 * Added a HC plugin.
 * Now draws background color.
 * Removed Canvas when drawing.
 * Added padding for tiles so that they don't bleed.

#### HC
 * Removed many assertions made for polygons. This is because the HC plugin for STI creates a shape for *every* object, regardless of whether it is actually used or not. It would be quite a headache if every single polygon and polyline could not intersect. The main changes are that polygons can now be comprised of any number of vertices, including 0, 1, and 2.
 * Added grouping to shapes. A shape belongs to only one group, but can have any number of layers. A shape of a given group can only collide with objects in any of its layers.
 * Small change to how ConvexShape returns its separation.
