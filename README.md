# opentera-dashboards-service

OpenTera dashboard service

## Authors

* [Simon Brière, ing., M.Sc.A., CDRV](mailto:simon.briere@usherbrooke.ca)
* [Dominic Létourneau, ing., M.Sc.A., IntRoLab](mailto:simon.briere@usherbrooke.ca)

## Installation

### Requirements

Create a new database "opentera_dashboards" and configure the [DashboardsService.json](config/DashboardsService.json) file.

### Build with CMake

Use cmake to generate the venv and the translations.

```bash
# Create a build directory
mkdir build
cd build
# Launch cmake, you can specify an existing environment
cmake ../ -DPYTHON_ENV_DIRECTORY="optional python venv path"
# CMake will create the venv if needed and install the requirements
# It will also build the translations
make
# You can update the translations (optional)
make dashboards-service-python-all-with-translations
```

### Setting up the Service (only once)

```bash
# This must be executed only once from the root of the project
conda activate ./venv
# Run the setup script, you might need to change the credentials in the script depending on your setup
# Service will be created in the system with roles.
python3 utils/setup_dashboards_service_run_once.py
```

### Compiling the FrontEnd

#### Requirements

* Qt 6.7 or later with WebAssembly

#### Build steps

* Follow the Qt [instructions](https://doc.qt.io/qt-6/wasm.html) to setup WebAssembly.
* Open the [Frontend/DashboardsViewer/CMakeLists.txt](Frontend/DashboardsViewer/CMakeLists.txt) and use the WebAssembly kit.
* Build the project in "Release"

Copy the following files (found in the build directory) to the [static](static/) directory :

* DashboardsViewerApp.html
* DashboardsViewerApp.js
* DashboardsViewerApp.wasm
* DashboardsViewerApp.worker.js
* loading_logo.png
* qtloader.js
* qtlogo.svg

You are now ready to run the service.

### Running the Dashboards Service

```bash
# This must be executed at the root of the project
# Load the venv first, path might be different if you are using an existing venv
conda activate ./venv

python3 DashboardsService.py [--enable_tests=1] [--config=<Config file full path>]

```
