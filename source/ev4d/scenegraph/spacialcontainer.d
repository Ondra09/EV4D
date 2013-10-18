
module ev4d.scenegraph.spacialcontainer;

struct ConditionalRange(alias fun, R)
if(isForwardRange!R)
{
    StateType[stateSize] _state;
    size_t _n;

    this(R* range) @safe pure nothrow // @safe pure nothrow should be default to most functions
    {
        _range = range;
    }

    void popFront()
    {
    }

    @property StateType front()
    {
    }

    @property typeof(this) save()
    {
        return this;
    }

    enum bool empty = false;
}

/// Ditto
ConditionalRange!(fun, R, State.length)
conditionalRange(alias fun, State...)(State initial)

{
    CommonType!(State)[State.length] state;
    foreach (i, Unused; State)
    {
        state[i] = initial[i];
    }
	// this retype state to type of return... :)
    return typeof(return)(state);
}

