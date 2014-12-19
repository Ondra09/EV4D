#/bin/bash
find . -name *.d | xargs wc -l | grep total
