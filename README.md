# shadow-boundary-detection

This project is an implementation of the paper [What Characterizes a Shadow Boundary
under the Sun and Sky](http://www.cs.northwestern.edu/~xhu414/papers/11iccv_shadow.pdf).

The 36D feature vector consists 12 dimensions times 3 scales. We interpret the 3 scales
as the Gaussian smoothed image with σ = 0, 1, 2, where the case σ = 0 refers to the
original image. Gaussian filter size is defined as 6*σ+1. As for the 12 dimensions, which
can be split into 4 groups, we only talk about the first and last features here since the rest
are trivial.

To compute the first feature, illumination ratio of sun and sky, we need to define the
Gaussian weighted average of pixels on both sides of an edge pixel. Here we use an
oriented 2D Gaussian derivative filter aligned to the direction of boundary according to
[Lalonde et al](http://repository.cmu.edu/cgi/viewcontent.cgi?article=1783&context=robotics). Keep its positive entries and set the rest to 0, normalize it and apply it.
To improve efficiency, we avoid convolving the whole image with the filter, but calculate
only the convolution value at the edge pixel. This value is exactly the Gaussian average
of one side. Rotate the filter by 180 degrees and repeat we will get the average of the
other side.

To compute the last feature, edge width, we simply traverse along the direction of
gradient and the opposite direction, from the edge pixel to a certain furthest location or a
pixel whose gradient magnitude is below a specified threshold ratio of the edge pixel.
We test on the LAL dataset. Same as the paper, we randomly select 30000 shadow and
30000 non-shadow edge pixels from 100 images for training, 10000 and 10000 from the
rest 35 for testing. The result:

![Alt text](https://raw.githubusercontent.com/spin0za/shadow-boundary-detection/master/roc.jpg)

## Demo image:

![Alt text](https://raw.githubusercontent.com/spin0za/shadow-boundary-detection/master/demoDetected.jpg)

Using an excessively extensive edge linking method may make the
shadow boundary complete but would increase false positive too. Our result comes from
edge linking based on 8-connectivity, which seem to be a tradeoff between false positive
rate and boundary expression.
