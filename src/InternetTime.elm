module InternetTime exposing ( beat
                             , centibeat
                             , inBeats
                             , inCentibeats
                             , convertBeats
                             , convertCentibeats
                             , displayBeats
                             , displayCentibeats
                             , convert
                             , display
                             )

{-| A library that lets you use Internet Time units and convert `Time` into Internet Time, both as
  Internet Time units (eg. beats, centibeats) or as properly formatted strings for display.

# Units of time
@docs beat, centibeat

# Conversions for lengths of time
@docs inBeats, inCentibeats

# Conversions and display for daily time
@docs convertBeats, convertCentibeats, displayBeats, displayCentibeats

# Custom conversions and display for daily time
@docs convert, display

-}


import Time exposing (Time)
import String exposing (dropRight, padLeft, right)





-- handy measurements

{-| One Internet Time beat as a Time value (86.4 seconds). This is the largest possible measurement of time in Internet Time.

    beat == 86400

```

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every beat Tick

```

-}
beat : Time
beat =
  86400

{-| One Internet Time centibeat as a Time value (864 milliseconds).

    centibeat == 864

-}
centibeat : Time
centibeat =
  864







-- conversions for Unix Epoch Time
-- does not account for time zones

{-| Convert a `Time` to Internet Time beats (1/1,000th of a day).

It treats the time as a length rather than a fixed point in time (and thus, it does not attempt to change timezone).

    inBeats 1525244393059 -- 17653291.586331 (beats)
-}
inBeats : Time -> Float
inBeats t =
  t / beat

{-| Convert a `Time` to Internet Time centibeats (1/100,000th of a day).

It treats the time as a length rather than a fixed point in time (and thus, it does not attempt to change timezone).

    inCentiBeats 1525244393059 -- 1765329158.6331 (centibeats)
-}
inCentibeats : Time -> Float
inCentibeats t =
  t / centibeat







-- quick conversions for a single day


{-| Convert a `Time` to Internet Time beats for that particular day as an `Int`.

This calculation also converts the time to Internet Time's timezone (UTC+01:00).

    convertBeats 1525244393059 -- 333
    convertBeats 1525221281000 -- 65
-}

convertBeats : Time -> Int
convertBeats = convert 0


{-| Convert a `Time` to Internet Time centibeats for that particular day as an `Int`.

This calculation also converts the time to Internet Time's timezone (UTC+01:00).

    convertCentibeats 1525244393059 -- 33325
    convertCentibeats 1525221281000 -- 6575
-}

convertCentibeats : Time -> Int
convertCentibeats = convert 2


{-| Convert a `Time` to Internet Time beats for that particular day. The output is a `String` that's prepared for display (with padded 0s).

This calculation also converts the time to Internet Time's timezone (UTC+01:00).

    displayBeats 1525244393059 -- "333"
    displayBeats 1525221281000 -- "065"
-}

displayBeats : Time -> String
displayBeats = display 0


{-| Convert a `Time` to Internet Time centibeats for that particular day. The output is a `String` that's prepared for display (with padded 0s).

This calculation also converts the time to Internet Time's timezone (UTC+01:00).

    displayCentibeats 1525244393059 -- "333.25"
    displayCentibeats 1525221281000 -- "065.75"
-}


displayCentibeats : Time -> String
displayCentibeats = display 2



{-| Convert a `Time` to the Internet Time for that particular day in the form of an `Int`.

This calculation also converts the time to Internet Time's timezone (UTC+01:00).

The first argument is for how much detail (extra digits) you want - beats are the largest form of measurement possible.


```
    convert 0 1525244393059 -- 333 (beats)
    convert 2 1525244393059 -- 33325 (centibeats)

    convert 0 1525221281000 -- 65 (beats)
    convert 2 1525221281000 -- 6575 (centibeats)
```

This returns an `Int` no matter how much detail because it's more accurate to use `Int` than `Float` for this type of context.
(Floating point accuracy can waver and create artefacts when displaying or computing.)
-}

convert : Int -> Time -> Int
convert detail time =
  let
    thousands = 10^(detail)
  in
    time
    |> (+) 3600000 -- add an hour to get the right timezone (UTC+01:00)
    |> inBeats -- convert to beats
    |> (*) (toFloat thousands) -- shift the decimal place depending on how much detail
    |> floor -- round down
    |> flip (%) (1000 * thousands) -- remove the digits at that represent more than a day's worth of beats



{-| Convert a `Time` to a Internet Time for that particular day in the form of a display-ready `String`.

This calculation also converts the time to Internet Time's timezone (UTC+01:00).

The first argument is for how much detail (extra digits) you want - beats are the largest form of measurement possible.

```
    display 0 1525244393059 -- "333"
    display 2 1525244393059 -- "333.25"

    display 0 1525294572000 -- "914"
    display 2 1525294572000 -- "914.37"
```

This time is padded with zeroes so you get the proper 3-number display for beats.

```
    display 0 1525221281000 -- "065"
    display 2 1525221281000 -- "065.75"
```
-}

display : Int -> Time -> String
display detail time =
  let
    displayTime =
      time
      |> convert detail
      |> toString
      |> padLeft (3 + detail) '0' -- pad with 0s

  in
    if detail <= 0 then displayTime -- if there's no extra detail, don't add a period.

    else
      dropRight detail displayTime ++ "." ++ right detail displayTime
