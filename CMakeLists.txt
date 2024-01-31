cmake_minimum_required(VERSION 3.16.0)
include(ExternalProject)
project(opentera_dashboards_service)


if(NOT CMAKE_BUILD_TYPE )
    MESSAGE(STATUS "undefined build type, set to release" )
    set(CMAKE_BUILD_TYPE Release )
elseif(NOT (${CMAKE_BUILD_TYPE} STREQUAL "Release" OR ${CMAKE_BUILD_TYPE} STREQUAL "Debug" ))
    message(FATAL_ERROR "CMAKE_BUILD_TYPE must be either Release or Debug")
endif()

# Make sure venv is installed first
if(NOT PYTHON_ENV_DIRECTORY)
    set(PYTHON_VERSION 3.11)

    MESSAGE(STATUS, "Python env directory not specified, using default : ${CMAKE_CURRENT_SOURCE_DIR}/venv")
    set(PYTHON_ENV_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/venv)

    # Create venv with conda
    if(WIN32)
        set(conda_executable "conda.bat")
    else(WIN32)
        set(conda_executable "conda")
    endif(WIN32)

    # Check if conda is installed
    find_program(CONDA_EXECUTABLE ${conda_executable})
    if(NOT CONDA_EXECUTABLE)
        message(FATAL_ERROR "conda executable not found, please install conda and try again")
    else(NOT CONDA_EXECUTABLE)
        message(STATUS "conda executable found : ${CONDA_EXECUTABLE}")
    endif(NOT CONDA_EXECUTABLE)

    # Check if venv exists
    if(NOT EXISTS ${PYTHON_ENV_DIRECTORY})
        message(STATUS "Creating python virtual environment in ${PYTHON_ENV_DIRECTORY}")
        execute_process(COMMAND ${CONDA_EXECUTABLE} install -m -c anaconda -y -p ${PYTHON_ENV_DIRECTORY} python=${PYTHON_VERSION})
    else(NOT EXISTS ${PYTHON_ENV_DIRECTORY})
        message(STATUS "Python virtual environment already exists in ${PYTHON_ENV_DIRECTORY}")
    endif(NOT EXISTS ${PYTHON_ENV_DIRECTORY})

    # Set Python executable
    if(WIN32)
        set(PYTHON_EXECUTABLE ${PYTHON_ENV_DIRECTORY}/python.exe)
    else(WIN32)
        set(PYTHON_EXECUTABLE ${PYTHON_ENV_DIRECTORY}/bin/python)
    endif(WIN32)

    # Install requirements
    message(STATUS "Installing python requirements")
    execute_process(COMMAND ${PYTHON_EXECUTABLE} -m pip install -r ${CMAKE_CURRENT_SOURCE_DIR}/requirements.txt)
endif()


# Python executables should be installed with the opentera package
if(WIN32)
    set(PYTHON_EXECUTABLE ${PYTHON_ENV_DIRECTORY}/python.exe)
    set(PYTHON_PIP_EXECUTABLE ${PYTHON_ENV_DIRECTORY}/Scripts/pip.exe)
    set(PYBABEL_EXECUTABLE ${PYTHON_ENV_DIRECTORY}/Scripts/pybabel.exe)
else(WIN32)
    set(PYTHON_EXECUTABLE ${PYTHON_ENV_DIRECTORY}/bin/python)
    set(PYTHON_PIP_EXECUTABLE ${PYTHON_ENV_DIRECTORY}/bin/pip)
    # Not sure why, but is installed in .local directory and must be in path
    # You might need to do a symlink in the venv/bin directory...
    set(PYBABEL_EXECUTABLE ${PYTHON_ENV_DIRECTORY}/bin/pybabel)
endif(WIN32)


set (translation_pot_file ${CMAKE_CURRENT_BINARY_DIR}/dashboards_service_translations.pot)

message(STATUS "PYBABEL EXECUTABLE : ${PYBABEL_EXECUTABLE}")

# Will always be considered out of date...
add_custom_target(
    dashboards-service-python-translations-init
    COMMAND ${PYBABEL_EXECUTABLE} extract -F babel.cfg -o ${translation_pot_file} .
    # TO REINITIALIZE TRANSLATION FILES (comment the two lines, or the translations will be overwritten)
    COMMAND ${PYBABEL_EXECUTABLE} init -i ${translation_pot_file} -d translations -D dashboards_service -l fr
    COMMAND ${PYBABEL_EXECUTABLE} init -i ${translation_pot_file} -d translations -D dashboards_service -l en
    COMMAND ${PYBABEL_EXECUTABLE} update -i ${translation_pot_file} -d translations -D dashboards_service
    COMMAND ${PYBABEL_EXECUTABLE} compile -d translations -D dashboards_service
    DEPENDS ${PYBABEL_EXECUTABLE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/babel.cfg
)


# Will always be considered out of date...
add_custom_target(
    dashboards-service-python-translations-update
    COMMAND ${PYBABEL_EXECUTABLE} extract -F babel.cfg -o ${translation_pot_file} .
    COMMAND ${PYBABEL_EXECUTABLE} update -i ${translation_pot_file} -d translations -D dashboards_service
    COMMAND ${PYBABEL_EXECUTABLE} compile -d translations -D dashboards_service
    DEPENDS ${PYBABEL_EXECUTABLE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/babel.cfg
)

# Will always be considered out of date...
add_custom_target(
    dashboards-service-python-translations-compile-only
    COMMAND ${PYBABEL_EXECUTABLE} extract -F babel.cfg -o ${translation_pot_file} .
    COMMAND ${PYBABEL_EXECUTABLE} compile -d translations -D dashboards_services
    DEPENDS ${PYBABEL_EXECUTABLE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/babel.cfg
)


# Build this target if you want to update translations too...
add_custom_target(dashboards-service-python-all-with-translations
    DEPENDS dashboards-service-python-translations)

# Build this target if you want to compile translations only
add_custom_target(dashboards-service-python-all-with-translations-compile-only ALL
    DEPENDS dashboards-service-python-translations-compile-only)
