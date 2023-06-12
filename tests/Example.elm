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
