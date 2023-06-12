# elm-random-test

**In most cases you won't need or want this package!** The vast majority of the time, the best
approach is to just use [`elm-test`](https://package.elm-lang.org/packages/elm-explorations/test/latest/)
and its `Fuzz` module directly.

That said, for [`elm-geometry`](https://package.elm-lang.org/packages/ianmackenzie/elm-geometry/latest/)
I've found that pure fuzz testing is not always the ideal approach:

- The fuzzing process is in a sense _too_ good, in that it generates things like nearly-parallel
  axes for an axis intersection test; this is then a poorly conditioned numerical problem and
  leads to large roundoff errors (and a failed test). Fuzz testing is designed explicitly to try to
  catch corner cases, but in these kinds of numerical cases there's really no way to find an
  accurate solution so we shouldn't expect the code to.
- Shrinking doesn't make a lot of sense when dealing with geometry, and can lead to misleading
  example failures; for example you might notice that a test seemed to always fail for points with
  very small X/Y/Z coordinates, but actually that's just because the shrinker is always shrinking to
  smaller `Float` values.

Both issues are solved by just using [random generators](https://package.elm-lang.org/packages/elm/random/latest/)
without any explicit targeting of corner cases or shrinking. For the kinds of tests I tend to write,
this still catches most of the bugs I'm interested in catching. For example, it's easy to write code
that works for triangles with vertices in counterclockwise order but not clockwise; writing a few
manual tests might not catch that but testing on triangles with randomly-generated vertices almost
certainly will.

`elm-test` _does_ have [`Fuzz.fromGenerator`](https://package.elm-lang.org/packages/elm-explorations/test/latest/Fuzz#fromGenerator),
but even this has what seems to me to be some unexpected and potentially misleading behavior.
`Fuzz.fromGenerator` shrinks towards _smaller random seeds_, which can lead to some weird apparent
coupling between what look like they should be independent random generators. For example, if I run
the test

```elm
floatsAreInOrder : Test
floatsAreInOrder =
    Test.fuzz2
        (Fuzz.fromGenerator (Random.float 0 10))
        (Fuzz.fromGenerator (Random.float 0 10))
        "Silly test"
        (\x y -> x |> Expect.lessThan y)
```

then I get the failure

```
0.8904744718288526
╷
│ Expect.lessThan
╵
0.8904744718288526
```

because `elm-test` has 'shrunk' the two `Random.float` generators to use the same seed, meaning they
produce the same value! (It's true that passing two equal `Float` values will fail the test, but the
test will actually fail on _half_ of all possible input combinations so highlighting the one
special case of equality seems a bit confusing/misleading.)

In contrast, if instead of using `Test.fuzz2` on two separate random generators I use `Test.fuzz` on
a single _composite_ random generator like so:

```elm
floatsAreInOrder : Test
floatsAreInOrder =
    Test.fuzz
        (Fuzz.fromGenerator
            (Random.pair 
                (Random.float 0 10)
                (Random.float 0 10)
            )
        )
        "Silly test"
        (\( x, y ) -> x |> Expect.lessThan y)

```

(which seems like it should be pretty much equivalent), I get a more purely random failing test
case:

```    
5.944127085163927
╷
│ Expect.lessThan
╵
3.5176761788934465
```

It's definitely worth pointing out that using actual fuzzers (`Fuzz.floatRange`) results in the 
failing test case "0 is not less than 0", which is indeed about the simplest possible counterexample
(although I still think it's a bit misleading to highlight a case with equal inputs).

## Using this package

If after reading the above, "pure random" testing seems like a good fit for your use case, this
package basically provides a light wrapper around `elm-test` to do fuzz testing using the pattern
from the second example above (still calling `Test.fuzz` internally, but only ever passing a single
composite `Generator` to `Fuzz.fromGenerator` instead of converting multiple independent
`Generator` values into separate `Fuzzer` values).

Here's a simple example of using the package:

```elm
module Example exposing (test)

import Expect
import Random
import Test exposing (Test)
import Test.Random as Test


test : Test
test =
    Test.check "Reversing a list twice gives the original list"
        (Random.list 10 (Random.int 0 100))
        (\list ->
            list
                |> List.reverse
                |> List.reverse
                |> Expect.equal list
        )
```
