# brain_tumor_segmentation_classificaiton
Using Digital Signal Processing to segment and classify brain tumors from TCIA (The Cancer Imaging Archive) DICOM images 


## Problem. A brief description of the problem you intend to work on.
* We would like to perform segmentation and classification of brain tumor images, obtained from a database of radiological images of healthy and tumor tissues.

## Tools. A brief description of the tools you will use. 
* Firstly, we plan to use the TCIA (The Cancer Imaging Archive) for a large set of images as our dataset. They are stored in DICOM format which can be imported in MATLAB.
* We first need to segment the tumor region in the images. To classify the tumorous region, we plan to study the pixel intensity of the region. 
* We then can use a Fast Fourier Transform (FFT) to represent the images in the frequency domain, and filter for different signatures    corresponding to diseased regions. We will also explore other DSP techniques 

## Desired outcomes. What results do you hope to obtain? What would an overwhelming success look like? What obstacles might you encounter?
* We hope to be able to effectively segment and classify the tumor images, with an acceptable probability of detection with low false positive rate. This will be determined based on the data we are working with, and with more meticulous research on the current state of classifying brain tumor images.
* Overwhelming success would be an classification rate that matches the industry standard.
* We might run into obstacles if our data set is not diverse enough. We are working with a public database of images, and some collections of data are not as thorough as others. This will have to go into consideration when we finalize which images we will be using.
* Using pixel intensity as our metric for classification might provide challenges, especially when we import our data into MATLAB and Python and run the risk of image quality reductions.

## References. What literature have you looked at related to the topic? 
* https://archive.org/details/indexing_theides_219
* https://wiki.cancerimagingarchive.net/display/Public/QIN-BRAIN-DSC-MRI
* http://ieeexplore.ieee.org/document/6804437/

