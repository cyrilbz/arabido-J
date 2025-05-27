# arabido-J

Two tools to study plant trays. An example image below:

![Screenshot](r_55_04_20250407.jpg)

A first tool allows image registration. A second tool performs plant segmentation (through an Ilastik model that must have been trained previously) and computes plant area per plant pot (see result below). More informations can be found in the pdf file in the repository.


Registration_trays.ijm : imageJ macro for semi-automatic registration of plant trays.

segmentation_analyze_pots.ijm : imageJ macro for plant segmentation and pot by pot analysis. Requires the Ilastik software (https://www.ilastik.org/) and the ilastik & MorpholibJ ImageJ plugins (add update sites: ilastik, IJPB-plugins).

arabido_analysis.py: Python code to analyse the results of the .csv file (output from the segmentation macro). Requires the Matplotlib and Pandas librairies.


![Screenshot](result.png)
