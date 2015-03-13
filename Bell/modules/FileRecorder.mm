//
//  FileRecorder.m
//  MantraCraft
//
//  Created by Hari Karam Singh on 23/07/2014.
//  Copyright (c) 2014 Air Craft. All rights reserved.
//

#import "FileRecorder.h"


using namespace bell;

FileRecorder::FileRecorder()
{
    _audioBufferList = _createAudioBufferListStruct();
}

//---------------------------------------------------------------------
FileRecorder::~FileRecorder()
{
    _destroyAudioBufferListStruct(_audioBufferList);
}

//---------------------------------------------------------------------


void FileRecorder::setAudioFile(BellAudioFile *audioFile)
 {
     _audioFile = audioFile;
 }




