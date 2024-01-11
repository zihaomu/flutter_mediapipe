cmake_minimum_required(VERSION 3.6.0)


include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)
set(SOURCES
    ../../lib/opencv-cpp/gaussian.cpp
    ../../lib/opencv-cpp/image_ffi.cpp
    ../../lib/opencv-cpp/main.cpp
    ../../lib/opencv-cpp/mpp_remap.cpp
)

add_library(libMNN SHARED IMPORTED GLOBAL)
set_target_properties(libMNN PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libMNN.so)

add_library(libopencv_core SHARED IMPORTED GLOBAL)
set_target_properties(libopencv_core PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_core.so)

add_library(libopencv_dnn SHARED IMPORTED GLOBAL)
set_target_properties(libopencv_dnn PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_dnn.so)

add_library(libopencv_imgproc SHARED IMPORTED GLOBAL)
set_target_properties(libopencv_imgproc PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_imgproc.so)

add_library(libvision_pose_detector SHARED IMPORTED GLOBAL)
set_target_properties(libvision_pose_detector PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libvision_pose_detector.so)

add_library(libvision_pose_landmarker SHARED IMPORTED GLOBAL)
set_target_properties(libvision_pose_landmarker PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libvision_pose_landmarker.so)

#find_library(log-lib log)
add_library(OpenCV_ffi ${SOURCES})
target_link_libraries(OpenCV_ffi
    ${log-lib}
#    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_core.so
#    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so
##        ${libMNN}
#        ${libopencv_core}
##        ${libopencv_dnn}
#        ${libopencv_imgproc}
##        ${libvision_pose_detector}
##        ${libvision_pose_landmarker}
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libMNN.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_core.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_dnn.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_imgproc.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libvision_pose_detector.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libvision_pose_landmarker.so
    )

#include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)
##add_library(lib_opencv SHARED IMPORTED)
##set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so)
#set(SOURCES
#    ../../lib/opencv-cpp/main.cpp
#)
#
#find_library(log-lib log)
#add_library(OpenCV_ffi SHARED ${SOURCES})
#target_link_libraries(OpenCV_ffi
#        ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_java4.so
#        #lib_opencv
#        ${log-lib}
#        )
