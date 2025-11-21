# arabidoJ-4loc

Plant segmentation for field arabidopsis.

## Training details

This model was trained using [BiaPy](https://biapyx.github.io/) [1]. Complete information on how to train this model can be found in BiaPy's documentation, specifically under [semantic segmentation workflow](https://biapy.readthedocs.io/en/latest/workflows/semantic_segmentation.html) description. If you want to reproduce this model training please use the configuration described below (Technical specification section).

### Training Data

- Imaging modality: blablabla
- Dimensionality: 2D
- Source: blablabla ; DOI: blablabla

### Training procedure
#### Preprocessing
- Zero mean and unit variance normalization. Mean value calculated from the training data. Std value calculated from the training data.
- Normalization and percentile clipping values calculated from the complete image.

## Evaluation

### Metrics

In the case of semantic segmentation the following metrics are calculated:
- Intersection over Union (IoU), also referred as the [Jaccard index](https://en.wikipedia.org/wiki/Jaccard_index), is essentially a method to quantify the percent of overlap between the target mask and the prediction output.

More info in [BiaPy documentation](https://biapy.readthedocs.io/en/latest/workflows/semantic_segmentation.html#metrics).
### Results
#### Training results
The validation data was extracted from the training data using a split of 20.0%.
The final metrics obtained from the training phase are:
- Train loss: 0.0806272029876709
- Train IoU: 0.8522657305002213
- Validation loss: 0.08149516582489012
- Validation IoU: 0.8505128026008606

**Clarifications on the terminology:**
We provide metrics calculated in different manners. Below are explanations for the terms used:
- Metrics labeled as 'per image' are computed by feeding the complete images into the model and evaluating the predictions on the whole image

## Technical specifications
This model was trained using BiaPy (v3.6.7). To reproduce the results, make sure to install the same BiaPy version and run it with the configuration provided below. You will need to change the paths to the data accordingly.
```yaml
AUGMENTOR:
  AFFINE_MODE: reflect
  AUG_SAMPLES: true
  BRIGHTNESS: true
  BRIGHTNESS_FACTOR: (-0.2, 0.2)
  CONTRAST: true
  CONTRAST_FACTOR: (-0.2, 0.2)
  ELASTIC: true
  ENABLE: true
  E_ALPHA: (16, 20)
  E_MODE: constant
  E_SIGMA: 4
  HFLIP: true
  RANDOM_ROT: true
  RANDOM_ROT_RANGE: (-180, 180)
  VFLIP: true
  ZOOM: true
  ZOOM_RANGE: (0.8, 1.2)
DATA:
  EXTRACT_RANDOM_PATCH: true
  PATCH_SIZE: (320,320,3)
  REFLECT_TO_COMPLETE_SHAPE: true
  TEST:
    ARGMAX_TO_OUTPUT: true
    CHECK_DATA: true
    IN_MEMORY: false
    LOAD_GT: false
    OVERLAP: (0,0)
    PADDING: (32,32)
    PATH: /home/cbozonnet/Documents/image_processing/BiaPy/test_complet/raw
    RESOLUTION: (1,1)
  TRAIN:
    CHECK_DATA: true
    GT_PATH: /home/cbozonnet/Documents/image_processing/BiaPy/train_complet/label
    IN_MEMORY: false
    OVERLAP: (0,0)
    PADDING: (0,0)
    PATH: /home/cbozonnet/Documents/image_processing/BiaPy/train_complet/raw
    REPLICATE: 1
  VAL:
    FROM_TRAIN: true
    IN_MEMORY: true
    RANDOM: true
    RESOLUTION: (1,1)
    SPLIT_TRAIN: 0.2
LOSS:
  CLASS_REBALANCE: true
  TYPE: DICE
MODEL:
  ARCHITECTURE: resunet
  DROPOUT_VALUES:
  - 0.0
  - 0.0
  - 0.0
  - 0.0
  - 0.0
  FEATURE_MAPS:
  - 16
  - 32
  - 64
  - 128
  - 256
  N_CLASSES: 2
PROBLEM:
  NDIM: 2D
  TYPE: SEMANTIC_SEG
SYSTEM:
  NUM_CPUS: -1
  NUM_WORKERS: 2
  SEED: 0
TEST:
  ENABLE: true
  VERBOSE: true
TRAIN:
  BATCH_SIZE: 16
  ACCUM_ITER: 1
  ENABLE: true
  EPOCHS: 750
  LR: 0.0001
  LR_SCHEDULER:
    MIN_LR: 1.0e-05
    NAME: warmupcosine
    WARMUP_COSINE_DECAY_EPOCHS: 10
  OPTIMIZER: ADAMW
  OPT_BETAS: (0.9, 0.999)
  PATIENCE: 150
  W_DECAY: 0.02

```

## Contact
For problems with BiaPy library itself checkout our [FAQ & Troubleshooting section](https://biapy.readthedocs.io/en/latest/get_started/faq.html).

For questions or issues with this models, please reach out by:
- Opening a topic with tags bioimageio and biapy on [image.sc](https://forum.image.sc/)
- Creating an issue in https://github.com/BiaPyX/BiaPy

Model created by:
- Cyril Bozonnet (github: cyrilbz)


## References
> [1] Franco-Barranco, Daniel, et al. "BiaPy: Accessible deep learning on bioimages." Nature Methods (2025): 1-3.
> 
> [2] Franco-Barranco, Daniel, Arrate Muñoz-Barrutia, and Ignacio Arganda-Carreras. "Stable deep neural network architectures for mitochondria segmentation on electron microscopy volumes." Neuroinformatics 20.2 (2022): 437-450.
