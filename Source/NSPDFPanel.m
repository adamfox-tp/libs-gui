/* Implementation of class NSPDFPanel
   Copyright (C) 2019 Free Software Foundation, Inc.
   
   By: heron
   Date: Sat Nov 16 21:21:00 EST 2019

   This file is part of the GNUstep Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.
*/

#include <AppKit/NSPDFPanel.h>
#include <AppKit/NSPDFInfo.h>
#include <AppKit/NSWindow.h>
#include <AppKit/NSViewController.h>
#include <Foundation/NSString.h>

@implementation NSPDFPanel

+ (NSPDFPanel *) panel
{
  return nil;
}

- (NSViewController *) accessoryController
{
  return nil;
}

- (void) setAccessoryController: (NSViewController *)accessoryView
{
}

- (NSPDFPanelOptions) options
{
  return 0;
}

- (void) setPDFPanelOptions: (NSPDFPanelOptions)opts
{
}

- (NSString *) defaultFileName
{
  return nil;
}

- (void) setDefaultFileName: (NSString *)fileName
{
}

- (void) begineSheetWithPDFInfo: (NSPDFInfo *)pdfInfo
                 modalForWindow: (NSWindow *)window
              completionHandler: (GSPDFPanelCompletionHandler)handler
{
}

@end

