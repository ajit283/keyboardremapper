//
//  main.m
//  keyboardremapper
//
//  Created by Ajit Mistry on 26.07.22.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>

double spaceDownTime = 0;
double spaceUpTime = 0;
bool isSpaceDown = false;
double currentKeyDown = 0;
double currentKeyUp = 0;
bool isCurrentKeyDown = false;
double lock = 0;
bool spcFlag = false;

const double TIMEOUT = 0.2;

CGEventMask mask = CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventKeyDown);


int64_t currentKey = 0;


// define the keymap here (my setup: VIM arrows shifted one key to the right)
int64_t getLayerKey(int64_t currentKey) {
    switch(currentKey) {
        case kVK_ANSI_J:
            return kVK_LeftArrow;
        case kVK_ANSI_K:
            return kVK_DownArrow;
        case kVK_ANSI_Semicolon:
            return kVK_RightArrow;
        case kVK_ANSI_L:
            return kVK_UpArrow;
        default:
            return 0x00;
    }
}






CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    
   
    
    int64_t keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    
    if (getLayerKey(keycode) != 0x00 && type == kCGEventKeyDown) {
        currentKey = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        spcFlag = false;
        NSLog(@"isCurrentKeyDown true");
        currentKeyDown = CFAbsoluteTimeGetCurrent();
    }
    
    
   
    
    if (CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == 0x31 && type == kCGEventKeyDown && lock == 0) {
        if(isSpaceDown == false){
            NSLog(@"space down %f", lock);
            isSpaceDown = true;
            spaceDownTime = CFAbsoluteTimeGetCurrent();
        }
    
        NSLog(@"exit");
        return NULL;
        
    } 
    else if (CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == 0x31 && type == kCGEventKeyUp && lock == 0) {
        if(isSpaceDown == true){
            NSLog(@"space up %f", lock);
            isSpaceDown = false;
            spcFlag = true;
            spaceUpTime = CFAbsoluteTimeGetCurrent();
            if((spaceDownTime - spaceUpTime < TIMEOUT) && (currentKeyDown - spaceDownTime < 0) && (currentKeyUp - spaceUpTime < 0) ){
                NSLog(@"normal space emitted");
                
                
                lock = 1;
                CGEventRef pressspace = CGEventCreateKeyboardEvent(NULL, 0x31, true);
                CGEventRef releasespace = CGEventCreateKeyboardEvent(NULL, 0x31, false);
                
                CGEventTapPostEvent(proxy, pressspace);
                CGEventTapPostEvent(proxy, releasespace);
                
                CFRelease(pressspace);
                CFRelease(releasespace);
                
                lock = 0;
                
                return NULL;
                
                
            }
        }
        
        return NULL;
    }
    else if(CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == currentKey && type == kCGEventKeyUp && lock == 0 && isSpaceDown && ((currentKeyDown - spaceDownTime) < TIMEOUT)){
        
        
        
        NSLog(@"layerKey emitted (second order)");
        lock = 1;
        CGEventRef presslayer = CGEventCreateKeyboardEvent(NULL, getLayerKey(currentKey), true);
        CGEventRef releaselayer = CGEventCreateKeyboardEvent(NULL, getLayerKey(currentKey), false);
        CGEventTapPostEvent(proxy, presslayer);
        CGEventTapPostEvent(proxy, releaselayer);
        CFRelease(presslayer);
        CFRelease(releaselayer);
        
        
        
        
    }
    
    
    else if(((CFAbsoluteTimeGetCurrent() - spaceDownTime) > TIMEOUT) && isSpaceDown && lock == 0 && CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == currentKey){
        CGEventSetIntegerValueField(event, kCGKeyboardEventKeycode, getLayerKey(currentKey));
        NSLog(@"space down, layerKey emitted");
        return event;
    }
    
    
    else if (CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == currentKey && type == kCGEventKeyUp && lock == 0 && !isSpaceDown && spcFlag) {
        
        
        long timedifference = (CFAbsoluteTimeGetCurrent() -  spaceDownTime);
        NSLog(@"diff: %ld", timedifference);
        
        if(!isSpaceDown){
            
            
            CGEventRef pressspace = CGEventCreateKeyboardEvent(NULL, 0x31, true);
            CGEventRef releasespace = CGEventCreateKeyboardEvent(NULL, 0x31, false);
            CGEventRef presscurrentKey = CGEventCreateKeyboardEvent(NULL, currentKey, true);
            CGEventRef releasecurrentKey = CGEventCreateKeyboardEvent(NULL, currentKey, false);
            
            CGEventTapPostEvent(proxy, pressspace);
            CGEventTapPostEvent(proxy, releasespace);
            CGEventTapPostEvent(proxy, presscurrentKey);
            CGEventTapPostEvent(proxy, releasecurrentKey);
            
            CFRelease(pressspace);
            CFRelease(releasespace);
            CFRelease(presscurrentKey);
            CFRelease(releasecurrentKey);
         
            spcFlag = false;
            return NULL;
            
            
            
            
            
            
        }
        return NULL;
    }
    else if(CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode) == currentKey && type == kCGEventKeyDown && lock == 0 && isSpaceDown){
        
        NSLog(@"new");
        return NULL;
        
    }
    

    lock = 0;
    NSLog(@"exit, lock: %f", lock);
    return event;
}






int main(int argc, char *argv[]) {
    @autoreleasepool {
        CFRunLoopSourceRef runLoopSource;
        
        CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, mask, myCGEventCallback, NULL);
        
        
        if (!eventTap) {
            NSLog(@"Couldn't create event tap");
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
