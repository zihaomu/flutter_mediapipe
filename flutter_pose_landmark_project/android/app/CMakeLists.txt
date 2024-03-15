cmake_minimum_required(VERSION 3.6.0)


include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)
set(SOURCES
    ../../lib/opencv-cpp/gaussian.cpp
    ../../lib/opencv-cpp/image_ffi.cpp
    ../../lib/opencv-cpp/main.cpp
    ../../lib/opencv-cpp/mpp_remap.cpp
)

add_library(libopencv_core SHARED IMPORTED GLOBAL)
set_target_properties(libopencv_core PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_core.so)

add_library(libMNN SHARED IMPORTED GLOBAL)
set_target_properties(libMNN PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libMNN.so)

add_library(libopencv_dnn SHARED IMPORTED GLOBAL)
set_target_properties(libopencv_dnn PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_dnn.so)

add_library(libopencv_imgproc SHARED IMPORTED GLOBAL)
set_target_properties(libopencv_imgproc PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_imgproc.so)

add_library(libtensorflow-lite SHARED IMPORTED GLOBAL)
set_target_properties(libtensorflow-lite PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libtensorflow-lite.so)

add_library(libvision_pose_detector SHARED IMPORTED GLOBAL)
set_target_properties(libvision_pose_detector PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libvision_pose_detector.so)

#find_library(log-lib log)
add_library(OpenCV_ffi ${SOURCES})
target_link_libraries(OpenCV_ffi
    ${log-lib}

    # base
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_base.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_severity.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_malloc_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_raw_logging_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_scoped_set_env.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_spinlock_wait.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_strerror.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_throw_delegate.so

    # container
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_hashtablez_sampler.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_raw_hash_set.so

    # crc
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_crc_cord_state.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_crc_cpu_detect.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_crc_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_crc32c.so

    # debugging
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_debugging_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_demangle_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_examine_stack.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_failure_signal_handler.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_leak_check.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_stacktrace.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_symbolize.so

    # log
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_die_if_null.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_entry.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_flags.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_globals.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_initialize.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_internal_check_op.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_internal_conditions.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_internal_format.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_internal_globals.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_internal_log_sink_set.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_internal_message.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_internal_nullguard.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_internal_proto.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_log_sink.so

    # type
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_int128.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_exponential_biased.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_periodic_sampler.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_distributions.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_internal_distribution_test_util.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_internal_platform.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_internal_pool_urbg.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_internal_randen_hwaes_impl.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_internal_randen_hwaes.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_internal_randen_slow.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_internal_randen.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_internal_seed_material.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_seed_gen_exception.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_random_seed_sequences.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_bad_any_cast_impl.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_bad_optional_access.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_bad_variant_access.so

    # time to strings
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_civil_time.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_time_zone.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_time.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_city.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_hash.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_low_level_hash.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_status.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_statusor.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_cord_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_cord.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_cordz_functions.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_cordz_handle.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_cordz_info.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_cordz_sample_token.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_str_format_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_string_view.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_strings_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_strings.so

    # flags
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_commandlineflag_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_commandlineflag.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_config.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_marshalling.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_parse.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_private_handle_accessor.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_program_name.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_reflection.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_usage_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags_usage.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_flags.so

    # synchronization
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_graphcycles_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_kernel_timeout_internal.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libabsl_synchronization.so

    # misc
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libcpuinfo.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libeight_bit_int_gemm.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libfft2d_fftsg.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libfft2d_fftsg2d.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libpthreadpool.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libXNNPACK.so

    # other misc
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libfarmhash.so

    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libMNN.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_core.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_dnn.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libopencv_imgproc.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libtensorflow-lite.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libvision_pose_detector.so
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/main/jniLibs/${ANDROID_ABI}/libvision_pose_landmarker.so
    )
