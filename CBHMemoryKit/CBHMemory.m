//  CBHMemory.c
//  CBHMemoryKit
//
//  Created by Christian Huxtable, November 2018.
//  Copyright (c) 2018, Christian Huxtable <chris@huxtable.ca>
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

#include "CBHMemory.h"

#include <stdlib.h>
#include <string.h>


#define _guardAllocPossible(num, size)\
if ( ((size) <= 0) ) return;\
if ( CBHMemory_willOverflow((num), (size)) ) return

#define _guardAllocPossibleReturn(num, size, retVal)\
if ( ((size) <= 0) ) return (retVal);\
if ( CBHMemory_willOverflow((num), (size)) ) return (retVal)

#define _guardAgainstNull(memory) if ( (memory) == NULL ) return
#define _guardAgainstNullReturn(memory, retVal) if ( (memory) == NULL ) return (retVal)


#pragma mark - Exceptions

const NSExceptionName CBHCallocException = @"CBHCallocException";
const NSExceptionName CBHReallocException = @"CBHReallocException";


#pragma mark - Allocation

inline void *CBHMemory_alloc(const size_t num, const size_t size)
{
	/// Guard against empty size, and overflow
	_guardAllocPossibleReturn(num, size, NULL);

	/// Allocate the memory
	void *memory = malloc(num * size);

	/// Check for failure
	_guardAgainstNullReturn(memory, NULL);
	return memory;
}

inline void *CBHMemory_calloc(const size_t num, const size_t size)
{
	/// Guard against empy allocation
	_guardAllocPossibleReturn(num, size, NULL);

	/// Allocate the memory
	void *memory = calloc(num, size);

	/// Check for failure
	_guardAgainstNullReturn(memory, NULL);
	return memory;
}


#pragma mark - Reallocation

inline void *CBHMemory_realloc(void *ptr, const size_t num, const size_t size)
{
	/// Guard against null pointer, empty size, and overflow
	_guardAgainstNullReturn(ptr, NULL);
	_guardAllocPossibleReturn(num, size, NULL);

	/// Re-Allocate the memory
	void *memory = realloc(ptr, num * size);
	return memory;
}

inline void *CBHMemory_recalloc(void *ptr, const size_t oldNum, const size_t newNum, const size_t size)
{
	/// Guard against null pointer
	_guardAgainstNullReturn(ptr, NULL);

	/// Re-Allocate the memory
	void *newptr = CBHMemory_realloc(ptr, newNum, size);

	/// Check for failure
	_guardAgainstNullReturn(newptr, NULL);

	/// Zero the new memory
	if ( oldNum >= newNum ) return newptr;
	bzero((void *)((uintptr_t)newptr + (oldNum * size)), (newNum - oldNum) * size);
	return newptr;
}


#pragma mark - Copying

inline void *CBHMemory_copy(const void *orig, const size_t num, const size_t size)
{
	/// Guard against null source, empty size, and overflow
	_guardAgainstNullReturn(orig, NULL);
	_guardAllocPossibleReturn(num, size, NULL);

	/// Allocate the copy
	void *copy = CBHMemory_calloc(num, size);
	_guardAgainstNullReturn(copy, NULL);

	/// Perform the copy
	memmove(copy, orig, num * size);
	return copy;
}

inline void *CBHMemory_copyTo(const void *orig, void *dest, const size_t num, const size_t size)
{
	/// Guard against null source/destination, empty size, and overflow
	_guardAgainstNullReturn(orig, NULL);
	_guardAgainstNullReturn(dest, NULL);
	_guardAllocPossibleReturn(num, size, NULL);

	/// Perform the copy
	memmove(dest, orig, num * size);
	return dest;
}


#pragma mark - Swapping

inline void CBHMemory_swapBytes(void *a, void *b, const size_t num, const size_t size)
{
	/// Guard against null pointers, empty size, and overflow
	_guardAgainstNull(a);
	_guardAgainstNull(b);
	_guardAllocPossible(num, size);

	size_t count = num * size;
	uint8_t tmp;

	uint8_t *pa = a;
	uint8_t *pb = b;

	/// Perform swap byte by byte
	while (count > 0)
	{
		tmp = *pb;
		*pb++ = *pa;
		*pa++ = tmp;

		--count;
	}
}


#pragma mark - Zeroing

inline void CBHMemory_zero(void *ptr, const size_t num, const size_t size)
{
	/// Guard against null pointer, empty size, and overflow
	_guardAgainstNull(ptr);
	_guardAllocPossible(num, size);

	/// Perform the zero
	bzero(ptr, num * size);

	/// Check for failure
	_guardAgainstNull(ptr);
}


#pragma mark - Compare

inline bool CBHMemory_compare(const void *ptr0, const void *ptr1, const size_t num, const size_t size)
{
	/// Guard against null pointers, empty size, and overflow
	_guardAgainstNullReturn(ptr0, false);
	_guardAgainstNullReturn(ptr1, false);
	_guardAllocPossibleReturn(num, size, false);

	/// Perform the compare
	return memcmp(ptr0, ptr1, num * size) == 0;
}


#pragma mark - Free

inline void CBHMemory_free_f(void **mem)
{
	/// Guard against freeing NULL
	_guardAgainstNull(mem);
	_guardAgainstNull(*mem);

	/// Free and NULL;
	free(*mem);
	*mem = NULL;
}


#pragma mark - Overflowing

inline bool CBHMemory_willOverflowSize(const size_t num, const size_t size, const size_t max)
{
	/// Catch potential divide by zero and empty size.
	if ( num <= 0 || size <= 0 ) return false;

	/// Check overflow.
	return ((max / num) < size);
}
