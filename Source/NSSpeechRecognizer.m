/* Implementation of class NSSpeechRecognizer
   Copyright (C) 2019 Free Software Foundation, Inc.
   
   By: Gregory John Casamento
   Date: Fri Dec  6 04:55:59 EST 2019

   This file is part of the GNUstep Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110 USA.
*/

#import <AppKit/NSSpeechRecognizer.h>
#import <AppKit/NSApplication.h>
#import <Foundation/NSDistantObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSError.h>
#import <Foundation/NSConnection.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSUUID.h>
#import "GSFastEnumeration.h"
#import "AppKit/NSWorkspace.h"

id   _speechRecognitionServer = nil;
BOOL _serverLaunchTested = NO;

#define SPEECH_RECOGNITION_SERVER @"GSSpeechRecognitionServer"

@interface NSObject (SpeechRecognitionServerPrivate)
- (void) addToBlockingRecognizers: (NSString *)s;
- (void) removeFromBlockingRecognizers: (NSString *)s;
- (BOOL) isBlocking: (NSString *)s;
@end

@implementation NSSpeechRecognizer

+ (void) initialize
{
  if (self == [NSSpeechRecognizer class])
    {
      if (nil == _speechRecognitionServer)
        {
          NSWorkspace *ws = [NSWorkspace sharedWorkspace];
          [ws launchApplication: SPEECH_RECOGNITION_SERVER
                       showIcon: NO
                     autolaunch: NO];
        }
    }
}

- (void) processNotification: (NSNotification *)note
{
  NSString *word = (NSString *)[note object];

  if (_listensInForegroundOnly)
    {
      if (_appInForeground == NO)
        {
          return;
        }
    }

  if (_blocksOtherRecognizers)
    {
      if ([_speechRecognitionServer isBlocking: [_uuid UUIDString]] == NO)
        {
          // If we are not a blocking recognizer, then we are blocked...
          return;
        }
    }
  
  word = [word lowercaseString];
  FOR_IN(NSString*, obj, _commands)
    {
      if ([[obj lowercaseString] isEqualToString: word])
        {
          [_delegate speechRecognizer: self
                  didRecognizeCommand: word];
        }
    }
  END_FOR_IN(_commands);
}

- (void) processAppStatusNotification: (NSNotification *)note
{
  NSString *name = [note name];
  
  if ([name isEqualToString: NSApplicationDidBecomeActiveNotification])
    {
      _appInForeground = YES;
    }
  else
    {
      _appInForeground = NO;
    }
}

// Initialize
- (instancetype) init
{
  self = [super init];
  if (self != nil)
    {
      [[NSDistributedNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(processNotification:)
               name: GSSpeechRecognizerDidRecognizeWordNotification
             object: nil];

      [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(processAppStatusNotification:)
               name: NSApplicationDidBecomeActiveNotification
             object: nil];

      [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(processAppStatusNotification:)
               name: NSApplicationDidResignActiveNotification
             object: nil];

      _delegate = nil;
      _blocksOtherRecognizers = NO;
      _listensInForegroundOnly = YES;
      _uuid = [NSUUID UUID];
      
      if (nil == _speechRecognitionServer && !_serverLaunchTested)
        {
          unsigned int i = 0;
          
          // Wait for up to five seconds  for the server to launch, then give up.
          for (i = 0 ; i < 50 ; i++)
            {
              _speechRecognitionServer = [NSConnection
                                           rootProxyForConnectionWithRegisteredName: SPEECH_RECOGNITION_SERVER
                                                                               host: nil];
              RETAIN(_speechRecognitionServer);
              if (nil != _speechRecognitionServer)
                {
                  NSDebugLog(@"Server found!!!");
                  break;
                }
              [NSThread sleepForTimeInterval: 0.1];
            }
          
          // Set a flag so we don't bother waiting for the speech recognition server to
          // launch the next time if it didn't work this time.
          _serverLaunchTested = YES;
        }
    }
  return self;
}

- (void) dealloc
{
  [[NSDistributedNotificationCenter defaultCenter] removeObserver: self];
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  _delegate = nil;
  [super dealloc];
}

// Delegate
- (id<NSSpeechRecognizerDelegate>) delegate
{
  return _delegate;
}

- (void) setDelegate: (id<NSSpeechRecognizerDelegate>)delegate
{
  _delegate = delegate;
}

// Configuring...
- (NSArray *) commands
{
  return _commands;
}

- (void) setCommands: (NSArray *)commands
{
  ASSIGNCOPY(_commands, commands);
}

- (NSString *) displayCommandsTitle
{
  return _displayCommandsTitle;
}

- (void) setDisplayCommandsTitle: (NSString *)displayCommandsTitle
{
  ASSIGNCOPY(_displayCommandsTitle, displayCommandsTitle);
}

- (BOOL) listensInForegroundOnly
{
  return _listensInForegroundOnly;
}

- (void) setListensInForegroundOnly: (BOOL)listensInForegroundOnly
{
  _listensInForegroundOnly = listensInForegroundOnly;
}

- (BOOL) blocksOtherRecognizers
{
  return _blocksOtherRecognizers;
}

- (void) setBlocksOtherRecognizers: (BOOL)blocksOtherRecognizers
{
  if (blocksOtherRecognizers == YES)
    {
      [_speechRecognitionServer addToBlockingRecognizers: [_uuid UUIDString]];
    }
  else
    {
      [_speechRecognitionServer removeFromBlockingRecognizers: [_uuid UUIDString]];
    }
  _blocksOtherRecognizers = blocksOtherRecognizers;
}

// Listening
- (void) startListening
{
  [_speechRecognitionServer startListening];
}

- (void) stopListening
{
  [_speechRecognitionServer stopListening];
}
@end
