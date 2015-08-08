/**
 Authors: Eastern Wolf
 */

module ev4ds.shipcontroller;

import std.algorithm;

class FighterShipController(T)
{
private:
	T[] fighters;
	immutable int speed = 10;
	immutable int turRadius = 10;

public:

	void addFighter(T fighter)
	{
		fighters ~= fighter;
	}

	void removeFighter(const T fighter)
	{
		auto slice = remove!(a => a == obj)(fighters);

		fighters.length = slice.length;
	}

	void update()
	{
		foreach(fighter; fighters)
		{
			// update fighter position
			
		}
	}
}


