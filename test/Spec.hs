module Main where

import Test.Hspec
import Test.QuickCheck
import Test.QuickCheck.Checkers
import Test.QuickCheck.Classes
import Data.Monoid
import GameMechanics
import HillClimbingSolverGame
import Data.List (nub)

instance Arbitrary AnswerResult where
  arbitrary = do
    a <- arbitrary
    b <- arbitrary
    return $ AnswerResult a b

instance EqProp AnswerResult where (=-=) = eq

genGuess :: Gen String
genGuess = arbitrary `suchThat` (\x -> length x == 4)

genTuple :: Gen (String, String)
genTuple = do
  a <- arbitrary `suchThat` (\x -> length x == 4)
  b <- arbitrary `suchThat` (\x -> length x == 4)
  return (a, b)

genUnique :: Gen String
genUnique = arbitrary `suchThat` (\x -> (length x == 4) && nub x == x)

prop_guessesCorrectly :: Property
prop_guessesCorrectly =
  forAll genGuess
  (\x -> checkGuess x x === AnswerResult 4 0)

prop_guessesIncorrectPos :: Property
prop_guessesIncorrectPos =
  forAll genUnique
  (\x -> checkGuess x (reverse x) === AnswerResult 0 4)

prop_scoreSumsCorrectly :: Property
prop_scoreSumsCorrectly =
  forAll genTuple
  (\(answer, guess) -> (blackPegs (checkGuess answer guess)) + (whitePegs (checkGuess answer guess)) <= 4)

prop_scoreSumsCorrectly' :: Property
prop_scoreSumsCorrectly' =
  forAll genGuess
  (\x -> (blackPegs (checkGuess x (reverse x))) + (whitePegs (checkGuess x (reverse x))) === 4)

main :: IO ()
main = do
  quickBatch (monoid AnswerResult)
  quickCheck prop_guessesCorrectly
  quickCheck prop_guessesIncorrectPos
  quickCheck prop_scoreSumsCorrectly
  quickCheck prop_scoreSumsCorrectly'

