project(flutter_ffi)
cmake_minimum_required(VERSION 3.21)

#CONFIGURATION

set(OPENCV_VERSION 4.5.0)

message("architecture ${IOS_ARCH}")
message("sys_root ${CMAKE_OSX_SYSROOT}")

#Paths
set(openssl ${CMAKE_CURRENT_SOURCE_DIR}/openssl)
set(opencv ${CMAKE_CURRENT_SOURCE_DIR}/opencv-build/opencv-${OPENCV_VERSION}-ios-build/build/build-${IOS_ARCH}-${CMAKE_OSX_SYSROOT}/install/lib/cmake/opencv4) ## need to be precompiled!!
set(umbrella ${CMAKE_CURRENT_SOURCE_DIR}/../umbrella)
message("opencv path ${opencv}")

#### Open SSL
add_library(OpenSSL INTERFACE)
add_dependencies(OpenSSL ${openssl})
set_property(TARGET OpenSSL PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${openssl}/include")
set_property(TARGET OpenSSL PROPERTY INTERFACE_LINK_DIRECTORIES "${openssl}/lib/iOS")
set_property(TARGET OpenSSL PROPERTY INTERFACE_LINK_LIBRARIES crypto ssl)

#OpenCV
set(OpenCV_DIR ${opencv})
find_package(OpenCV REQUIRED HINTS ${opencv})

set(CMAKE_CXX_STANDARD 17) #set c++ language standart

set(CMAKE_OSX_DEPLOYMENT_TARGET 11)

set(FLUTTER_UMBRELLA
	${umbrella}/ShapeDetector/ShapeDetector.cpp
	${umbrella}/Utils/MatUtils.h
	${umbrella}/Utils/FlutterCVOperations.h
    ${umbrella}/OpenCV/OpenCvFFI.cpp
    ${umbrella}/OpenCV/OpenCvFFI.h
	${umbrella}/ShapeDetector/ShapeDetector.h
)

set(FLUTTER_UMBRELLA_PUBLIC
	${umbrella}/OpenCV/OpenCvFFI.h
	${umbrella}/Utils/FlutterCVOperations.h
	${umbrella}/Utils/MatUtils.h
)

set(CMAKE_INSTALL_PREFIX
	${CMAKE_CURRENT_SOURCE_DIR}/../../ios
)

###Build a shared library with our umbrella clases and opencv
add_library(${CMAKE_PROJECT_NAME} SHARED
	${FLUTTER_UMBRELLA}
)

target_link_libraries(${CMAKE_PROJECT_NAME} PUBLIC
	${OpenCV_LIBS}
    ${OpenSSL}
)

target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC
    ${umbrella}
)
## compile option nessessary to build propper framework
target_compile_options(${CMAKE_PROJECT_NAME}
  PUBLIC
    "-fembed-bitcode"
  )

set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
	FRAMEWORK TRUE
	MACOSX_FRAMEWORK_IDENTIFIER com.scanbot.flutterffi
	PUBLIC_HEADER "${FLUTTER_UMBRELLA_PUBLIC}"
	VERSION 1.0.0
	SOVERSION 1.0.0
#For release build add your credentials
	#XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
	#XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ""
    #XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "Yes"
)

message("ready to compile")
