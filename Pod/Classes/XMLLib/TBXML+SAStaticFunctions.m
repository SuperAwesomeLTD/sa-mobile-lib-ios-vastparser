//
//  TBXML+SAStaticFunctions.m
//  Pods
//
//  Copyright (c) 2015 SuperAwesome Ltd. All rights reserved.
//
//  Created by Gabriel Coman on 12/14/2015.
//
//

#import "TBXML+SAStaticFunctions.h"

@implementation TBXML (SAStaticFunctions)

+ (void) searchSiblingsAndChildrenOf:(TBXMLElement*)element
                             forName:(NSString*)name
                                into:(NSMutableArray*)container {
    
    // do a recursive search while the element still has either siblings or
    // chilren to go to
    do {
        if ([[TBXML elementName:element] isEqualToString:name]) {
            [container addObject:[NSValue valueWithPointer:element]];
        }
        
        if (element->firstChild) {
            [self searchSiblingsAndChildrenOf:element->firstChild
                                      forName:name
                                         into:container];
        }
    } while ((element = element->nextSibling));
}

+ (NSMutableArray*) searchSiblingsAndChildrenOf:(TBXMLElement*)element
                                        forName:(NSString*)name {
    
    // init container
    NSMutableArray *container = [[NSMutableArray alloc] init];
    
    // call the above function to fill the array
    [self searchSiblingsAndChildrenOf:element forName:name into:container];
    return container;
}

+ (NSValue*) findFirstIntanceInSiblingsAndChildrenOf:(TBXMLElement *)element
                                             forName:(NSString *)name {
    NSMutableArray *container = [self searchSiblingsAndChildrenOf:element forName:name];
    if (container.count >= 1) {
        return [container firstObject];
    }
    return NULL;
}

+ (void) searchSiblingsAndChildrenOf:(TBXMLElement*)element
                             forName:(NSString*)name
                         andInterate:(TBXMLIterateBlock)block {
    
    // get the container array full of pointers to found elements
    NSMutableArray *container = [self searchSiblingsAndChildrenOf:element forName:name];
    
    // itterate through the container and call block(_element) on it
    for (NSValue *pointerToElement in container) {
        TBXMLElement *_element = [pointerToElement pointerValue];
        block(_element);
    }
}


+ (BOOL) checkSiblingsAndChildrenOf:(TBXMLElement *)element
                            forName:(NSString *)name {
    
    // do a recursive search for an element with given name, and when at least
    // one item is found, return true
    do {
        if ([[TBXML elementName:element] isEqualToString:name]) {
            return true;
        }
        
        if (element->firstChild) {
            return [self checkSiblingsAndChildrenOf:element->firstChild forName:name];
        }
    } while ((element = element->nextSibling));
    
    // no element found, then return false
    return false;
}

@end
