# Internet Time

**[Go to this package](https://github.com/dzuk-mutant/internet-time-elm) for a much better version of this module that's compatible with more recent Elm versions.**

The Elm module nobody asked for. Convert `Time` into Internet Time, both as Internet Time units (like beat and centibeat) and as properly-formatted strings for display.

It's pretty small, there's just one file and the documentation is all there.

```

inBeats 1525244393059 -- 17653291.586331 (beats)

convertBeats 1525244393059 -- 333

displayBeats 1525251972000 -- "420"

convert 0 1525221281000 -- 65 (beats)

display 2 1525294572000 -- "914.37"

```
