//
//  BellDefs.h
//  Bell
//
//  Created by Hari Karam Singh on 14/12/2013.
//  Copyright (c) 2013 Air Craft Media Ltd. All rights reserved.
//

#import "BellDefs.h"


/////////////////////////////////////////////////////////////////////////
#pragma mark - ASBD Consts
/////////////////////////////////////////////////////////////////////////

const AudioStreamBasicDescription kBellCanonicalStreamFormat = {
    .mSampleRate = 44100.0, //kAudioStreamAnyRate,
    .mFormatID = kAudioFormatLinearPCM,
    .mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved,
    .mBytesPerPacket = sizeof(BellSample) * 1,
    .mFramesPerPacket = 1,
    .mBytesPerFrame = sizeof(BellSample) * 1,
    .mChannelsPerFrame = 2,
    .mBitsPerChannel = 8 * sizeof(BellSample),
};


/////////////////////////////////////////////////////////////////////////
#pragma mark - File Formats - CAF
/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_CAF_LPCM_Stereo_44_1_16bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBytesPerPacket = 16/8 * 2 * 1,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 16/8 * 2,
        .mChannelsPerFrame = 2,
        .mBitsPerChannel = 16,
        .mReserved = 0
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const BellAudioFileFormatDescription kBellFileFormat_CAF_LPCM_Stereo_44_1_24bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 24,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 24/8 * 2,
        .mBytesPerPacket = 24/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const BellAudioFileFormatDescription kBellFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 32,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 32/8 * 2,
        .mBytesPerPacket = 32/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const BellAudioFileFormatDescription kBellFileFormat_CAF_LPCM_Stereo_44_1_16bit_Packed_SignedInt = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger,
        .mBitsPerChannel = 16,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 16/8 * 2,
        .mBytesPerPacket = 16/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const BellAudioFileFormatDescription kBellFileFormat_CAF_LPCM_Stereo_44_1_24bit_Packed_SignedInt = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger,
        .mBitsPerChannel = 24,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 24/8 * 2,
        .mBytesPerPacket = 24/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const BellAudioFileFormatDescription kBellFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_SignedInt = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger,
        .mBitsPerChannel = 32,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 32/8 * 2,
        .mBytesPerPacket = 32/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const BellAudioFileFormatDescription kBellFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_Float = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat,
        .mBitsPerChannel = 32,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 32/8 * 2,
        .mBytesPerPacket = 32/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

const BellAudioFileFormatDescription kBellFileFormat_CAF_LPCM_Stereo_44_1_64bit_Packed_Float = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat,
        .mBitsPerChannel = 64,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 64/8 * 2,
        .mBytesPerPacket = 64/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};


/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_CAF_MPEG4AAC_Stereo_HardwareCodec = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleHardwareAudioCodecManufacturer,
    .extension = "caf\0"
};

/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_CAF_MPEG4AAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_CAF_IMA4_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatAppleIMA4,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};

/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_CAF_ALAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileCAFType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatAppleLossless,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "caf\0"
};



/////////////////////////////////////////////////////////////////////////
#pragma mark - File Formats - AAC
/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_AAC_MPEG4AAC_Stereo_HardwareCodec = {
    .fileTypeId = kAudioFileAAC_ADTSType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleHardwareAudioCodecManufacturer,
    .extension = "aac\0"
};

const BellAudioFileFormatDescription kBellFileFormat_AAC_MPEG4AAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileAAC_ADTSType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aac\0"
};



/////////////////////////////////////////////////////////////////////////
#pragma mark - File Formats - M4A
/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_M4A_MPEG4AAC_Stereo_HardwareCodec = {
    .fileTypeId = kAudioFileM4AType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleHardwareAudioCodecManufacturer,
    .extension = "m4a\0"
};

/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_M4A_MPEG4AAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileM4AType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatMPEG4AAC,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "m4a\0"
};

/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_M4A_ALAC_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileM4AType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatAppleLossless,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "m4a\0"
};


/////////////////////////////////////////////////////////////////////////
#pragma mark - AIFF
/////////////////////////////////////////////////////////////////////////

const BellAudioFileFormatDescription kBellFileFormat_AIFF_LPCM_Stereo_44_1_16bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileAIFFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 16,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 16/8 * 2,
        .mBytesPerPacket = 16/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aif\0"
};

const BellAudioFileFormatDescription kBellFileFormat_AIFF_LPCM_Stereo_44_1_24bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileAIFFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 24,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 24/8 * 2,
        .mBytesPerPacket = 24/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aif\0"
};

const BellAudioFileFormatDescription kBellFileFormat_AIFF_LPCM_Stereo_44_1_32bit_Packed_SignedInt_BigEndian = {
    .fileTypeId = kAudioFileAIFFType,
    .streamFormat = {
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mChannelsPerFrame = 2,
        .mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian,
        .mBitsPerChannel = 32,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = 32/8 * 2,
        .mBytesPerPacket = 32/8 * 2 * 1
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aif\0"
};


/////////////////////////////////////////////////////////////////////////
#pragma mark - File Formats - AIFC (AIFF compressed)
/////////////////////////////////////////////////////////////////////////

/** AIFF plus compression.  You can still used the .aiff extension */
const BellAudioFileFormatDescription kBellFileFormat_AIFC_IM4_Stereo_SoftwareCodec = {
    .fileTypeId = kAudioFileAIFCType,
    .streamFormat = {
        .mSampleRate = kAudioStreamAnyRate,
        .mFormatID = kAudioFormatAppleIMA4,
        .mChannelsPerFrame = 2
    },
    .codecManufacturer = kAppleSoftwareAudioCodecManufacturer,
    .extension = "aif\0"
};

