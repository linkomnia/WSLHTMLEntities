//
//  WSLHTMLEntities.m
//  WSLHTMLEntities
//
//  Created by Stephen Darlington on 05/06/2012.
//  Copyright (c) 2012 Wandle Software Limited. All rights reserved.
//

#import "WSLHTMLEntities.h"
#import "WSLHTMLEntityDefinitions.h"

// Remove dependency on header file generated by Flex by declaring the C types and
// functions that we use here.
typedef void* yyscan_t;
typedef struct yy_buffer_state *YY_BUFFER_STATE;

int WSLlex_init(yyscan_t* yyscanner);
int WSLlex (yyscan_t yyscanner);
int WSLlex_destroy(yyscan_t yyscanner);
void WSLrestart (FILE *input_file ,yyscan_t yyscanner );
YY_BUFFER_STATE WSL_scan_string (const char *yy_str ,yyscan_t yyscanner );
char *WSLget_text (yyscan_t yyscanner );

// And now on to the good stuff...

@interface WSLHTMLEntities ()

+(NSString*)convertHTMLtoString:(NSString*)html scanner:(yyscan_t)scanner;

@end

@implementation WSLHTMLEntities {
    yyscan_t _scanner;
}

-(id)init {
    self = [super init];
    if (self) {
        WSLlex_init(&_scanner);
    }
    return self;
}

-(void)dealloc {
    WSLlex_destroy(_scanner);
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

-(NSString*)convertHTMLtoString:(NSString*)html {
    WSLrestart(NULL, _scanner);
    return [WSLHTMLEntities convertHTMLtoString:html scanner:_scanner];
}

+(NSString*)convertHTMLtoString:(NSString*)html {
    yyscan_t scanner;
    
    WSLlex_init(&scanner);
    NSString* retv = [WSLHTMLEntities convertHTMLtoString:html scanner:scanner];
    WSLlex_destroy(scanner);
    return retv;
}

+(NSString*)convertHTMLtoString:(NSString*)html scanner:(yyscan_t)scanner {
    if (! [html canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        // if it's not UTF8 I'm not sure what to do with it...
        return html;
    }
    
    const char* text = [html UTF8String];
    
    WSL_scan_string(text, scanner);
    int expression;
    NSMutableString* output = [NSMutableString string];
    while ((expression = WSLlex(scanner))) {
        // TODO: there has to be a more efficient way of doing this...
        switch (expression) {
            case WSL_ENTITY_NOMATCH: {
                const char *str = WSLget_text(scanner);
                NSString *s = [NSString stringWithUTF8String:str];
                if (s != nil) {
                    [output appendString:s];
                }
                break;
            }
            case WSL_ENTITY_NUMBER:
                expression = atoi(&WSLget_text(scanner)[2]);
                // fall through so expression is added to string
            default:
                [output appendFormat:@"%C", (unsigned short) expression];
                break;
        }
    }
    
    return output;
}

@end
