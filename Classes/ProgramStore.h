//
//  ProgramStore.h
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProgramStore : NSObject {
    // ProgramDescriptor is a Dictionary with:
    //
    //  title       - Title which is displayed on the function button panel next to
    //              the top button.
    //  description - Description of the program. Pressing teh title shows a panel
    //              with the description
    //  cagegory    - Category of this program, for grouping
    //  program     - Array of program instructions (see below)
    //
    //  'prog' is an array of NSDictionary entries:
    //
    //  name - NSString: name of function or subroutine
    //  key  - NSNumber: index of USER key assigned to function, -1 if this is a subroutine
    //  inst - NSArray: instructions for this function or subroutine
    //  
    NSMutableDictionary* m_programDescriptor;
    BOOL m_programDescriptorDirty;
}

@property(readonly) NSArray* program;
@property(readonly) NSUInteger currentFunction;
@property(readonly) NSUInteger currentInstruction;
@property(assign) NSString* title;
@property(assign) NSString* category;
@property(assign) NSString* description;

// Program list is an array of dictionaries. Each dictionary contains:
//
//  'category' - category name
//  'array' - array of program names in that category
//
// Categories are in alphabetical order, except that the 
// first category will be called 'Uncategorized' if there are any
// uncategorized programs. The currently loaded program appears in 
// the list unless it is unnamed.
+ (NSArray*)programList;

- (id) initWithProgramPath:(NSString*) path;

+ (NSDictionary*)detailsForProgram:(NSString*) title withCategory:(NSString*) category;
- (void)loadProgram:(NSString*) title withCategory:(NSString*) category;
- (void)setProgramDescriptor:(NSDictionary*) program;
- (NSString*)programToPropertyListString;

- (void)addFunction;
- (void)addInstructionString:(NSString*) instruction;
- (BOOL)canAssignUserKey;
- (void)nameCurrentSubroutine:(int) reg;
- (void)nameCurrentFunction:(NSString*) name;
- (void)selectFunction:(NSUInteger) func instruction:(NSUInteger) inst;
- (void)currentFunctionName:(NSString**) name key:(int*) key;
- (NSString*)functionNameForKey:(int) key;
- (void)deleteCurrentFunction;
- (void)deleteCurrentInstruction;
- (NSArray*)instructionsForSubr:(int) reg function:(NSUInteger*) function;
- (void)clear;

- (void)cleanup;

@end
