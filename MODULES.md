#Modules and Libraries used in this engine

#### Simple Tiled Implementation
Loads [Tiled](http://www.mapeditor.org/) maps. It is very feature rich and supports the rendering of tiled maps, animated tiles, and has a neat plugin system for implementing other libraries for use with it.

#### HC
Collision library.

#### Hump
A utility library. Contains many features, including a camera, 2d vector manipulation, signals, classes, and gamestates.

#### anim
Animation library. Includes a Track type which interpolates a single value with
an interpolation(linear, floor, cubic, etc.), An animation type that serves as
a collection of tracks, and an AnimationPlayer type which which contains
multiple animations which can be played. 

#### input
Small input library. Comprised of three parts: Events created from user input,
Event Matches which are tested against each event, and Event managers which process Events.

#### dkjson
Reads/writes to and from json files.

#### matrix3
A 3x3 matrix library.

#### transform
A library used to generate matrix3. Makes it easier to transform objects than with pure matrices.

#### ncs
A node-component system, the backbone of this entire engine. A node is a hierarchy; a transform done on one node affects all of its child nodes. Every node can have any number of components. Examples of components include 'camera', 'drawable_circle', 'tween', 'spritemap', 'collisionbody', etc.
