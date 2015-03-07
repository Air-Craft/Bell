//
//  AUMDefs.h
//  AUM
//
//  Created by Hari Karam Singh on 14/12/2013.
//  Copyright (c) 2013 Air Craft Media Ltd. All rights reserved.
//

#ifndef __AUMDefs_h
#define __AUMDefs_h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/////////////////////////////////////////////////////////////////////////
#pragma mark - Types
/////////////////////////////////////////////////////////////////////////

typedef Float32 AUM_Sample;

/**
 A way of encapsulating the various enums required to define an output file format.
 */
typedef struct {
    AudioFileTypeID fileTypeId;
    AudioStreamBasicDescription streamFormat;
    UInt32 codecManufacturer;
    char extension[5];      // 4 digits plus \0 null
} AUM_AudioFileFormatDescription;


    
/////////////////////////////////////////////////////////////////////////
#pragma mark - ASBD Consts
/////////////////////////////////////////////////////////////////////////

/**
 Useful default for the cleanest Render callback code.  non-interleaved, stereo, Float32, 44.1kHz. (No longer default to kAudioStreamAnyRate)
 */
FOUNDATION_EXTERN const AudioStreamBasicDescription AUM_kCanonicalStreamFormat;

/////////////////////////////////////////////////////////////////////////
#pragma mark - Audio File Formats
/////////////////////////////////////////////////////////////////////////

/** @name File Formats
 \b Don't forget LPCM ones need a sample rate set
 */
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_LPCM_Stereo_44_1_16bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_LPCM_Stereo_44_1_24bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_LPCM_Stereo_44_1_16bit_Packed_SignedInt;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_LPCM_Stereo_44_1_24bit_Packed_SignedInt;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_SignedInt;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_LPCM_Stereo_44_1_32bit_Packed_Float;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_LPCM_Stereo_44_1_64bit_Packed_Float;


FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_MPEG4AAC_Stereo_HardwareCodec;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_MPEG4AAC_Stereo_SoftwareCodec;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_IMA4_Stereo_SoftwareCodec;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_CAF_ALAC_Stereo_SoftwareCodec;

FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_AAC_MPEG4AAC_Stereo_HardwareCodec;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_AAC_MPEG4AAC_Stereo_SoftwareCodec;

FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_M4A_MPEG4AAC_Stereo_HardwareCodec;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_M4A_MPEG4AAC_Stereo_SoftwareCodec;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_M4A_ALAC_Stereo_SoftwareCodec;

FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_AIFF_LPCM_Stereo_44_1_16bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_AIFF_LPCM_Stereo_44_1_24bit_Packed_SignedInt_BigEndian;
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_AIFF_LPCM_Stereo_44_1_32bit_Packed_SignedInt_BigEndian;

/** AIFF plus compression.  You can still used the .aiff extension */
FOUNDATION_EXTERN const AUM_AudioFileFormatDescription AUM_kFileFormat_AIFC_IM4_Stereo_SoftwareCodec;

#endif // header
