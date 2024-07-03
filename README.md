# Targeting Tools

## Overview

Targeting Tools is a comprehensive R Shiny application designed to assist in land analysis and decision-making processes. The original targeting tool is available here.    
- webpage: https://targetingtools.ciat.cgiar.org/.   
- github: https://github.com/CIAT/targeting-tools-toolbox/.   

It provides three main functionalities:

1. Land Suitability Analysis
2. Land Similarity Analysis
3. Land Statistics

This tool is particularly useful for researchers, policymakers, and land management professionals working in agriculture, environmental science, and urban planning.

## Table of Contents

- [Features](#features)
- [Folder Structure](#folder-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features

### Land Suitability Analysis
- Select regions and countries for analysis
- Use pre-existing raster datasets or upload custom data
- Set optimal values for different parameters
- Generate suitability maps based on multiple criteria

### Land Similarity Analysis
- Identify areas with similar characteristics to known locations
- Use multiple input rasters for comprehensive similarity assessment
- Generate Mahalanobis distance and MESS (Multivariate Environmental Similarity Surface) outputs

### Land Statistics
- Calculate various statistics on land suitability outputs
- Reclassify input rasters using different methods (Equal Interval, Reclass by Table)
- Perform zonal statistics with multiple value rasters

## Folder Structure

```
TargetingTools/
├── app.R
├── www/
├── R/
│   ├── ui.R
│   ├── server.R
│   ├── suitability_functions.R
│   ├── similarity_functions.R
│   └── statistics_functions.R
└── data/
    ├── Africa/
    │   ├── Kenya/
    │   │   ├── bio1.tif
    │   │   ├── bio2.tif
    │   │   └── ...
    │   ├── Ethiopia/
    │   └── Tanzania/
    ├── Asia/
    │   ├── Bangladesh/
    │   ├── India/
    │   └── Philippines/
    └── Global/
        ├── bio1.tif
        ├── bio2.tif
        └── ...
```

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/ani-ghosh/spatial_targeting.git
   ```

2. Install required R packages:
   ```R
   install.packages(c("shiny", "shinydashboard", "leaflet", "terra", "sf", "DT", "shinyjs"))
   ```

3. Ensure you have the necessary data files in the `data/` directory as per the folder structure above.

## Usage

1. Navigate to the project directory:
   ```
   cd TargetingTools
   ```

2. Run the Shiny app:
   ```R
   shiny::runApp()
   ```

3. The app should open in your default web browser. If it doesn't, look for a URL in the R console output and open it manually.

4. Select the desired tool (Land Suitability, Land Similarity, or Land Statistics) from the sidebar menu.

5. Follow the on-screen instructions to select regions, countries, and raster datasets for your analysis.

6. Adjust parameters as needed and run the analysis.

7. View results on the interactive map and download outputs as needed.

## Contributing

We welcome contributions to improve Targeting Tools! Here are ways you can contribute:

1. Report bugs and suggest features by opening issues.
2. Submit pull requests with bug fixes or new features.
3. Improve documentation or add examples.
4. Share your experience using the tool.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the YYY License - see the [LICENSE.md](LICENSE.md) file for details.

---

For more information, please contact [Name/Organization] at [contact@email.com].