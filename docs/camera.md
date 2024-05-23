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

### Camera Models

Just a visual aid to understand the different camera types.  Look at is a camera that has a fixed point that it is looking at.

[Camera Models](images/camera_modes.png)

### Look-at Transformation

The most popular way of creating the view matrix is using a camera LookAt() function.  This returns a matrix that can be used to multiply the vertices to convert them to camera/view space.

Camera will have a position and an orientation.  Then we have an eye point for the camera and a target point.

We need to do two important transformations:

1. Translating the whole scene inversely from the camera eye position to the origin (matrix M<sub>T</sub>).
2. Rotating the scene with th ereverse orientation (matrix M<sub>R</sub>), so that the camera is positioned at the origin and facing the positive z-axis.

M<sub>view</sub> = M<sub>R</sub> * M<sub>T</sub> = 
