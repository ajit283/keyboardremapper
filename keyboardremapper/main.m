//
//  main.m
//  keyboardremapper
//
//  Created by Ajit Mistry on 26.07.22.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>

double spacedown = 0;
double spaceup = 0;
bool space = false;
double jdown = 0;
double jup = 0;
bool j = false;
double lock = 0;
bool spc = false;

/*
 kVK_ANSI_I                    = 0x22 = 34,

  kVK_ANSI_L                    = 0x25 = 37,
  kVK_ANSI_J                    = 0x26 = 38,

  kVK_ANSI_K                    = 0x28 = 40,
 kVK_LeftArrow                 = 0x7B = 123,
   kVK_RightArrow                = 0x7C = 124,
   kVK_DownArrow                 = 0x7D = 125,
   kVK_UpArrow                   = 0x7E = 126
 kVK_F18                       = 0x4F,
 kVK_F19                       = 0x50,
 kVK_F20                       = 0x5A,
 kVK_F13                       = 0x69,
  kVK_F16                       = 0x6A,
  kVK_F14                       = 0x6B,
  kVK_F10                       = 0x6D,
  kVK_F12                       = 0x6F,
  kVK_F15                       = 0x71,
 */

int keys[] = {38, 40, 37, 34, kVK_ANSI_W, kVK_ANSI_R};

int64_t currentKey = 69;

struct key {
    double keydown;
    double keyup;
    bool space;
};
int valueinarray(int64_t val)
{
    if(val == 38 || val == 40 || val == 37 || val==34 || val==kVK_ANSI_W || val==kVK_ANSI_R){
        NSLog(@"true");
        return 1;
    }
    return 0;
}

int getLayerKey(int64_t currentKey){
    if(currentKey == 38){
        return 123;
  } else if(currentKey == 40){
        return 125;
    } else if(currentKey == 37){
      return 124;
    } else if(currentKey == 34){
        return 126;
    } else if(currentKey == kVK_ANSI_W){
        return kVK_F18;
    } else if(currentKey == kVK_ANSI_R){
        return kVK_F19;
    }
    return 0x00;
}








CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
  //0x0b is the virtual keycode for "b"
  //0x09 is the virtual keycode for "v"
    CGEventRef pressspace = CGEventCreateKeyboardEvent(NULL, 0x31, true);
    CGEventRef releasespace = CGEventCreateKeyboardEvent(NULL, 0x31, false);
   
    int64_t keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    if (valueinarray(CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode)) == 1 && type == kCGEventKeyDown) {
        currentKey = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        NSLog(@"currentKey %d", currentKey);
        spc = false;
            NSLog(@"j down");
            //space = true;
            jdown = (double) CFAbsoluteTimeGetCurrent();
        
    
    }
    
    CGEventRef presscurrentKey = CGEventCreateKeyboardEvent(NULL, currentKey, true);
                  CGEventRef releasecurrentKey = CGEventCreateKeyboardEvent(NULL, currentKey, false);
       CGEventRef presslayer = CGEventCreateKeyboardEvent(NULL, getLayerKey(currentKey), true);
            CGEventRef releaselayer = CGEventCreateKeyboardEvent(NULL, getLayerKey(currentKey), false);
    
  if (CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == 0x31 && type == kCGEventKeyDown && lock == 0) {
      if(space == false){
          NSLog(@"space down %f", lock);
          space = true;
          spacedown = (double) CFAbsoluteTimeGetCurrent();
      }
      //NSLog(@"spacedown variable: ", type);k
      CFRelease(pressspace);
      CFRelease(releasespace);
      CFRelease(presscurrentKey);
      CFRelease(releasecurrentKey);
      CFRelease(presslayer);
      CFRelease(releaselayer);
      NSLog(@"exit");
      return NULL;
  } else if (CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == 0x31 && type == kCGEventKeyUp && lock == 0) {
      if(space == true){
          NSLog(@"space up %f", lock);
          space = false;
          spc=true;
          spaceup = (double)CFAbsoluteTimeGetCurrent();
          if((spacedown - spaceup < 0.2) && (jdown - spacedown < 0) && (jup - spacedown < 0) ){
              NSLog(@"normal space sent");
              
             
             lock = 1;
              NSLog(@"lock: %f", lock);
              CGEventTapPostEvent(proxy, pressspace);
              CGEventTapPostEvent(proxy, releasespace);
              
              CFRelease(pressspace);
                       CFRelease(releasespace);
                       CFRelease(presscurrentKey);
                       CFRelease(releasecurrentKey);
                       CFRelease(presslayer);
                       CFRelease(releaselayer);
              lock = 0;
                   return NULL;
              
                   
          }
      }
      //NSLog(@"spacedown variable: ", type);
      CFRelease(pressspace);
          CFRelease(releasespace);
          CFRelease(presscurrentKey);
          CFRelease(releasecurrentKey);
          CFRelease(presslayer);
          CFRelease(releaselayer);
      return NULL;
  }
    

  
  else if(CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == currentKey && type == kCGEventKeyUp && lock == 0 && space && (((double)jdown - (double) spacedown) < 0.2)){
     
      
      
          NSLog(@"second order left arrow");
          lock= 1;
          CGEventTapPostEvent(proxy, presslayer);
          CGEventTapPostEvent(proxy, releaselayer);
      
      NSLog(@"got here");
     /* CFRelease(pressspace);
          CFRelease(releasespace);
          CFRelease(presscurrentKey);
          CFRelease(releasecurrentKey);
          CFRelease(presslayer);
          CFRelease(releaselayer);*/
      //return NULL;
      
      
      
  }
  
  
   else if((((double)CFAbsoluteTimeGetCurrent() - (double) spacedown) > 0.2) && space && lock == 0 && CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == currentKey){
                  CGEventSetIntegerValueField(event, kCGKeyboardEventKeycode, getLayerKey(currentKey));
                  NSLog(@"space down, left arrow");
                  CFRelease(pressspace);
                      CFRelease(releasespace);
                      CFRelease(presscurrentKey);
                      CFRelease(releasecurrentKey);
                      CFRelease(presslayer);
                      CFRelease(releaselayer);
                  return event;
              }
    
//   else if(CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == currentKey && type == kCGEventKeyUp && lock == 0 && !space && spc){
//
//
//
//
//         NSLog(@"new2");
//       CGEventTapPostEvent(proxy, presscurrentKey);
//               CGEventTapPostEvent(proxy, releasecurrentKey);
//              CFRelease(pressspace);
//                       CFRelease(releasespace);
//                       CFRelease(presscurrentKey);
//                       CFRelease(releasecurrentKey);
//                       CFRelease(presslayer);
//                       CFRelease(releaselayer);
//       spc = false;
//              return NULL;
//
//
//
//        }
    
  else if (CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == currentKey && type == kCGEventKeyUp && lock == 0 && !space && spc) {
          
          
          long timedifference = ((double)CFAbsoluteTimeGetCurrent() -  spacedown);
          NSLog(@"diff: %ld", timedifference);
          //NSLog(@"spacedown variable: ", type);
      if(!space){
          NSLog(@"space not down, %d",currentKey);
     
      //lock = 1;
          CGEventTapPostEvent(proxy, pressspace);
          CGEventTapPostEvent(proxy, releasespace);
     CGEventTapPostEvent(proxy, presscurrentKey);
        CGEventTapPostEvent(proxy, releasecurrentKey);
          
          CFRelease(pressspace);
                   CFRelease(releasespace);
                   CFRelease(presscurrentKey);
                   CFRelease(releasecurrentKey);
                   CFRelease(presslayer);
                   CFRelease(releaselayer);
          spc = false;
          return NULL;
          
          
          
          
          
          
      }
      CFRelease(pressspace);
          CFRelease(releasespace);
          CFRelease(presscurrentKey);
          CFRelease(releasecurrentKey);
          CFRelease(presslayer);
          CFRelease(releaselayer);
          return NULL;
      }
  else if(CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == currentKey && type == kCGEventKeyDown && lock == 0 && space){
        
         
      NSLog(@"new");
      CFRelease(pressspace);
               CFRelease(releasespace);
               CFRelease(presscurrentKey);
               CFRelease(releasecurrentKey);
               CFRelease(presslayer);
               CFRelease(releaselayer);
      return NULL;
         
         
         
     }
  
  
  
  
    
    lock = 0;
    NSLog(@"exit, lock: %f", lock);
    CFRelease(pressspace);
        CFRelease(releasespace);
        CFRelease(presscurrentKey);
        CFRelease(releasecurrentKey);
        CFRelease(presslayer);
        CFRelease(releaselayer);
    return event;
}




CGEventMask mask = CGEventMaskBit(kCGEventKeyUp) |
                   CGEventMaskBit(kCGEventKeyDown);

int main(int argc, char *argv[]) {
    @autoreleasepool {
        
        
        
    
  CFRunLoopSourceRef runLoopSource;

  CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, mask, myCGEventCallback, NULL);
   
    
  if (!eventTap) {
    NSLog(@"Couldn't create event tap!!");
    exit(1);
  }

  runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);

  CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);

  CGEventTapEnable(eventTap, true);

  CFRunLoopRun();

  CFRelease(eventTap);
  CFRelease(runLoopSource);
    }

  exit(0);
}
