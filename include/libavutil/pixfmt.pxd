cdef extern from "libavutil/pixfmt.h" nogil:

    cdef enum AVColorRange:
        AVCOL_RANGE_UNSPECIFIED = 0
        AVCOL_RANGE_MPEG        = 1
        AVCOL_RANGE_JPEG        = 2
        AVCOL_RANGE_NB

    cdef enum AVColorPrimaries:
        AVCOL_PRI_RESERVED0   = 0
        AVCOL_PRI_BT709       = 1
        AVCOL_PRI_UNSPECIFIED = 2
        AVCOL_PRI_RESERVED    = 3
        AVCOL_PRI_BT470M      = 4
        AVCOL_PRI_BT470BG     = 5
        AVCOL_PRI_SMPTE170M   = 6
        AVCOL_PRI_SMPTE240M   = 7
        AVCOL_PRI_FILM        = 8
        AVCOL_PRI_BT2020      = 9
        AVCOL_PRI_SMPTE428    = 10
        AVCOL_PRI_SMPTEST428_1 = AVCOL_PRI_SMPTE428
        AVCOL_PRI_SMPTE431    = 11
        AVCOL_PRI_SMPTE432    = 12
        AVCOL_PRI_JEDEC_P22   = 22
        AVCOL_PRI_NB

    cdef enum AVColorTransferCharacteristic:
        AVCOL_TRC_RESERVED0    = 0
        AVCOL_TRC_BT709        = 1
        AVCOL_TRC_UNSPECIFIED  = 2
        AVCOL_TRC_RESERVED     = 3
        AVCOL_TRC_GAMMA22      = 4
        AVCOL_TRC_GAMMA28      = 5
        AVCOL_TRC_SMPTE170M    = 6
        AVCOL_TRC_SMPTE240M    = 7
        AVCOL_TRC_LINEAR       = 8
        AVCOL_TRC_LOG          = 9
        AVCOL_TRC_LOG_SQRT     = 10
        AVCOL_TRC_IEC61966_2_4 = 11
        AVCOL_TRC_BT1361_ECG   = 12
        AVCOL_TRC_IEC61966_2_1 = 13
        AVCOL_TRC_BT2020_10    = 14
        AVCOL_TRC_BT2020_12    = 15
        AVCOL_TRC_SMPTE2084    = 16
        AVCOL_TRC_SMPTEST2084  = AVCOL_TRC_SMPTE2084
        AVCOL_TRC_SMPTE428     = 17
        AVCOL_TRC_SMPTEST428_1 = AVCOL_TRC_SMPTE428
        AVCOL_TRC_ARIB_STD_B67 = 18
        AVCOL_TRC_NB

    cdef enum AVColorSpace:
        AVCOL_SPC_RGB         = 0
        AVCOL_SPC_BT709       = 1
        AVCOL_SPC_UNSPECIFIED = 2
        AVCOL_SPC_RESERVED    = 3
        AVCOL_SPC_FCC         = 4
        AVCOL_SPC_BT470BG     = 5
        AVCOL_SPC_SMPTE170M   = 6
        AVCOL_SPC_SMPTE240M   = 7
        AVCOL_SPC_YCGCO       = 8
        AVCOL_SPC_YCOCG       = AVCOL_SPC_YCGCO
        AVCOL_SPC_BT2020_NCL  = 9
        AVCOL_SPC_BT2020_CL   = 10
        AVCOL_SPC_SMPTE2085   = 11
        AVCOL_SPC_CHROMA_DERIVED_NCL = 12
        AVCOL_SPC_CHROMA_DERIVED_CL = 13
        AVCOL_SPC_ICTCP       = 14
        AVCOL_SPC_NB
    
    cdef enum AVChromaLocation:
        AVCHROMA_LOC_UNSPECIFIED = 0
        AVCHROMA_LOC_LEFT        = 1
        AVCHROMA_LOC_CENTER      = 2
        AVCHROMA_LOC_TOPLEFT     = 3
        AVCHROMA_LOC_TOP         = 4
        AVCHROMA_LOC_BOTTOMLEFT  = 5
        AVCHROMA_LOC_BOTTOM      = 6
        AVCHROMA_LOC_NB