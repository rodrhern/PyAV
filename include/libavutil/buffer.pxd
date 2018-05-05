cdef extern from "libavutil/buffer.h" nogil:

    cdef struct AVBuffer:
        pass

    cdef struct AVBufferRef:
        AVBuffer *buffer
        uint8_t *data
        int size

    cdef AVBufferRef *av_buffer_ref(AVBufferRef *buf)

    cdef void av_buffer_unref(AVBufferRef **buf)
