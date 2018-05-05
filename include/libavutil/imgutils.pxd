cdef extern from "libavutil/imgutils.h" nogil:

    cdef int av_image_get_buffer_size(AVPixelFormat pix_fmt, int width, int height, int align)
    cdef int av_image_copy_to_buffer(uint8_t *dst, int dst_size,
                            uint8_t *src_data[4], int src_linesize[4],
                            AVPixelFormat pix_fmt, int width, int height, int align)