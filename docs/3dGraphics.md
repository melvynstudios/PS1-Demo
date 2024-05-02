# 3d Graphics

- Vertex, are points in space, (x, y, z)
- Polygon face is defined by connecting vertices.
  - Quad faces are defined by 4 vertices
	- Triangle faces are defined by 3 vertices

## Projection

- Perspective projection, used for 3d graphics, field of view.
- Orthographic projection, used for 2d graphics, screen size.

![projection](3dProjection.png)

### Perspective projection

**Perspective divide:**  Xscreen = Xworld / z    and    Yscreen = Yworld / z

The GTE does this quickly for us on the PS1.

### Vertices

![vertices](vertices.png)

A cube is a a 3d mesh.  It consists of vertices and faces.  The origin in the image becomes the pivot point, all the vertices are based off the origin of the mesh.  (0, 0, 0)

```c
SVECTOR vertices[] = {
	{ -128, -128, -128 },
	{  128, -128, -128 },
	{  128, -128,  128 },
	{ -128, -128,  128 },
	{ -128,  128, -128 },
	{  128,  128, -128 },
	{  128,  128,  128 },
	{ -128,  128,  128 }
};

short faces[] = {
	0, 3, 2,
	0, 2, 1,
	4, 0, 1,
	4, 1, 5,
	7, 4, 5,
	7, 5, 6,
	5, 1, 2,
	5, 2, 6,
	2, 3, 7,
	2, 7, 6,
	0, 4, 7,
	0, 7, 3
};
```

The faces are indices of how the vertices are connected to make a face or triangle.  Uses clockwise orientation to show that it is pointed towards the camera.  If we use counterclockwise, it would be pointing away from the camera.
Similarly clockwise orientation would point up, and counterclockwise would point down.  This is how 3d math works.

![faces](faces.png)



The SVECTOR is part of the LIBGTE library.

We have the following primitives:
- Matrix
- Vector
- SVector
- CVector
	- used for colors
- DVector
	- 2d for x and y

## Geometry Transformation Engine

- GTE is a vector & matrix high-speed geometric processor
- GTE has its own multiplier, accumulator, and divider.  [Registers]
- It is implemented as a coprocessor 2 under the MIPS architecture
                                                    __________
                                                    | Memory |
                                                    ----------
                                                         |
                                                         |
//-------------------------------------------------------------------------//
                         |
                         |
                      -------
                      | CPU |
                      -------
                       [GTE]
                       |cp2|

### GTE Features

- Fast vector/matrix calculations
- Fast coordinate transformations
- Fast perspective projections
- Fast lighting calculations

### CPU Block Diagram

![CPU Block](CPU-Block.png)

## 3d Transformations

There is a pipeline to handle 3d transformations.

1. When we start, the vertices are in `model space` (local coordinate system as they are defined in a modeling software like blender)
	1. This means that all the vertices are local and relative to the origin point of the model.
1. Start by transforming the vertices of the model into the world space.  This means multiply by world matrix.
	1.  Transition the vertices of the model into the `world space`, which puts the model and its transformations in the world matrix.
2. Next we convert the vertices into the view `space/camera space`.  This means multiply by view matrix.
	1.  This puts the model into the camera view.  The new coordinate system becomes the eye of the camera
3. The scene is now in view space and can now be projected into screen space. (perform the perspective divide)
	1. We can use the GTE do do this for us.
4. Rasterize the scene to the screen.

Transformations are handled by the GTE using vectors.

```c
SVECTOR rotation    = {0, 0, 0};          // Declare the rotation vector {x, y, z} ... SVECTOR is small vector because the values are not going to be big
VECTOR  translation = {0, 0, 480};        // Declare the translation vector {x, y, z}
VECTOR  scale       = {ONE, ONE, ONE};    // Declare the scale vector {x, y, z}

MATRIX world        = {0};                // Declare the world matrix
```

Functions that are available to use for handling world objects:

func|description
---|---
RotMatrix(&rotation, &world);|Populate rotation values into world matrix
TransMatrix(&world, &translation);|Populate translation values into world matrix
ScaleMatrix(&world, &scale);|Populate scale values into world matrix
SetRotMatrix(&world);| Sets the rotation matrix to be used by GTE
SetTransMatrix(&world);| Sets the translation matrix to be used by GTE

Example code:

```c
SVECTOR rotation    = {0, 0, 0};
VECTOR  translation = {0, 0, 480};
VECTOR  scale       = {ONE, ONE, ONE};

MATRIX world        = {0};

void Update(void) {
	ClearOTagR(ot[currentBuffer], OT_LENGTH);   // Clear OT

	RotMatrix(&rotation, &world);
	TransMatrix(&world, &translation);
	ScaleMatrix(&world, &scale);

	SetRotMatrix(&world);
	SetTransMatrix(&world);

	poly = (POLY_F3*) nextprim;
	SetPolyF3(poly);
	setRGB0(poly, 255, 0, 0);

	// Rotate, translate, and project the vertices & outputs the results into a primitive
	otz = 0;  // Ordering table z for this triangle
	otz += RotTransPers(&vertices[faces[0]], (long*) &poly->x0, &p, &flg);
	otz += RotTransPers(&vertices[faces[1]], (long*) &poly->x1, &p, &flg);
	otz += RotTransPers(&vertices[faces[2]], (long*) &poly->x2, &p, &flg);
	otz /= 3;    // Average the z values

	addPrim(ot[currentBuffer][otz], poly);
	nextprim += sizeof(POLY_F3);
}
```
