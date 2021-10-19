project(flutter_ffi)
cmake_minimum_required(VERSION 3.10)

#CONFIGURATION

set(OPENCV_VERSION 4.4.0)

message("api level ${ANDROID_PLATFORM}")
message("ndk ${ANDROID_NDK}")
message("abi ${ANDROID_ABI}")
message("target ${TARGET}")

#Paths
set(openssl ${CMAKE_CURRENT_SOURCE_DIR}/android/openssl)
set(opencv ${CMAKE_CURRENT_SOURCE_DIR}/android/opencv-build/opencv-${OPENCV_VERSION}-android/sdk/native/jni) ## need to be precompiled!!
set(umbrella ${CMAKE_CURRENT_SOURCE_DIR}/umbrella)
set(opencv_includes ${CMAKE_CURRENT_SOURCE_DIR}/opencv/${ANDROID_ABI})

include(ExternalProject)
find_library(log-lib log) #add android logging
# GLESv2 look for opengl android
find_path(GLES2_INCLUDE_DIR GLES2/gl2.h
    HINTS ${ANDROID_NDK})
find_library(GLES2_LIBRARY libGLESv2.so
    HINTS ${GLES2_INCLUDE_DIR}/../lib)

#### Open SSL
add_library(OpenSSL INTERFACE)
add_dependencies(OpenSSL ${openssl})
set_property(TARGET OpenSSL PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${openssl}/include")
set_property(TARGET OpenSSL PROPERTY INTERFACE_LINK_DIRECTORIES "${openssl}/lib/${ANDROID_ABI}")
set_property(TARGET OpenSSL PROPERTY INTERFACE_LINK_LIBRARIES crypto ssl)

set(OpenCV_DIR ${opencv})
find_package(OpenCV REQUIRED HINTS ${opencv})
set(CMAKE_CXX_STANDARD 17) #set c++ language standart

set(FLUTTER_UMBRELLA
	${umbrella}/OpenCV/OpenCvFFI.cpp
	${umbrella}/FaceDetector/FaceDetector.cpp
)

###Build a shared library with our umbrella clases and opencv
add_library(${CMAKE_PROJECT_NAME} SHARED
	${FLUTTER_UMBRELLA}
)

#target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
#	${SBSDK_TFLITE_DEFS})

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
	${GLES2_INCLUDE_DIR}
)

target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC
    ${umbrella}
)

target_link_libraries(${CMAKE_PROJECT_NAME} PUBLIC
	${OpenCV_LIBS}
    OpenSSL
	${log-lib}
	${GLES2_LIBRARY}
)

#NDK ONLY?
#add_compile_options(-fexceptions -frtti)

message("ready to compile")
