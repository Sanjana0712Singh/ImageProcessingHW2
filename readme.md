================================================================================
README — CAI 4842 Image Processing Fundamentals
Assignment 2: Histogram Modification and Color Processing
Sanjana Singh
================================================================================

--------------------------------------------------------------------------------
1. COMPILING THE PROJECT
--------------------------------------------------------------------------------
The project is built using the provided Makefile. To compile, navigate to the
project directory and run:

    cd ~/DIPCODE_Linux/project
    make clean

This will:
  1. Recompile the iptools library (image.cpp + utility.cpp) into ../lib/libiptools.a
  2. Compile and link iptool.cpp against the library to produce bin/iptool

To run the program:

    cd ~/DIPCODE_Linux/project/bin
    ./iptool parameters.txt
--------------------------------------------------------------------------------
2. LIST OF IMPLEMENTED FUNCTIONS
--------------------------------------------------------------------------------

--- HW2 FUNCTIONS ---

  histStretchA  : Algorithm A — Modified histogram stretching for greyscale ROI.
                  Computes optimal threshold T, finds dark pixels (I < T),
                  and applies a piecewise linear mapping to stretch dark pixels
                  to [0, 255]. Pixels >= T are unchanged.

  histStretchB  : Algorithm B — Local quarter stretching for greyscale ROI.
                  Splits the ROI into 4 quadrants and applies Algorithm A
                  independently to each quadrant.

  greyAugment   : Greyscale augmentation. Generates 12 output images from
                  a single ROI: Original, Algorithm A processed, and Algorithm B
                  processed — each rotated at 0, 90, 180, and 270 degrees.
                  Output files are auto-named (see Section 4).

  colorHistStretch : Algorithm A applied to one or more color channels.
                  Channel is selected via a mask parameter (see Section 3).

  colorAugment  : Color augmentation. Generates 20 output images from a single
                  ROI: Original, A on R only, A on G only, A on B only, and A
                  on all channels — each rotated at 0, 90, 180, and 270 degrees.
                  Output files are auto-named (see Section 4).

--- HW1 FUNCTIONS (carried over, updated to rectangular ROI format) ---

  add           : Add a constant intensity value to all pixels in the ROI.
  binarize      : Binarize pixels in ROI (below threshold → 0, above → 255).
  decrease      : Decrease brightness of pixels below threshold in ROI.
  rotate        : Rotate a square ROI in-place by 90, 180, or 270 degrees.
  scale         : Scale a square ROI by a ratio, then rotate.
  brightnessRotate : Add brightness to square ROI, then rotate.
  colorModify   : Apply multiplicative and additive color modification with
                  optional rotation to a square ROI.
--------------------------------------------------------------------------------
3. PARAMETER FILE FORMAT
--------------------------------------------------------------------------------

Each line in the parameter file describes one complete operation:

    inputFile outputFile numROIs [ROI_1_params] [ROI_2_params] ... [ROI_N_params]

All values are space-separated on a single line.
Lines beginning with # are treated as comments and skipped.

ROI parameters per ROI (repeated numROIs times):

    x  y  roiRows  roiCols  functionName  [functionParams]

  x        : Top-left row of the ROI (integer)
  y        : Top-left col of the ROI (integer)
  roiRows  : Height of the ROI in pixels (integer)
  roiCols  : Width of the ROI in pixels (integer)

Function-specific parameters:

  add             value
    value         : Integer to add to each pixel (can be negative)

  binarize        threshold
    threshold     : Integer threshold [0–255]

  decrease        threshold  value
    threshold     : Pixels below this are decreased
    value         : Amount to subtract

  rotate          angle
    angle         : 90, 180, or 270 (degrees clockwise). ROI must be square.

  scale           ratio  angle
    ratio         : Float scale factor (e.g. 2.0, 0.5)
    angle         : 0, 90, 180, or 270. ROI must be square.

  brightnessRotate  br  angle
    br            : Integer brightness increase
    angle         : 90, 180, or 270. ROI must be square.

  colorModify     moreC  ac  angle
    moreC         : Float multiplicative factor for all channels
    ac            : Integer additive value for all channels
    angle         : Rotation angle (0, 90, 180, 270, or arbitrary degrees)

  histStretchA    (no additional parameters)

  histStretchB    (no additional parameters)

  greyAugment     (no additional parameters)
                  Saves 12 files automatically. outputFile is saved as
                  an unchanged copy of the source image.

  colorHistStretch  channelMask
    channelMask   : 0 = Red only
                    1 = Green only
                    2 = Blue only
                    3 = All channels independently

  colorAugment    (no additional parameters)
                  Saves 20 files automatically. outputFile is saved as
                  an unchanged copy of the source image.

--------------------------------------------------------------------------------
4. AUTO-GENERATED OUTPUT FILE NAMING
--------------------------------------------------------------------------------

greyAugment produces 12 files named:
    <outputBase>_roi<roiIndex>_<NN>_<version>_r<angle>.pgm

  outputBase : outputFile with extension removed (e.g. "aug_grey" from "aug_grey.pgm")
  roiIndex   : 0-based index of the ROI in the loop
  NN         : 2-digit image number (00–11)
  version    : orig, A, or B
  angle      : 0, 90, 180, or 270

  Example: aug_grey_roi0_04_A_r90.pgm

colorAugment produces 20 files named:
    <outputBase>_roi<roiIndex>_<NN>_<version>_r<angle>.ppm

  version    : orig, A_R, A_G, A_B, or A_all
  Example: aug_color_roi0_12_A_B_r180.ppm

--------------------------------------------------------------------------------
5. EXAMPLE PARAMETER FILE LINES
--------------------------------------------------------------------------------

# Algorithm A on a single 300x300 greyscale ROI
snowman.pgm snowman_1A.pgm 1 200 200 300 300 histStretchA

# Algorithm A on 10 ROIs (each 100x100)
snowman.pgm snowman_1A_10rois.pgm 10 50 50 100 100 histStretchA 50 200 100 100 histStretchA 50 350 100 100 histStretchA 50 500 100 100 histStretchA 200 50 100 100 histStretchA 200 200 100 100 histStretchA 200 350 100 100 histStretchA 200 500 100 100 histStretchA 350 50 100 100 histStretchA 350 200 100 100 histStretchA

# Algorithm B on a single 300x300 greyscale ROI
snowman.pgm snowman_1B.pgm 1 200 200 300 300 histStretchB

# Greyscale augmentation — generates 12 images
snowman.pgm aug_grey.pgm 1 200 200 300 300 greyAugment

# Color histogram stretching — R channel only
minecraft.ppm mine_3A_R.ppm 1 780 1816 400 400 colorHistStretch 0

# Color histogram stretching — all channels
minecraft.ppm mine_3A_all.ppm 1 780 1816 400 400 colorHistStretch 3

# Color augmentation — generates 20 images
minecraft.ppm aug_color.ppm 1 780 1816 400 400 colorAugment

--------------------------------------------------------------------------------
6. INPUT IMAGES USED
--------------------------------------------------------------------------------

  snowman.pgm   : Greyscale PGM image (P5 format), used for 1A, 1B, 1C tests.
  minecraft.ppm : Color PPM image (P6 format, 4032x1960), used for 3A, 3B tests.

Both images are included in the bin/ directory of the submitted ZIP.

--------------------------------------------------------------------------------
7. NOTES
--------------------------------------------------------------------------------

- ROI bounds are checked before processing. Out-of-bounds ROIs are skipped
  with a printed warning and do not crash the program.
- The HW1 rotate, scale, brightnessRotate, and colorModify functions require
  square ROIs (roiRows == roiCols). Rectangular ROIs will produce incorrect
  results for these functions.
- histStretchA and histStretchB work correctly with rectangular ROIs.
- greyAugment and colorAugment work correctly with rectangular ROIs; rotated
  output images have transposed dimensions for 90 and 270 degree rotations.

================================================================================
