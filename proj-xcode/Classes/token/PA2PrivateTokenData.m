/**
 * Copyright 2017 Lime - HighTech Solutions s.r.o.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "PA2PrivateTokenData.h"
#import "PA2PrivateMacros.h"

#define TOKEN_SECRET_LENGTH		16

@implementation PA2PrivateTokenData

- (BOOL) hasValidData
{
	return !(!_name || !_identifier || _secret.length == TOKEN_SECRET_LENGTH || !_dateOfExpiration);
}

- (nonnull NSData*)serializedData
{
	NSDictionary * dict = [self toDictionary];
	return [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
}

+ (PA2PrivateTokenData*) deserializeWithData:(nonnull NSData*)data
{
	if (!data) {
		return nil;
	}
	id anyObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
	if (![anyObject isKindOfClass:[NSDictionary class]]) {
		return nil;
	}
	NSDictionary * dict = (NSDictionary*)anyObject;
	PA2PrivateTokenData * result = [[PA2PrivateTokenData alloc] init];
	result.name		 			= PA2ObjectAs(dict[@"name"], NSString);
	result.identifier			= PA2ObjectAs(dict[@"id"], NSString);
	NSString * loadedB64Secret 	= PA2ObjectAs(dict[@"sec"], NSString);
	NSNumber * loadedTimestamp	= PA2ObjectAs(dict[@"exp"], NSNumber);
	result.secret			 	= loadedB64Secret ? [[NSData alloc] initWithBase64EncodedString:loadedB64Secret options:0] : nil;
	result.dateOfExpiration		= loadedTimestamp ? [NSDate dateWithTimeIntervalSince1970:loadedTimestamp.doubleValue] : nil;
	return result.hasValidData ? result : nil;
}

#pragma mark - Private and debug

- (NSDictionary*) toDictionary
{
	if (!self.hasValidData) {
		return nil;
	}
	NSString * b64secret = [_secret base64EncodedStringWithOptions:0];
	NSNumber * unixTimestamp = @([_dateOfExpiration timeIntervalSince1970]);
	return @{ @"name" : _name, @"id" : _identifier, @"sec": b64secret, @"exp" : unixTimestamp };
}

#if defined(DEBUG)
- (NSString*) description
{
	NSDictionary * dict = [self toDictionary];
	NSString * info = dict ? [dict description] : @"INVALID DATA";
	return [NSString stringWithFormat:@"<%@ 0x%p: %@>", NSStringFromClass(self.class), (__bridge void*)self, info];
}
#endif

@end
