# - Try to find KurentoHelpers

#=============================================================================
# Copyright 2014 Kurento
#
#=============================================================================

set(PACKAGE_VERSION "6.13.0")
set(KurentoHelpers_VERSION ${PACKAGE_VERSION})
set(KurentoHelpers_FOUND 1)

include (FindPackageHandleStandardArgs)

find_package_handle_standard_args(KurentoHelpers FOUND_VAR KurentoHelpers_FOUND
  REQUIRED_VARS KurentoHelpers_VERSION
  VERSION_VAR KurentoHelpers_VERSION
)
mark_as_advanced(KurentoHelpers_FOUND KurentoHelpers_VERSION)
