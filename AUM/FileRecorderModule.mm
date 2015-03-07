//
//  FileRecorderModule.m
//  MantraCraft
//
//  Created by Hari Karam Singh on 23/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import "FileRecorderModule.h"


using namespace AUM;

FileRecorderModule::FileRecorderModule()
{
    _audioBufferList = _createAudioBufferListStruct();
}

//---------------------------------------------------------------------
FileRecorderModule::~FileRecorderModule()
{
    _destroyAudioBufferListStruct(_audioBufferList);
}

//---------------------------------------------------------------------


void FileRecorderModule::setAudioFile(AUMAudioFile *audioFile)
 {
     _audioFile = audioFile;
 }




