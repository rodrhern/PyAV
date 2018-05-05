from libc.stdint cimport uint8_t
cimport numpy
cimport libav as lib

cdef class FrameBuffer(object):
    
    cdef uint8_t *buffer
    cdef readonly int buffer_size


cdef class HWAccel:
    # input
    cdef lib.AVFormatContext *input_ctx
    cdef lib.AVStream *video
    cdef int video_stream
    # decoder
    cdef lib.AVCodecContext *decoder_ctx
    cdef lib.AVCodec *decoder
    # hwaccel
    cdef lib.AVHWDeviceType type
    cdef lib.AVBufferRef *hw_device_ctx
    cdef lib.AVPixelFormat hw_pix_fmt
    # packet
    cdef lib.AVPacket packet
    cdef lib.AVFrame *frame
    cdef int is_decoding_frame
    cdef int is_decoding_packet
    