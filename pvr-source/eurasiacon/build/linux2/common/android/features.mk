########################################################################### ###
#@Copyright     Copyright (c) Imagination Technologies Ltd. All Rights Reserved
#@License       Dual MIT/GPLv2
# 
# The contents of this file are subject to the MIT license as set out below.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# Alternatively, the contents of this file may be used under the terms of
# the GNU General Public License Version 2 ("GPL") in which case the provisions
# of GPL are applicable instead of those above.
# 
# If you wish to allow use of your version of this file only under the terms of
# GPL, and not to allow others to use your version of this file under the terms
# of the MIT license, indicate your decision by deleting the provisions above
# and replace them with the notice and other provisions required by GPL as set
# out in the file called "GPL-COPYING" included in this distribution. If you do
# not delete the provisions above, a recipient may use your version of this file
# under the terms of either the MIT license or GPL.
# 
# This License is also included in this distribution in the file called
# "MIT-COPYING".
# 
# EXCEPT AS OTHERWISE STATED IN A NEGOTIATED AGREEMENT: (A) THE SOFTWARE IS
# PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT; AND (B) IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
### ###########################################################################

include ../common/android/platform_version.mk

# Basic support option tuning for Android
#
SUPPORT_ANDROID_PLATFORM := 1
SUPPORT_OPENGLES1_V1_ONLY := 1
DONT_USE_SONAMES := 1

# Meminfo IDs are required for buffer stamps
#
SUPPORT_MEMINFO_IDS := 1

# Enable services ion support by default
#
SUPPORT_ION ?= 0
SUPPORT_DMABUF ?= 1

# Need multi-process support in PDUMP
#
SUPPORT_PDUMP_MULTI_PROCESS := 1

# Always print debugging after 5 seconds of no activity
#
CLIENT_DRIVER_DEFAULT_WAIT_RETRIES := 50

# Android WSEGL is always the same
#
OPK_DEFAULT := libpvrANDROID_WSEGL.so

# srvkm is always built, but bufferclass_example is only built
# before EGL_image_external was generally available.
#
KERNEL_COMPONENTS := srvkm

# Kernel modules are always installed here under Android
#
PVRSRV_MODULE_BASEDIR := /system/modules/

# Use the new PVR_DPF implementation to allow lower message levels
# to be stripped from production drivers
#
PVRSRV_NEW_PVR_DPF := 1

# Production Android builds don't want PVRSRVGetDCSystemBuffer
#
SUPPORT_PVRSRV_GET_DC_SYSTEM_BUFFER := 0

# Prefer to limit the 3D parameters heap to <16MB and move the
# extra 48MB to the general heap. This only affects cores with
# 28bit MMUs (520, 530, 531, 540).
#
SUPPORT_LARGE_GENERAL_HEAP := 1

# Enable a page pool for uncached memory allocations. This improves
# the performance of such allocations because the pages are temporarily
# not returned to Linux and therefore do not have to be re-invalidated
# (fewer cache invalidates are needed).
#
# Default the cache size to a maximum of 5400 pages (~21MB). If using
# newer Linux kernels (>=3.0) the cache may be reclaimed and become
# smaller than this maximum during runtime.
#
PVR_LINUX_MEM_AREA_POOL_MAX_PAGES ?= 5400

# Unless overridden by the user, assume the RenderScript Compute API level
# matches that of the SDK API_LEVEL.
#
RSC_API_LEVEL ?= $(API_LEVEL)
ifneq ($(findstring $(RSC_API_LEVEL),21 22),)
RSC_API_LEVEL := 20
endif

##############################################################################
# Framebuffer target extension is used to find configs compatible with
# the framebuffer (added in JB MR1).
#
EGL_EXTENSION_ANDROID_FRAMEBUFFER_TARGET := 1

##############################################################################
# Handle various platform includes for unittests
#
UNITTEST_INCLUDES := \
 eurasiacon/android \
 $(ANDROID_ROOT)/frameworks/base/native/include \
 $(ANDROID_ROOT)/frameworks/native/include \
 $(ANDROID_ROOT)/frameworks/native/opengl/include \
 $(ANDROID_ROOT)/libnativehelper/include/nativehelper

# But it doesn't have OpenVG headers
#
UNITTEST_INCLUDES += eurasiacon/unittests/include

##############################################################################
# Future versions moved proprietary libraries to a vendor directory
#
SHLIB_DESTDIR := /system/vendor/lib
DEMO_DESTDIR := /system/vendor/bin

# EGL libraries go in a special place
#
EGL_DESTDIR := $(SHLIB_DESTDIR)/egl

##############################################################################
# In K and older, augment the libstdc++ includes with stlport includes. Any
# part of the C++ library not implemented by stlport will be handled by
# linking in libstdc++ too (see extra_config.mk).
#
# On L and newer, don't use stlport OR libstdc++ at all; just use libc++.
#
SYS_CXXFLAGS := -fuse-cxa-atexit $(SYS_CFLAGS)
ifeq ($(is_at_least_lollipop),1)
SYS_INCLUDES += \
 -isystem $(ANDROID_ROOT)/external/libcxx/include
else
SYS_INCLUDES += \
 -isystem $(ANDROID_ROOT)/bionic \
 -isystem $(ANDROID_ROOT)/external/stlport/stlport
endif

##############################################################################
# Support the OES_EGL_image_external extensions in the client drivers.
#
GLES1_EXTENSION_EGL_IMAGE_EXTERNAL := 1
GLES2_EXTENSION_EGL_IMAGE_EXTERNAL := 1

##############################################################################
# ICS requires that at least one driver EGLConfig advertises the
# EGL_RECORDABLE_ANDROID attribute. The platform requires that surfaces
# rendered with this config can be consumed by an OMX video encoder.
#
EGL_EXTENSION_ANDROID_RECORDABLE := 1

##############################################################################
# ICS added the EGL_ANDROID_blob_cache extension. Enable support for this
# extension in EGL/GLESv2.
#
EGL_EXTENSION_ANDROID_BLOB_CACHE := 1

##############################################################################
# JB added a new corkscrew API for userland backtracing.
#
ifeq ($(is_at_least_lollipop),0)
PVR_ANDROID_HAS_CORKSCREW_API := 1
endif

##############################################################################
# JB MR1 introduces cross-process syncs associated with a fd.
# This requires a new enough kernel version to have the base/sync driver.
#
EGL_EXTENSION_ANDROID_NATIVE_FENCE_SYNC ?= 1
PVR_ANDROID_NATIVE_WINDOW_HAS_SYNC ?= 1

##############################################################################
# Versions of Android between Cupcake and KitKat MR1 required Java 6.
#
ifeq ($(is_at_least_lollipop),0)
LEGACY_USE_JAVA6 ?= 1
endif

##############################################################################
# Versions of Android between ICS and KitKat MR1 used ion .heap_mask instead
# of .heap_id_mask.
#
ifeq ($(is_at_least_lollipop),0)
PVR_ANDROID_HAS_ION_FIELD_HEAP_MASK := 1
endif

##############################################################################
# Lollipop supports 64-bit. Configure BCC to emit both 32-bit and 64-bit LLVM
# bitcode in the renderscript driver.
#
ifeq ($(is_at_least_lollipop),1)
PVR_ANDROID_BCC_MULTIARCH_SUPPORT := 1
endif

##############################################################################
# Lollipop annotates the cursor allocation with USAGE_CURSOR to enable it to
# be accelerated with special cursor hardware (rather than wasting an
# overlay). This flag stops the DDK from blocking the allocation.
#
ifeq ($(is_at_least_lollipop),1)
PVR_ANDROID_HAS_GRALLOC_USAGE_CURSOR := 1
endif

##############################################################################
# Lollipop changed the camera HAL metadata specification to require that
# CONTROL_MAX_REGIONS specifies 3 integers (instead of 1).
#
ifeq ($(is_at_least_lollipop),1)
PVR_ANDROID_CAMERA_CONTROL_MAX_REGIONS_HAS_THREE := 1
endif

##############################################################################
# Marshmallow needs --soname turned on
#
ifeq ($(is_at_least_marshmallow),1)
PVR_ANDROID_NEEDS_SONAME ?= 1
endif

##############################################################################
# Marshmallow replaces RAW_SENSOR with RAW10, RAW12 and RAW16
#
ifeq ($(is_at_least_marshmallow),1)
PVR_ANDROID_HAS_HAL_PIXEL_FORMAT_RAWxx := 1
endif

##############################################################################
# Marshmallow onwards DDK stopped render script acceleration using GPU.
# This flag stops device allocation.
#
ifeq ($(is_at_least_marshmallow),1)
PVR_ANDROID_HAS_GRALLOC_USAGE_RENDERSCRIPT := 1
endif

# Placeholder for future version handling
#
ifeq ($(is_future_version),1)
-include ../common/android/future_version.mk
endif
