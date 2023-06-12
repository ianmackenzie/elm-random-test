module Test.Random exposing
    ( check, check2, check3, check4, check5, check6, check7, check8
    , checkExpectation
    )

{-| The `Test.checkN` functions work much like the `Test.fuzzN` functions from `elm-test`, except
you pass `Generator` values instead of `Fuzzer` values and the description is passed first (I
personally think it reads better that way).

Internally, the given generators will be:

  - Combined into a single random generator
  - Converted into a `Fuzzer` using [`Fuzz.fromGenerator`](https://package.elm-lang.org/packages/elm-explorations/test/latest/Fuzz#fromGenerator)
  - Tested using [`Test.fuzz`](http://localhost:8000/packages/elm-explorations/test/latest/Test#fuzz)

@docs check, check2, check3, check4, check5, check6, check7, check8


# Advanced

@docs checkExpectation

-}

import Expect exposing (Expectation)
import Fuzz
import Random exposing (Generator)
import Test exposing (Test)


{-| If you need to write tests with more than 8 inputs or otherwise need more flexibility, you can
use this function. Instead of passing value generators and an expectation function separately, you
use whatever functionality you want to build up a `Generator Expectation` and then test _that_.

For example,

    Test.Random.check2 "My test"
        firstGenerator
        secondGenerator
        Expect.equal

could be written as

    Test.Random.checkExpectation "My test" <|
        Random.map2 Expect.equal
            firstGenerator
            secondGenerator

where existing `Random` functionality (in this case `Random.map2`) is used to convert a couple of
value generators into an `Expectation` generator.

-}
checkExpectation : String -> Generator Expectation -> Test
checkExpectation description generator =
    Test.fuzz (Fuzz.fromGenerator generator) description identity


{-| -}
check : String -> Generator a -> (a -> Expectation) -> Test
check description generator expectation =
    checkExpectation description (Random.map expectation generator)


{-| -}
check2 : String -> Generator a -> Generator b -> (a -> b -> Expectation) -> Test
check2 description firstGenerator secondGenerator expectation =
    checkExpectation description <|
        Random.map2 expectation
            firstGenerator
            secondGenerator


{-| -}
check3 : String -> Generator a -> Generator b -> Generator c -> (a -> b -> c -> Expectation) -> Test
check3 description firstGenerator secondGenerator thirdGenerator expectation =
    checkExpectation description <|
        Random.map3 expectation
            firstGenerator
            secondGenerator
            thirdGenerator


{-| -}
check4 :
    String
    -> Generator a
    -> Generator b
    -> Generator c
    -> Generator d
    -> (a -> b -> c -> d -> Expectation)
    -> Test
check4 description firstGenerator secondGenerator thirdGenerator fourthGenerator expectation =
    checkExpectation description <|
        Random.map4 expectation
            firstGenerator
            secondGenerator
            thirdGenerator
            fourthGenerator


{-| -}
check5 :
    String
    -> Generator a
    -> Generator b
    -> Generator c
    -> Generator d
    -> Generator e
    -> (a -> b -> c -> d -> e -> Expectation)
    -> Test
check5 description firstGenerator secondGenerator thirdGenerator fourthGenerator fifthGenerator expectation =
    checkExpectation description <|
        Random.map5 expectation
            firstGenerator
            secondGenerator
            thirdGenerator
            fourthGenerator
            fifthGenerator


andMap : Generator a -> Generator (a -> b) -> Generator b
andMap valueGenerator functionGenerator =
    Random.map2 (|>) valueGenerator functionGenerator


{-| -}
check6 :
    String
    -> Generator a
    -> Generator b
    -> Generator c
    -> Generator d
    -> Generator e
    -> Generator f
    -> (a -> b -> c -> d -> e -> f -> Expectation)
    -> Test
check6 description firstGenerator secondGenerator thirdGenerator fourthGenerator fifthGenerator sixthGenerator expectation =
    checkExpectation description
        (Random.constant expectation
            |> andMap firstGenerator
            |> andMap secondGenerator
            |> andMap thirdGenerator
            |> andMap fourthGenerator
            |> andMap fifthGenerator
            |> andMap sixthGenerator
        )


{-| -}
check7 :
    String
    -> Generator a
    -> Generator b
    -> Generator c
    -> Generator d
    -> Generator e
    -> Generator f
    -> Generator g
    -> (a -> b -> c -> d -> e -> f -> g -> Expectation)
    -> Test
check7 description firstGenerator secondGenerator thirdGenerator fourthGenerator fifthGenerator sixthGenerator seventhGenerator expectation =
    checkExpectation description
        (Random.constant expectation
            |> andMap firstGenerator
            |> andMap secondGenerator
            |> andMap thirdGenerator
            |> andMap fourthGenerator
            |> andMap fifthGenerator
            |> andMap sixthGenerator
            |> andMap seventhGenerator
        )


{-| -}
check8 :
    String
    -> Generator a
    -> Generator b
    -> Generator c
    -> Generator d
    -> Generator e
    -> Generator f
    -> Generator g
    -> Generator h
    -> (a -> b -> c -> d -> e -> f -> g -> h -> Expectation)
    -> Test
check8 description firstGenerator secondGenerator thirdGenerator fourthGenerator fifthGenerator sixthGenerator seventhGenerator eigthGenerator expectation =
    checkExpectation description
        (Random.constant expectation
            |> andMap firstGenerator
            |> andMap secondGenerator
            |> andMap thirdGenerator
            |> andMap fourthGenerator
            |> andMap fifthGenerator
            |> andMap sixthGenerator
            |> andMap seventhGenerator
            |> andMap eigthGenerator
        )
