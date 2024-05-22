# Camera Space

With a camera we are looking from a 0,0,0 viewpoint.  So we need an object, called a camera, that we can use to give us a perspective of the world.

The camera is going to have a position and an orientation.  So we will have a camera transformation.

## Define a camera

It has a position and orientation

```c
typedef struct {
	VECTOR position;
	SVECTOR rotation;
	MAXTRIX lookat;
} Camera;
```

**LOOKAT:** is a matrix will position everything to align with the camera.  It is a matrix, and I'll have to go investigate the math on the transformations of the world matrix.

### Lookat matrix

the lookat transformation is responsible for transforming all the vertices of the scene, rotation, translate, convert them into a new coordinate system where the new origin point of the camera is the center of the camera.

The `Camera Transformation` is a stage of the graphics pipeline that transforms all the vertices of our scene, multiplying them by the `view matrix` and converting them to a _new coordinate system_ whose *origin* is the camera *eye* point looking at the positive z-axis.

### Render pipeline

[render pipeline](images/render_pipeline.png)

`local space` is the model space.
`world space` is positioning the 3d model in the world.
`camera space` rotate and translate objects to align with the camera.
`clip space` is culled so we only render objects that are in the camera's field of view