from libc.stdint cimport uint8_t

cimport libav as lib

cimport numpy
import numpy


DEVICE = '/dev/dri/renderD129'
DEVICE_TYPE = 'vaapi'


cdef int hw_decoder_init(lib.AVCodecContext *ctx, lib.AVHWDeviceType type, lib.AVBufferRef *hw_device_ctx):    
    
    err = lib.av_hwdevice_ctx_create(&hw_device_ctx, type, DEVICE, NULL, 0)
    if err < 0:
        raise Exception("Failed to create specified HW device")
    
    ctx.hw_device_ctx = lib.av_buffer_ref(hw_device_ctx)
    
    return 0


cdef class HWAccel:

    def find_device_type(self, device_type):
        self.type = lib.av_hwdevice_find_type_by_name(device_type)
        if self.type == lib.AV_HWDEVICE_TYPE_NONE:
            print("Device type {} is not supported.".format(device_type))
            raise Exception

    def open_input_file(self, filename):
        # open the input file
        ret = lib.avformat_open_input(&self.input_ctx, filename, NULL, NULL)
        if ret != 0:
            print("Cannot open input file {}".format(filename))
            raise Exception
        
        ret = lib.avformat_find_stream_info(self.input_ctx, NULL)
        if ret < 0:
            print("Cannot find input stream information.")
            raise Exception

        # find the video stream information
        ret = lib.av_find_best_stream(self.input_ctx, lib.AVMEDIA_TYPE_VIDEO, -1, -1, &self.decoder, 0)
        if ret < 0:
            print("Cannot find a video stream in the input file")
            raise Exception
        self.video_stream = ret

    def init_decoder(self):
        i = 0
        while True:
            config = lib.avcodec_get_hw_config(self.decoder, i)
            if not config:
                print("Decoder {} does not support device type {}".format(
                    self.decoder.name, 
                    lib.av_hwdevice_get_type_name(self.type)
                ))
                raise Exception
            if config.methods & lib.AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX and config.device_type == self.type:
                self.hw_pix_fmt = config.pix_fmt
                break
            
            i += 1

        self.decoder_ctx = lib.avcodec_alloc_context3(self.decoder)
        if not self.decoder_ctx:
            raise Exception
        
        self.video = self.input_ctx.streams[self.video_stream]
        ret = lib.avcodec_parameters_to_context(self.decoder_ctx, self.video.codecpar)
        if ret < 0:
            raise Exception
        
        ret = hw_decoder_init(self.decoder_ctx, self.type, self.hw_device_ctx)
        if ret < 0:
            raise Exception

        ret = lib.avcodec_open2(self.decoder_ctx, self.decoder, NULL)
        if ret < 0:
            print("Failed to open codec for stream {}".format(self.video_stream))
            raise Exception

    def release(self):
        lib.avcodec_free_context(&self.decoder_ctx)
        lib.avformat_close_input(&self.input_ctx)
        lib.av_buffer_unref(&self.hw_device_ctx)

    def __cinit__(self):
        self.frame = lib.av_frame_alloc()

    def __dealloc__(self):
        lib.av_frame_free(&self.frame)

    def __init__(self, filename):
        self.find_device_type(DEVICE_TYPE)
        self.open_input_file(filename)
        self.init_decoder()
        
        self.is_decoding_packet = 0
        self.is_decoding_frame = 0

    def decode_packet(self):
        cdef lib.AVFrame *frame = NULL
        cdef lib.AVFrame *tmp_frame = NULL

        decoder_ctx = self.decoder_ctx
        packet = &self.packet

        ret = lib.avcodec_send_packet(decoder_ctx, packet)
        if ret < 0:
            print("Error during decoding: {}".format(ret))
        
        while True:

            frame = lib.av_frame_alloc()

            if not frame:
                print("Can not alloc frame")
                ret = lib.AVERROR(lib.ENOMEM)
                lib.av_frame_free(&frame)
                return ret

            ret = lib.avcodec_receive_frame(decoder_ctx, frame)
            if ret == lib.AVERROR(lib.EAGAIN) or ret == lib.AVERROR_EOF:
                lib.av_frame_free(&frame)
                return 0
            elif ret < 0:
                print("Error while decoding")
                lib.av_frame_free(&frame)
                return ret
            
            # retrieve data from GPU to CPU
            if frame.format == self.hw_pix_fmt:
                ret = lib.av_hwframe_transfer_data(self.frame, frame, 0)
                if (ret < 0):
                    print("Error transferring the data to system memory")
                    lib.av_frame_free(&frame)
                    return ret
            else:
                tmp_frame = self.frame
                self.frame = frame
                frame = tmp_frame
            
            lib.av_frame_free(&frame)
        
        return ret

    def decode(self):
        # actual decoding and dump the raw data
        frame_size = 0
        frame = None
        while frame_size <= 0:
            # iterate until finding a video packet
            while True:
                ret = lib.av_read_frame(self.input_ctx, &self.packet)
                if ret < 0:
                    self.decode_stop()
                    return False, frame
                if self.video_stream == self.packet.stream_index:
                    break
                lib.av_packet_unref(&self.packet)
            
            ret = self.decode_packet()
            lib.av_packet_unref(&self.packet)

            frame_size = lib.av_image_get_buffer_size(
                <lib.AVPixelFormat> self.frame.format, self.frame.width, self.frame.height, 1)
        return True, self.get_frame()

    def decode_stop(self):
        # flush the decoder
        self.packet.data = NULL
        self.packet.size = 0
        ret = self.decode_packet()
        lib.av_packet_unref(&self.packet)

    def get_frame(self):
        cdef numpy.ndarray[numpy.uint8_t, ndim=1] buffer

        size = lib.av_image_get_buffer_size(
            <lib.AVPixelFormat> self.frame.format, self.frame.width, self.frame.height, 1)
        
        if size <= 0:
            return []
        
        buffer = numpy.empty(size, dtype=numpy.uint8)
        
        ret = lib.av_image_copy_to_buffer(
            <uint8_t *> buffer.data, size, 
            self.frame.data, self.frame.linesize, <lib.AVPixelFormat> self.frame.format, 
            self.frame.width, self.frame.height, 1)
        h = int(self.frame.height * 1.5)
        w = self.frame.width
        return buffer.reshape(h, w)


