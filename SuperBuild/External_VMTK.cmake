set(proj VMTK)

# Set dependency list
set(${proj}_DEPENDS "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  message(FATAL_ERROR "Enabling ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj} is not supported !")
endif()

# Sanity checks
if(DEFINED VMTK_DIR AND NOT EXISTS ${VMTK_DIR})
  message(FATAL_ERROR "Foo_DIR variable is defined but corresponds to nonexistent directory")
endif()

if(NOT DEFINED ${proj}_DIR AND NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})

  if(NOT DEFINED git_protocol)
    set(git_protocol "git")
  endif()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    #GIT_REPOSITORY "${git_protocol}://github.com/vmtk/vmtk.git"
    #GIT_TAG "2cecfb427a45bbb5240de687929954c60ebab06f" # "more debugging test for mac os 10.13" (58c8829) commit broke Python wrapping, so we need to use the one before
    GIT_REPOSITORY "${git_protocol}://github.com/rlizzo/vmtk"
    GIT_TAG "slicer-fix"
    SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj}
    BINARY_DIR ${proj}-build
    CMAKE_CACHE_ARGS
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_BINARY_DIR}/${Slicer_THIRDPARTY_BIN_DIR}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_BINARY_DIR}/${Slicer_THIRDPARTY_LIB_DIR}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_DOCUMENTATION:BOOL=OFF
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags} 
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/SlicerVmtk-build
      # installation location for the pypes/scripts
      -DVMTK_INSTALL_BIN_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_PYTHON_LIB_DIR}/pypes
      -DVMTK_MODULE_INSTALL_LIB_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_PYTHON_LIB_DIR}/pypes
      -DVMTK_SCRIPTS_INSTALL_BIN_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_PYTHON_LIB_DIR}/pypes
      -DVMTK_SCRIPTS_INSTALL_LIB_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_PYTHON_LIB_DIR}/pypes
      -DPYPES_INSTALL_BIN_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_PYTHON_LIB_DIR}/pypes
      -DPYPES_MODULE_INSTALL_LIB_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_PYTHON_LIB_DIR}/pypes
      -DVMTK_CONTRIB_SCRIPTS_INSTALL_LIB_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_PYTHON_LIB_DIR}/pypes
      -DVMTK_CONTRIB_SCRIPTS_INSTALL_BIN_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_PYTHON_LIB_DIR}/pypes
      # installation location for all vtkvmtk stuff
      -DVTK_VMTK_INSTALL_BIN_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_BIN_DIR}
      -DVTK_VMTK_INSTALL_LIB_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_LIB_DIR}
      -DVTK_VMTK_MODULE_INSTALL_LIB_DIR:PATH=${Slicer_INSTALL_QTLOADABLEMODULES_PYTHON_LIB_DIR}
      -DVTK_VMTK_WRAP_PYTHON:BOOL=ON
      # we don't want superbuild since it will override our CMake settings
      -DVMTK_USE_SUPERBUILD:BOOL=OFF
      -DVMTK_CONTRIB_SCRIPTS:BOOL=ON
      -DVMTK_MINIMAL_INSTALL:BOOL=OFF
      -DVMTK_ENABLE_DISTRIBUTION:BOOL=OFF
      -DVMTK_WITH_LIBRARY_VERSION:BOOL=OFF
      # we want the vmtk scripts :)
      -DVMTK_SCRIPTS_ENABLED:BOOL=ON
      # we do not want cocoa, go away :)
      -DVTK_VMTK_USE_COCOA:BOOL=OFF
      # we use Slicer's VTK and ITK
      -DUSE_SYSTEM_VTK:BOOL=ON
      -DUSE_SYSTEM_ITK:BOOL=ON
      -DITK_DIR:PATH=${ITK_DIR}
      -DVTK_DIR:PATH=${VTK_DIR}
      -DPYTHON_LIBRARY:PATH=${PYTHON_LIBRARY}
    INSTALL_COMMAND ""
    DEPENDS
      ${${proj}_DEPENDS}
    )
  set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

else()
  ExternalProject_Add_Empty(${proj} DEPENDS ${${proj}_DEPENDS})
endif()

mark_as_superbuild(${proj}_DIR:PATH)
