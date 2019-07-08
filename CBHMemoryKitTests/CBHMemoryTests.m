//  CBHMemoryTests.m
//  CBHMemoryKitTests
//
//  Created by Christian Huxtable, June 2019.
//  Copyright (c) 2019, Christian Huxtable <chris@huxtable.ca>
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
//  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
//  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

#import <XCTest/XCTest.h>

@import CBHMemoryKit;


@interface CBHMemoryTests : XCTestCase
@end


@implementation CBHMemoryTests


#pragma mark - Allocation

- (void)test_alloc
{
	void *memory = CBHMemory_alloc(10, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Allocation failed.");

	CBHMemory_free(memory);
}

- (void)test_calloc
{
	NSUInteger *memory = CBHMemory_calloc(10, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Allocation failed.");

	for (NSUInteger i = 0; i < 10; ++i)
	{
		XCTAssertEqual(memory[i], 0, @"Failed to zero memory.");
	}

	CBHMemory_free(memory);
}


#pragma mark - Reallocation

- (void)test_realloc
{
	void *memory = CBHMemory_alloc(10, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Allocation failed.");

	memory = CBHMemory_realloc(memory, 20, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Reallocation failed.");

	CBHMemory_free(memory);
}


- (void)test_recalloc
{
	NSUInteger *memory = CBHMemory_calloc(10, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Allocation failed.");

	for (NSUInteger i = 0; i < 10; ++i)
	{
		XCTAssertEqual(memory[i], 0, @"Failed to zero memory.");
	}

	memory = CBHMemory_recalloc(memory, 10, 20, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Reallocation failed.");

	for (NSUInteger i = 0; i < 20; ++i)
	{
		XCTAssertEqual(memory[i], 0, @"Failed to zero memory.");
	}

	memory = CBHMemory_recalloc(memory, 20, 10, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Reallocation failed.");

	for (NSUInteger i = 0; i < 10; ++i)
	{
		XCTAssertEqual(memory[i], 0, @"Failed to zero memory.");
	}

	CBHMemory_free(memory);
}


#pragma mark - Copying

- (void)test_copy
{
	NSUInteger *memory = CBHMemory_calloc(10, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Allocation failed.");

	for (NSUInteger i = 0; i < 10; ++i) { memory[i] = i; }

	NSUInteger *copy = CBHMemory_copy(memory, 10, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Allocation failed.");

	for (NSUInteger i = 0; i < 10; ++i)
	{
		XCTAssertEqual(copy[i], i, @"Failed to copy memory.");
	}

	CBHMemory_free(memory);
	CBHMemory_free(copy);
}

- (void)test_copyTo
{
	NSUInteger *memory = CBHMemory_calloc(10, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Allocation failed.");

	for (NSUInteger i = 0; i < 10; ++i) { memory[i] = i; }


	NSUInteger *copy = CBHMemory_calloc(10, sizeof(NSUInteger));
	XCTAssertTrue(memory != NULL, @"Allocation failed.");
	
	CBHMemory_copyTo(memory, copy, 10, sizeof(NSUInteger));

	for (NSUInteger i = 0; i < 10; ++i)
	{
		XCTAssertEqual(copy[i], i, @"Failed to copy memory.");
	}

	CBHMemory_free(memory);
	CBHMemory_free(copy);
}


#pragma mark - Swapping

- (void)test_swapBytes
{
	NSUInteger *memory = CBHMemory_calloc(2, sizeof(NSUInteger));

	memory[0] = 0;
	memory[1] = NSUIntegerMax;

	CBHMemory_swapBytes(&memory[0], &memory[1], 1, sizeof(NSUInteger));

	XCTAssertEqual(memory[0], NSUIntegerMax, @"Failed to swap all bytes.");
	XCTAssertEqual(memory[1], 0, @"Failed to swap all bytes.");

	CBHMemory_free(memory);
}


#pragma mark - Zeroing

- (void)test_zero
{
	NSUInteger array[8] = { NSUIntegerMax, NSUIntegerMax, NSUIntegerMax, NSUIntegerMax, NSUIntegerMax, NSUIntegerMax, NSUIntegerMax, NSUIntegerMax };

	CBHMemory_zero(array, 8, sizeof(NSUInteger));

	for (NSUInteger i = 0; i < 8; ++i)
	{
		XCTAssertEqual(array[i], 0, @"Failed to zero memory.");
	}
}


#pragma mark - Comparison

- (void)test_compare
{
	NSUInteger array0[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
	NSUInteger array1[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
	NSUInteger array2[8] = { 1, 2, 3, 4, 5, 6, 7, 0 };

	XCTAssertTrue(CBHMemory_compare(array0, array0, 8, sizeof(NSUInteger)), @"Comparison of equal memory failed.");
	XCTAssertTrue(CBHMemory_compare(array0, array1, 8, sizeof(NSUInteger)), @"Comparison of equal memory failed.");
	XCTAssertFalse(CBHMemory_compare(array0, array2, 8, sizeof(NSUInteger)), @"Comparison of non-equal memory failed.");
}


#pragma mark - Overflowing

- (void)test_overflow
{
	//bool CBHMemory_willOverflowSize(const size_t num, const size_t size, const size_t max)

	XCTAssertFalse(CBHMemory_willOverflow(0, sizeof(NSUInteger)), @"Overflowed.");
	XCTAssertFalse(CBHMemory_willOverflow(1, sizeof(NSUInteger)), @"Overflowed.");
	XCTAssertFalse(CBHMemory_willOverflow(8, sizeof(NSUInteger)), @"Overflowed.");
	XCTAssertTrue(CBHMemory_willOverflow(NSUIntegerMax, sizeof(NSUInteger)), @"Didn't overflow.");
}


#pragma mark - Guards

- (void)test_guardNull
{
	XCTAssertEqual(CBHMemory_copy(NULL, 10, sizeof(NSUInteger)), NULL, @"Allocation succeeded when it shouldn't have.");
	CBHMemory_zero(NULL, 8, sizeof(NSUInteger));
}

- (void)test_guardAlloc
{
	XCTAssertNotEqual(CBHMemory_alloc(0, sizeof(NSUInteger)), NULL, @"Allocation didn't succeed.");
	XCTAssertEqual(CBHMemory_alloc(8, 0), NULL, @"Allocation succeeded when it shouldn't have.");

	NSUInteger array[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
	CBHMemory_zero(array, 8, 0);

	for (NSUInteger i = 0; i < 8; ++i)
	{
		XCTAssertNotEqual(array[i], 0, @"Zeroed memory when it shouldn't have.");
	}
}

- (void)test_guardAllocOverflow
{
	XCTAssertEqual(CBHMemory_alloc(NSUIntegerMax, sizeof(NSUInteger)), NULL, @"Allocation succeeded when it shouldn't have.");

	NSUInteger array[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };
	CBHMemory_zero(array, 8, NSUIntegerMax);

	for (NSUInteger i = 0; i < 8; ++i)
	{
		XCTAssertNotEqual(array[i], 0, @"Zeroed memory when it shouldn't have.");
	}
}

@end
