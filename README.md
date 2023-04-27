# Accompanying code to "Waves traveling over a map of visual space can ignite short-term predictions of sensory input"

This repository contains the source code and data from

Benigno, Budzinski, Davis, Reynolds, Muller. (2023) Waves traveling over a map of visual space can ignite short-term predictions of sensory input. *Nature Communications*.

The source code reproduces each manuscript figure, with MATLAB code organized as subfolders following individual figure panels. Installation only requires adding the files to the MATLAB path (done automatically where needed). Running the code in the respective panel subfolders will produce a graphical output of the panel from the text. Each script requires only a few minutes to run on a standard desktop workstation.

## Usage

Before running a script (within the `figures` subfolder), make sure the current working directory is the same as the directory in which the script is located. Each script begins with (1) a command to clear the MATLAB command window and any existing variables or figures, and (2) a command adding the `helpers` folder (and additional subfolders) to the path. The helper functions within these subfolders are used to simulate or process data.

## Testing

Tested on MATALB (R2021a) under macOS and Linux.

## Dependencies
N.B. all third-party dependencies are included and added to the path when needed.
- boundedline (https://github.com/kakearney/boundedline-pkg/) by Kelly Kearney
- colorcet (https://colorcet.holoviz.org/) by Peter Kovesi
- Weizmann Human Action Dataset (https://www.wisdom.weizmann.ac.il/~vision/SpaceTimeActions.html)
- MATLAB Statistics and Machine Learning Toolbox
- MATLAB Image Processing Toolbox
