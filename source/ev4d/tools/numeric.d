
module ev4d.tools.numeric;

union f2ui
{
	float f;
	uint ui;
}

/**
	Clears (-) sign on float passed as unsiged. (Clears first bit.)
	And encodes float value as uint to be comporable with integer arithmetic.
	Because we want to keep ordering, so that negative values will be are < than positive
	we need to flip bits.

	1. Always flip the sign bit.
	2. If the sign bit was set, flip the other bits too.

	http://stereopsis.com/radix.html
	(http://aras-p.info/blog/2014/01/16/rough-sorting-by-depth/)

	Params:
		f = float to flip to be comparable as int
	Returns: flipped bits to be comparable
*/
uint floatFlip(uint f)
{
  uint mask = -cast(int)(f >> 31) | 0x80000000;
  return f ^ mask;
}

unittest
{
	assert (floatFlip(0) == 2147483648);
	assert (floatFlip(-1) == 0);
	assert (floatFlip(1) == 2147483649);
	assert (floatFlip(-5) == 4);
	assert (floatFlip(5) == 2147483653);

	f2ui uni;
	uni.f = 0.0f;
	assert (floatFlip(uni.ui) == 2147483648);
	uni.f = -1.0f;
	assert (floatFlip(uni.ui) == 1082130431);
	uni.f = 1.0f;
	assert (floatFlip(uni.ui) == 3212836864);
	uni.f = -5.0f;
	assert (floatFlip(uni.ui) == 1063256063);
	uni.f = 5.0f;
	assert (floatFlip(uni.ui) == 3231711232);
}

/**
	Inverse float flip, obtain original back from float.

	Params:
		f = float to inverse flip
*/
uint inverseFloatFlip(uint f)
{
	uint mask = ((f >> 31) - 1) | 0x80000000;
	return f ^ mask;
}

unittest
{
	f2ui ff;
	ff.ui = inverseFloatFlip(2147483648);
	assert (ff.f == 0.0f);
	ff.ui = inverseFloatFlip(1082130431);
	assert (ff.f == -1.0f);
	ff.ui = inverseFloatFlip(3212836864);
	assert (ff.f == 1.0f);
	ff.ui = inverseFloatFlip(1063256063);			  
	assert (ff.f == -5.0f);
	ff.ui = inverseFloatFlip(3231711232);
	assert (ff.f == 5.0f);
}

/**
	Tranform float to takeBits number of bits for sorting as int.
	Signed version!

	Params: 
		ff = signed float

	http://aras-p.info/blog/2014/01/16/rough-sorting-by-depth
*/
uint floatToBits (int takeBits)(float ff)
{
	f2ui fui;
	fui.f = ff;
	fui.ui = floatFlip(fui.ui); // flip bits to be sortable
	uint b = fui.ui >> (32 - takeBits); // take highest takeBits bits

	return b;
}

/**
	Tranform float to takeBits number of bits for sorting as int.
	
	Params: 
		ff = should be guaranteed to be positive

	http://aras-p.info/blog/2014/01/16/rough-sorting-by-depth
*/
uint floatToBitsPositive (int takeBits)(float ff)
{
	f2ui fui;
	fui.f = ff;

	uint b = fui.ui >> (32 - takeBits); // take highest takeBits bits

	return b;
}
