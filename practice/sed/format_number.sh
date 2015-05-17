#!/usr/bin/env sh

print robin has 123456789 pounds | perl -p -e 's/(?<=\b?\d)(?=(?:\d{3})+\b)/,/g'

# Alternative if \b is not available:
print robin has 123456789 pounds | perl -p -e 's/(?<=(?<!\w)?\d)(?=(?:\d{3})+(?!\w))/,/g'
