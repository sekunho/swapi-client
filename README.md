<p align="center">
  <img src="swapi-haskell.svg" />
</p>

# SWAPI Client

[![License: MIT](https://img.shields.io/badge/license-BSD--3--Clause-yellow)](https://opensource.org/licenses/BSD-3-Clause)

`swapi-client` is a client library (without much bells and whistles) to interact
with SWAPI ([Star Wars API](https://swapi.dev)).

``` haskell
import qualified SwapiClient.Api as Api (getFilm)
import SwapiClient.Id (FilmId (FilmId))

main :: IO ()
main = do
  film <- Api.getFilm (FilmId 1)

  print film
```

## Motivation

Hello! This is the first personal project I'm working on to study Haskell, free
from following a book or tutorial as the main reference because it feels like
I've been stuck in tutorial hell without any way out.  I wanted to start with
something relatively simple so I can study things from the ground up with practical
experience. I'm also noting down some of the things I learned or realized in the
README; something I realized I should be doing more often thanks to Fly.io.

I don't recommend using this as THE tutorial for this sort of thing because I'm
just trying to piece things together like a caveman moments before fire was
discovered.

Making this involves some of the commonly used Haskell libraries like `aeson`,
`containers`, an HTTP client library I have not yet decided on, etc. and other
basic Haskell concepts to be aware of – which makes it a good candidate for a
starter project! Of course it doesn't require a deep dive in the aforementioned
libraries; it's just enough to make things work.

## Will this be a video

Yeah! So far I've recorded most of each and every session that I worked on this.
I'm still assessing if this should be a per episode video or just put the entire
journey in one video. I don't have an editor so I usually do all the editing
myself (which takes a lot of time). There's a lot of raw footage I'm gonna have
to go through unfortunately.

Whenever it's ready, it'll  be up on
[youtube.com/sekunho](https://www.youtube.com/sekunho/)
when I'm done. Subscribe to stay tuned! :)

## Table of Contents

- [Features](#features)
  - [Queryable resources](#queryable-resources)
  - [Parseable resources](#parseable-resources)
- [Annoyances of swapi](#annoyances-of-swapi)
- [Notes](#notes)
  - [Day 18 - 20/01/2022](#day-18---20012022)
  - [Day 17 - 19/01/2022](#day-17---19012022)
  - [Day 16 - 18/01/2022](#day-16---18012022)
  - [Day 15 - 16/01/2022](#day-15---16012022)
  - [Day 14 - 14/01/2022](#day-14---14012022)
  - [Day 13 - 15/12/2021](#day-13---15122021)
  - [Day 12 - 14/12/2021](#day-12---14122021)
  - [Day 11 - 11/12/2021](#day-11---11122021)
  - [Day 10 - 08/12/2021](#day-10---08122021)
  - [Day 9 - 06/12/2021](#day-9---06122021)
  - [Day 8 - 03/12/2021](#day-8---03122021)
  - [Day 7 - 01/12/2021](#day-7---01122021)
  - [Day 6 - 30/11/2021](#day-6---30112021)
  - [Day 5 - 29/11/2021](#day-5---29112021)
  - [Day 4 - 28/11/2021](#day-4---28112021)
  - [Day 3 - 27/11/2021](#day-3---27112021)
  - [Day 2 - 26/11/2021](#day-2---26112021)
  - [Day 1 - 25/11/2021](#day-1---25112021)

## Features

### Queryable resources

- [ ] Root
- [x] People
- [x] Film
- [ ] Starship
- [ ] Vehicle
- [ ] Species
- [ ] Planet

### Parseable resources

Resources/schemas that can be encoded/decoded to and from JSON respectively.

- [x] Root
- [x] People
  - [x] Index
  - [x] View
- [x] Film
  - [x] Index
  - [x] View
- [ ] Starship
  - [ ] Index
  - [ ] View
- [ ] Vehicle
  - [ ] Index
  - [ ] View
- [ ] Species
  - [ ] Index
  - [ ] View
- [ ] Planet
  - [ ] Index
  - [ ] View

## Annoyances of swapi

swapi.dev is awesome, especially since it's free, but there are some things I wish
to improve when I get the time to do so:

- A collection of things is sometimes encoded as a comma delimited string instead
of using an array

- Numbers are encoded as strings just because the field could be an actual string
like `"n/a"`, or `"none"`

- Inconsistent usage of units. e.g In `Starship`, it has a field called 
`max_atmosphering_speed` with the kilometer unit, and without. Both of which are
numbers, just encoded as strings. What's the unitless number supposed to be?

- `api/<resource>/schema/` does not work

- `Starship`: `crew` has a range value for one, and just a number for the others

- `Starship`: `length`'s number formatting is inconsistent

- `Starship`: `starship_class` character case is inconsistent

## Notes

Dates are formatted in DD-MM-YYYY.

### Day 18 - 20/01/2022

I pretty much repeated what I did yesterday. I'm thinking of refactoring some
things but I don't know how to improve it yet. I find some of the code I wrote
was a bit too verbose, and I think there's a better way around it.

I also haven't considered the wookie option. I'm not sure how to go about that
either.

### Day 17 - 19/01/2022

Worked on implementing the encoding `Film` and its test. Nothing really
noteworthy since it's just a repetition of previous days with a different coat
of paint.

#### Extracting the index out of resources

The index of each resource aren't unique from each other; its structure is
essentially the same! So I created a more generic type:

``` haskell
data Index a = Index
  { iCount :: Int
  , iNextPage :: Page
  , iPreviousPage :: Page
  , iResults :: [a]
  }
```

Now the `Index Person`, for example, will have these instances for `aeson`:

``` haskell
{-# language FlexibleInstances #-}

instance FromJSON (Index Person :: Type) where
  parseJSON :: Value -> Parser (Index Person)
  parseJSON =
    Aeson.withObject "Index" $
      \indexObject ->
        Index
          <$> indexObject .: "count"
          <*> indexObject .: "next"
          <*> indexObject .: "previous"
          <*> indexObject .: "results"

instance ToJSON (Index Person :: Type) where
  toJSON :: Index Person -> Value
  toJSON indexObject =
    Aeson.object
      [ "count"     .= iCount indexObject
      , "next"      .= iNextPage indexObject
      , "previous"  .= iPreviousPage indexObject
      , "results"   .= iResults indexObject
      ]
```

But there's one teeny tiny issue: it's annoying to repeat throughout the different
resources that has an `Index`, despite there being nothing specific to `Person`!
I still haven't found a way to generalize this further so I can have an easier
time, but so far I got nothing. `DerivingVia`? I don't know.

#### Communicating with swapi.dev

I figured I'd use `req` over `wreq` since I had enough on my new-thing-to-learn
plate. Although it seemed a bit abstract, with the help of `req`'s documentation
and test files, I was able to make a simple HTTP get request.

Building the URL was straightforward enough, fortunately.  I just slapped this
into `SwapiClient.Url`, and voila.

``` haskell
import Network.HTTP.Req ((/:), Url, Scheme (Https))
import Network.HTTP.Req qualified as Req (https)

swapiDomain :: Text
swapiDomain = "swapi.dev"

swapiBin :: Url 'Https
swapiBin = Req.https swapiDomain /: "api"
```

I should probably cleanup this module, especially with the domain stuff, in the
future. Writing that good ol' reliable TODO comment.

Some somewhat related comments on how I import stuff. Yeah, I usually use
qualified imports for functions, and regular imports for operators + types/data
constructors. I also prefer explicit imports/exports so that I can easily tell
what comes from where. It helps while I don't know the other libraries that well,
and I can read without reaching for Hoogle.

I used this style, from [Koz Ross](https://twitter.com/KozRoss), during my internship
in MLabs (great people), and it stuck with me ever since. There's a
detailed styleguide that they wrote over
[here](https://github.com/mlabs-haskell/styleguide), just in case anyone is
interested.

The hard part was cobbling `runReq` along with the request computation I was
trying to build. I was confused on how I was supposed to parse the response, you
know, from `BsResponse` to something usable like `ByteString`. But it turned out
all I lacked was `responseBody`. Cool.

From there it was just a matter of using `aeson`, and my manually derived
instances, that I worked hard on :), to decode it to the domain type I was
expecting, `Index Person`! And since it isn't a guarantee for the parsing to
succeed, the type signature looks like this `listPeople :: IO (Maybe (Index Person))`.

Here's the function looks like:

``` haskell
listPeople :: IO (Maybe (Index Person))
listPeople =
   Req.runReq Req.defaultHttpConfig $
    Req.req GET (Url.swapiBin /: "people") NoReqBody Req.bsResponse mempty
      <&> Req.responseBody
      <&> Aeson.decodeStrict
```

I initially wanted to use `>>=` but HLS kept informing me, and was very insistent,
to use `<&>` instead. Well, while it does look like it composes better, I'm not
sure what the caveats on how the computations are evaluated/executed, and all that
stuff. It looks nice, so I guess I'll leave it like this for now.

One step closer to having an actual proper, and working library! Gonna call it
a day for now.

#### `GeneralizedNewtypeDeriving`

More language pragmas, hooray.

So I was working on `getPerson`, which, well, provided with a person ID, it'll
give you back the character information of that associated ID. I used a `newtype`
to wrap the ID so it'll be harder to mix it with other IDs like `FilmId` and
whatnot, but there is the burden of having to manually unwrap it every time I
actually need the value wrapped in it.

In this case, I had to get the ID and convert it to `Text`. There's `TextShow`
that takes care of `Int -> Text`, but what if I had a `newtype` wrapping it?
I _could_ unwrap it manually, but that's tedious (and annoying). There is this
something called `GeneralizedNewtypeDeriving` which lets you ignore the `newtype`
, and discard it, so it gets treated as an unwrapped...thing. Ok, I'm bad at
explaining, so here's an example:

`TextShow` already has an instance for `Int`. So I could just convert an `Int`
to `Text` right away without manually writing an instance for it. But if I try
to wrap a `newtype` around it, I can't do it!

``` haskell
import TextShow (TextShow)

-- This won't do
newtype SomeId = SomeId Int
  deriving (Eq, Show, TextShow)
```

Compiling this'll cause GHC to point out that the `TextShow` typeclass isn't a
stock derivable thing. A stock derivable typeclass include `Eq`, `Num`, `Bounded`,
and some that I probably missed. The basic ones, basically. Although it does
point out that I could add `GeneralizedNewtypeDeriving`:

```sh
src/SwapiClient/Id.hs:67:23-30: error:
    • Can't make a derived instance of ‘TextShow PersonId’:
        ‘TextShow’ is not a stock derivable class (Eq, Show, etc.)
        Try GeneralizedNewtypeDeriving for GHC's newtype-deriving extension
    • In the newtype declaration for ‘PersonId’
   |
67 |   deriving (Eq, Show, TextShow)
   |                       ^^^^^^^^
cabal: Failed to build swapi-client-0.1.0.0 (which is required by
test:swapi-client-test from swapi-client-0.1.0.0).
```

``` diff
+ {-# language GeneralizedNewtypeDeriving #-}
+
import TextShow (TextShow)

newtype SomeId = SomeId Int
  deriving (Eq, Show, TextShow)
```

And it compiles!

I'm not really a fan of mixing the different kinds of derivations though. It
makes it confusing if it's just all in one `deriving`. Why are `Eq`, and `Show`,
which are stock derived classes, mixed with a `newtype` one? I guess it's not
that big of a deal though. But I just turn on `DerivingStrategies` to help me out
easily differentiate what's stock and not.

``` diff
{-# language GeneralizedNewtypeDeriving #-}

import TextShow (TextShow)

newtype SomeId = SomeId Int
-  deriving (Eq, Show, TextShow)
+  deriving stock (Eq, Show)
+  deriving newtype TextShow
```

Aaand with that I could just do this whenever I want to convert a `PersonId` to
`Text`: `Text.Show.showt (PersonId 1)` will evaluate to `"1" :: Text`. Mind blown.

### Day 16 - 18/01/2022

Woke up a bit earlier (04:00) than the usual (05:00-07:00) when the LTE is less
congested.

#### Overlapping instances

I ran into this issue before where SWAPI has this weird way of encoding a
collection of something as a string delimited by commas and a space. So if it's
a collection of film producers, it gets encoded as: `"Gary Kurtz, Rick McCallum"`
. But that's not exactly fun.

Here is a teeny tiny example:

``` haskell
{-# language InstanceSigs #-}

import Data.Aeson.Types (Value, Parser, (.:))
import Data.Aeson qualified as Aeson (withObject, withText)

newtype Producer = Producer Text
  deriving (Eq, Show)

newtype Film = Film
  { title :: Text
  , producers :: [Producer]
  } deriving (Eq, Show)

instance FromJSON Producer where
  parseJSON :: Value -> Parser Producer
  parseJSON = Aeson.withText (pure . Producer)

instance FromJSON Film where
  parseJSON :: Value -> Parser Film
  parserJSON =
    Aeson.withObject "Film" $
      \filmObj ->
        Film
          <$> filmObj .: "title"
          <*> producers .: "producers"
```

This is definitely OK if we're expecting a JSON list for the `producers` field
(`["Gary Kurtz", "Rick McCallum"]`), but `aeson` will complain if it runs into
an actual string, as expected.

So... do I just write a `FromJSON` instance for `[Producer]` as well? Ok, sure.

``` diff
{-# language InstanceSigs #-}

import Data.Aeson.Types (Value, Parser, (.:))
import Data.Aeson qualified as Aeson (withObject, withText)

newtype Producer = Producer Text
  deriving (Eq, Show)

newtype Film = Film
  { title :: Text
  , producers :: [Producer]
  } deriving (Eq, Show)

instance FromJSON Producer where
  parseJSON :: Value -> Parser Producer
  parseJSON = Aeson.withText (pure . Producer)

+ instance FromJSON [Producer] where
+   parseJSON :: Value -> Parser [Producer]
+   parseJSON =
+     Aeson.withText "[Producer]" (pure . map Producer . Text.splitOn ", ")

instance FromJSON Film where
  parseJSON :: Value -> Parser Film
  parserJSON =
    Aeson.withObject "Film" $
      \filmObj ->
        Film
          <$> filmObj .: "title"
          <*> producers .: "producers"
```

Looks good so far. So I parsed a comma delimited text into a list of texts, then
to a list of `Producer`. Time to compile...

...and I got this:

``` sh
src/SwapiClient/Film.hs:90:10: error:
    • Illegal instance declaration for ‘FromJSON [Producer]’
        (All instance types must be of the form (T a1 ... an)
         where a1 ... an are *distinct type variables*,
         and each type variable appears at most once in the instance head.
         Use FlexibleInstances if you want to disable this.)
    • In the instance declaration for ‘FromJSON ([Producer] :: Type)’
   |
90 | instance FromJSON ([Producer] :: Type) where
   |          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
cabal: Failed to build swapi-client-0.1.0.0 (which is required by
test:swapi-client-test from swapi-client-0.1.0.0).
```

By the looks of it, GHC is telling me it doesn't like how I wrote the instance
declaration, and that if I really wanted to, I could enable `FlexibleInstances`.

``` diff
{-# language InstanceSigs #-}
+ {-# language FlexibleInstances #-}

import Data.Aeson.Types (Value, Parser, (.:))
import Data.Aeson qualified as Aeson (withObject, withText)

newtype Producer = Producer Text
  deriving (Eq, Show)

newtype Film = Film
  { title :: Text
  , producers :: [Producer]
  } deriving (Eq, Show)

instance FromJSON Producer where
  parseJSON :: Value -> Parser Producer
  parseJSON = Aeson.withText (pure . Producer)

instance FromJSON [Producer] where
  parseJSON :: Value -> Parser [Producer]
  parseJSON =
    Aeson.withText "[Producer]" (pure . map Producer . Text.splitOn ", ")

instance FromJSON Film where
  parseJSON :: Value -> Parser Film
  parserJSON =
    Aeson.withObject "Film" $
      \filmObj ->
        Film
          <$> filmObj .: "title"
          <*> producers .: "producers"
```

Surely this is fine, right? No.

``` sh
src/SwapiClient/Film.hs:91:10: error:
    • Overlapping instances for FromJSON [Producer]
        arising from a use of ‘aeson-2.0.3.0:Data.Aeson.Types.FromJSON.$dmparseJSONList’
      Matching instances:
        instance FromJSON a => FromJSON [a]
          -- Defined in ‘aeson-2.0.3.0:Data.Aeson.Types.FromJSON’
        instance FromJSON [Producer]
          -- Defined at src/SwapiClient/Film.hs:91:10
    • In the expression:
        aeson-2.0.3.0:Data.Aeson.Types.FromJSON.$dmparseJSONList
          @([Producer])
      In an equation for ‘aeson-2.0.3.0:Data.Aeson.Types.FromJSON.parseJSONList’:
          aeson-2.0.3.0:Data.Aeson.Types.FromJSON.parseJSONList
            = aeson-2.0.3.0:Data.Aeson.Types.FromJSON.$dmparseJSONList
                @([Producer])
      In the instance declaration for ‘FromJSON [Producer]’
   |
91 | instance FromJSON ([Producer] :: Type) where
   |          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

src/SwapiClient/Film.hs:106:15: error:
    • Overlapping instances for FromJSON [Producer]
        arising from a use of ‘.:’
      Matching instances:
        instance FromJSON a => FromJSON [a]
          -- Defined in ‘aeson-2.0.3.0:Data.Aeson.Types.FromJSON’
        instance FromJSON [Producer]
          -- Defined at src/SwapiClient/Film.hs:91:10
    • In the second argument of ‘(<*>)’, namely ‘filmObj .: "producer"’
      In the first argument of ‘(<*>)’, namely
        ‘Film <$> filmObj .: "title" <*> filmObj .: "episode_id"
           <*> filmObj .: "opening_crawl"
           <*> filmObj .: "director"
           <*> filmObj .: "producer"’
      In the first argument of ‘(<*>)’, namely
        ‘Film <$> filmObj .: "title" <*> filmObj .: "episode_id"
           <*> filmObj .: "opening_crawl"
           <*> filmObj .: "director"
           <*> filmObj .: "producer"
           <*> filmObj .: "release_date"’
    |
106 |           <*> filmObj .: "producer"
    |               ^^^^^^^^^^^^^^^^^^^^^
cabal: Failed to build swapi-client-0.1.0.0 (which is required by
test:swapi-client-test from swapi-client-0.1.0.0).
```

The first one seems to be telling me that my instance declaration already has
an existing instance, which `aeson` implemented. Any list of `a :: Type` already
has its own instance declaration! Normally that's convenient since it's rather
tedious to repeat this. But this case is special since we do want to override how
`[Producer]` is parsed. Second one is just telling me that the usage of said
instance is invalid because it overlaps with an existing one.

I'm not entirely sure of what the differences are among the pragmas `OVERLAPS`,
`OVERLAPPING`, and `OVERLAPPABLE`. I tried `OVERLAPPABLE`, but it didn't fix it.
Not too familiar with this pragma yet unfortunately (user guide still confuses
me). But trying out `OVERLAPS` made it work!

``` diff
{-# language InstanceSigs #-}
{-# language FlexibleInstances #-}

import Data.Aeson.Types (Value, Parser, (.:))
import Data.Aeson qualified as Aeson (withObject, withText)

newtype Producer = Producer Text
  deriving (Eq, Show)

newtype Film = Film
  { title :: Text
  , producers :: [Producer]
  } deriving (Eq, Show)

instance FromJSON Producer where
  parseJSON :: Value -> Parser Producer
  parseJSON = Aeson.withText (pure . Producer)

- instance FromJSON [Producer] where
+ instance {-# OVERLAPS -#} FromJSON [Producer] where
  parseJSON :: Value -> Parser [Producer]
  parseJSON =
    Aeson.withText "[Producer]" (pure . map Producer . Text.splitOn ", ")

instance FromJSON Film where
  parseJSON :: Value -> Parser Film
  parserJSON =
    Aeson.withObject "Film" $
      \filmObj ->
        Film
          <$> filmObj .: "title"
          <*> producers .: "producers"
```

And now it works. Very cool. This tells GHC to loosen up a bit and allows me to
specify exactly which instance I want to use. The syntax is a bit strange though
cause I have to put it right after `instance`.

#### Using `OVERLAPS` instead of manually wrapping with `newtype`s

My previous (ugly) solution to this problem, since I wanted to dance around
`OVERLAPS` and not use it, was to use `newtype`s. Well, it worked! But it's
annoying because I have unnecessary `newtype` definitions as well as annoying
wrap/unwrap helper functions. So... I just got rid of it.

``` haskell
-- Oh no...
data HairColor
  = BrownHair
  | BlueHair
  -- ...

newtype HairColors = HairColors [HairColor]

instance ToJSON (HairColors :: Type) where
  toJSON :: HairColors -> Value
  toJSON = String . commaConcat . unHairColors
```

``` haskell
-- Cool!
data HairColor
  = BrownHair
  | BlueHair
  -- ...

instance {-# OVERLAPS #-} ToJSON ([HairColor] :: Type) where
  toJSON :: [HairColor] -> Value
  toJSON = String . commaConcat
```

### Day 15 - 16/01/2022

LTE was terrible yesterday. I couldn't anything done with 1Kbps. Honestly...

#### `cabal` shenanigans with `--enable-tests`

So turns out that `cabal` doesn't run resolve test dependencies, or something,
by default. Could be understanding it wrong, but that's how it is to me. So,
I had to use this flag `--enable-tests` so that it would actually run the tests.
But, HLS also needed that flag! I don't know how to pass flags to HLS, and it
seemed kinda janky if I were to manually do it all the time. So I had to look into
`cabal.project`, specifically `cabal.project.local`, and explicitly state the
package and its flags.

This is how it looks like at the moment:

``` cabal-config
package swapi-client
  tests: true
```

For some reason, this file is `.gitignore`'d by default. I've seen some repos
with this file though so I'm not sure why this is the case. I removed it, and
added it to version control for sanity.

#### More golden tests for `PersonIndex`

My internet is terrible since I'm just using LTE while waiting for both
electricity and the fiber internet to come back. Emphasis on terrible. So I
downloaded some of the JSON responses for some pages of `/people/`, decoded it
to `PersonIndex`, vomited it to a file, and compared said file to a golden file.
I did this because there are a lot of items per page and swapi.dev does not have
a limit option; I did not want to manually write everything down and maintain it
in the test files so I figured, why not just use golden tests for this? I don't
know how good of an idea my approach is, because I just used
`show :: PersonIndex -> String`. Something something don't use `show` for
serialization but it's ok for this case... I think?

More about golden tests:

I saved the JSON responses for each page in `./testdata/fixtures/person_index`,
with `n.json` (`n` being the page number). I could've manually written a test
case for each file but that's cumbersome. Fortunately, `tasty-golden` has something
for that:

```haskell
findByExtension
  :: [FilePath]     -- List of extensions. e.g [ ".json" ]
  -> FilePath       -- Directory you want to find matches for
  -> IO [FilePath]  -- Result!
```

But I also wanted to be able to name the tests that I generate based on the file
name, that way they won't be muddied together, and I can figure out which file
fails.

``` haskell
test_decodePersonIndices :: IO [TestTree]
test_decodePersonIndices =
  map mkGoldenTest <$> personIndices
  where
    personIndices :: IO [FilePath]
    personIndices =
      Tasty.Golden.findByExtension [".json"] "./testdata/fixtures/person_index"

    mkGoldenTest :: FilePath -> TestTree
    mkGoldenTest filepath =
      let baseName :: FilePath
          baseName = takeBaseName filepath
      in
        Tasty.Golden.goldenVsFile
          ("decode page " <> baseName)
          ("./testdata/person_index/" <> baseName <> ".golden")
          ("./testdata/person_index/" <> baseName <> ".data")
          (readFile filepath >>= (
            \personIndexJSON ->
              let personIndex =
                    Aeson.eitherDecodeStrict @PersonIndex personIndexJSON
              in
                writeFile
                  ("./testdata/person_index/" <> baseName <> ".data")
                  (show personIndex)) . ByteString.pack)

takeBaseName :: FilePath -> FilePath
takeBaseName =
  Text.unpack . head . Text.split (== '.') . last . Text.split (== '/') . Text.pack
```

I should probably use a strict version of `readFile`, but I haven't read up on
the problems of lazy IO yet, so I'll leave it for now.

#### Where are my test suites?

I didn't like that `cabal test` didn't show the test suites. I get a lot of
satisfaction from seeing them enumerated too. There's an alternate command I
found out only recently that shows all of it, and even detailing which
passed/failed, and it's: `<cabal project>-name:test:<test-suite>`.

Here is `cabal test`:

``` sh
[sekun@nixos:~/Projects/swapi]$ cabal test
Build profile: -w ghc-8.10.7 -O1
In order, the following will be built (use -v for more details):
 - swapi-client-0.1.0.0 (test:swapi-client-test) (ephemeral targets)
Preprocessing test suite 'swapi-client-test' for swapi-client-0.1.0.0..
Building test suite 'swapi-client-test' for swapi-client-0.1.0.0..
Running 1 test suites...
Test suite swapi-client-test: RUNNING...
Test suite swapi-client-test: PASS
Test suite logged to:
/home/sekun/Projects/swapi/dist-newstyle/build/x86_64-linux/ghc-8.10.7/swapi-client-0.1.0.0/t/swapi-client-test/test/swapi-client-0.1.0.0-swapi-client-test.log
1 of 1 test suites (1 of 1 test cases) passed.
```

Well, that's ugly.

And here's `cabal swapi-client:test/swapi-client-test`:

``` sh
[sekun@nixos:~/Projects/swapi]$ cabal run swapi-client:test:swapi-client-test
Up to date
test/Driver.hs
  RSJ1:                                                   OK
  fromJSON
    root schema fromJSON
      parses root JSON into a Root type:                  OK
  decodePersonIndices
    decode page 1:                                        OK (0.02s)
    decode page 3:                                        OK (0.02s)
    decode page 4:                                        OK
    decode page 2:                                        OK (0.02s)
  resourceUrl
    resourceUrl
      is the right URL for Root:                          OK
      is the right URL for People:                        OK
      is the right URL for People:                        OK
      is the right URL for People:                        OK
      is the right URL for People:                        OK
      is the right URL for People:                        OK
      is the right URL for People:                        OK
  getId
    getId
      gets ID from people resource URL:                   OK
      gets ID from film resource URL:                     OK
      gets ID from starships resource URL:                OK
      gets ID from vehicles resource URL:                 OK
      gets ID from species resource URL:                  OK
      gets ID from planets resource URL:                  OK
      gets ID from URL without trailing forwardslash:     OK
      gets Nothing from an invalid resource:              OK
      gets Nothing when there's no ID:                    OK
  urlToUrlData
    urlToUrlData
      parses URL with params:                             OK
      parses a URL without subdirectories or params:      OK
      parses URL without params but with subdirectories:  OK
      parses an unexpected base URL:                      OK
  urlDataToUrl
    urlDataTourl
      parses UrlData with params and subdir:              OK
      parses UrlData without params, with subdirs:        OK
      parses UrlData without params, and without subdirs: OK

All 29 tests passed (0.02s)
```

Magnificent.

### Day 14 - 14/01/2022

I'm planning on moving this into a blog but I haven't gotten around on
setting one up yet. Hopefully I'll be able to make each day more detailed rather
than just overviews of what happened. So going deeper into the code and all that
stuff. I'm not sure when that will happen, but I guess if I want to get a job,
I'll need one.

#### Golden test failing due to EOF

This one was an annoying one. I wasn't sure what I was doing wrong prior to
figuring it out, but wow, I feel extremely irate that this was simpler than
expected, and quite obvious too but I ignored my hunch.

So turns out `emacs` autoinserts line endings every time you save a file, which
is normally harmless and actually convenient. But `tasty-golden`, specifically
`Tasty.Golden.goldenVsFile` (`*VsString` as well) takes EOF seriously and treats
them as different things if you compare a file with EOF to a file without EOF.
Fair I guess, but still annoying.

Problem is, I tried making it more consistent in both files with the use of
different text editors like vim, but for some reason, they render it the same
way. I don't know what's up with this; it doesn't show a next line to move the
cursor to in the golden file, unlike emacs.

Easiest solution: Delete golden file, copy test file and rename it as golden
file. It's exactly the same in terms of contents anyway.

Edit: Maybe the term is not EOF but something else that I'm not sure of.

#### Incorrect field-value pairings when decoding root JSON

After working on the golden test, I worked on a spec test for decoding to `Root`.
Then I got some errors saying that it doesn't match, but I noticed that the
field-value pairs are incorrect! For instance, `https://swapi.dev/api/people/`
is supposed to be bounded to `rPeople`, but was instead bounded to some other
field of `Root`. Turns out I just forgot to rearrange it in the right order, since
I previously rearranged the object field order when encoding `Root`.

``` haskell
instance FromJSON (Root :: Type) where
  parseJSON :: Value -> Parser Root
  parseJSON =
    Aeson.withObject "Root" $
      \rootObj ->
        Root
          <$> rootObj .: "films"
          <*> rootObj .: "people"
          <*> rootObj .: "planets"
          <*> rootObj .: "species"
          <*> rootObj .: "starships"
          <*> rootObj .: "vehicles"

instance ToJSON (Root :: Type) where
  toJSON :: Root -> Value
  toJSON root =
    Aeson.object
      [ "films"     .= rFilms root
      , "people"    .= rPeople root
      , "planets"   .= rPlanets root
      , "species"   .= rSpecies root
      , "starships" .= rStarships root
      , "vehicles"  .= rVehicles root
      ]
```

Now I got these two simple tests for `Root`! I was able to catch a mistake that
I just introduced a commit ago thanks to one test case. Awesome.

### Day 13 - 15/12/2021

I wrote more tests for the `Url` module, and discovered some bugs in the process.
I am happy I decided to write tests because without it, I would probably be
frustrated in the future.

Turns out there was an issue in the parsing of `UrlData` to a url. Here's the
old version of `urlDataToUrl :: UrlData -> Text`:

``` haskell
urlDataToUrl :: UrlData -> Text
urlDataToUrl urlData =
  mconcat
    [ baseUrl
    , mconcat . udSubdir $ urlData
    , paramsToUrlParams . udParams $ urlData
    ]
  where
    ...
```

#### Issue #1: It didn't separate and end the subdirectories with `/`

I must've been extremely sleep deprived when I wrote this because there's no way
`mconcat . udSubdir $ urlData` would've worked that way. Anyway, because `baseUrl`
always ends with a `/`, I'm only concerned with interspersing and ending the
subdirectories with `/`.

I decided to use `foldl'`, not `foldr` since I don't have to deal with infinite
data, which I had to make a function for it.


``` diff
urlDataToUrl :: UrlData -> Text
urlDataToUrl urlData =
  mconcat
    [ baseUrl
-   , mconcat . udSubdir $ urlData
+   , subdirToUrlSubdir . udSubdir $ urlData
    , paramsToUrlParams . udParams $ urlData
    ]
  where
+   subdirToUrlSubdir :: [Text] -> Text
+   subdirToUrlSubdir = mconcat . reverse . foldl' (\acc el -> "/":el:acc) []
```

The reason for prepending the next element to the list and then reversing it is
because I didn't want to spend O(n) in each iteration. This way it only happens
during the reverse and the concatenation.

#### Issue #2: I got the logic reversed for parsing URL parameters

This one was also pretty stupid. I have this other helper function in 
`urlDataToUrl`:

``` diff
    paramsToUrlParams :: Map Text Text -> Text
    paramsToUrlParams params
-     | Map.null params =
-       Map.foldlWithKey'
-         (\acc key val -> acc <> key <> "=" <> val)
-         mempty
-         params
-     | otherwise = mempty
+     | Map.null params = mempty
+     | otherwise =
+         Map.foldlWithKey'
+           (\acc key val -> acc <> key <> "=" <> val)
+           mempty
+           params
```

If there are no parameters (empty map), then it's gonna perform the fold, which
is supposed to be for when there are parameters. So yeah, just a simple swap
would do just fine.

#### Issue #3: What about `?` and `&`?

Yep, I forgot about those as well. Fortunately, not too difficult to do.

``` diff
    paramsToUrlParams :: Map Text Text -> Text
    paramsToUrlParams params
      | Map.null params = mempty
      | otherwise =
-         Map.foldlWithKey'
-           (\acc key val -> acc <> key <> "=" <> val)
            mempty
            params
      | Map.null params = mempty
      | otherwise =
+       Text.cons '?' $
+         Text.drop 1 $
+           Map.foldlWithKey'
+             (\acc key val -> acc <> "&" <> key <> "=" <> val)
              mempty
              params
```

#### Issue #4: `[""]` if there are no subdirectories

There was also an issue with `urlToUrlData`. 

``` haskell
urlToUrlData :: Text -> Maybe UrlData
urlToUrlData strippedUrl = do
  urlDataText <- Text.stripPrefix baseUrl strippedUrl

  let (subdirText:paramsText) = Text.splitOn "/?" urlDataText

      subdirs :: [Text]
      subdirs = Text.split (== '/') . Text.dropWhileEnd (== '/') $ subdirText

      params :: Map Text Text
      params = Map.fromList $
        map parseKeyValue $
          concatMap (Text.split (== '&')) paramsText

  pure (UrlData { udSubdir = subdirs, udParams = params })
```

e.g `https://swapi.dev/api/` (I treated this as a base URL), it would end up with
`UrlData { udSubdir = [""], udParams = Map.empty }`. The `[""]` being useless.

`subdirText` is essentially the subdirectories encoded as `Text`. If there are
no subdirectories, then, well, it's going to be `""`. If I parse it 
(look at `subdirs :: [Text]`) then the entire thing is going to end with `[""]`
which makes sense. So a simpler way would be to just first check if what I'm
dealing with is an empty text, and if it is I just give back an empty list.

``` diff haskell
subdirs :: [Text]
- subdirs = Text.split (== '/') . Text.dropWhileEnd (== '/') $ subdirText
+ subdirs =
+   if Text.null subdirText
+   then []
+   else Text.split (== '/') . Text.dropWhileEnd (== '/') $ subdirText
```

Lots of issues in general that I caught with pretty simple tests. Convenient.
This is just the `Url` module though. I wonder what other bugs I'll discover
in the instances.

### Day 12 - 14/12/2021

I'm gonna spend this day writing tests for the existing code. Parts I want to
test are:

* `Url` module
* `aeson` instances

I think it would be cool if I could use `SmallCheck` to handle most of these things
since it would save a lot of time. I have to read on it though.

- I refactored `getId` to use `urlToUrlData`. So now I don't have any janky 
pattern matching, and it's much easier to understand what's happening thanks to
`UrlData` :).
- I decided to change `getId` to evaluate to a `Maybe Int` rather than an 
`Either String Int` just so that I could compose things better. This *might* be
a terrible idea because I lose out on some important errors encoded in `String`.
- Wrote some test cases for `resourceUrl` and `getId`. It's a bit of a pain to
deal with `getId` so I added a note to refactor it with property-based testing.
I used [this](https://github.com/sshine/hs-jq) to check how to work with `Hspec`
with `tasty-hspec`, and it turns out I had to add the `hspec` library too since
it doesn't reexport the types and functions for me. Not that inconvenient though.
- I'm thinking twice about using `SmallCheck` but unfortunately, `validity` is
not a `tasty` provider. So I still have to compare between `SmallCheck` and
`Hedgehog`.

### Day 11 - 11/12/2021

- Did some digging around for the `tasty` providers I'll need. I think 
`tasty-hunit`, and `tasty-golden` are good for now.
- Added `tasty-discover` to make test files less of a pain to manage. Seems quite
similar with `hspec-discover`.
- I just copied the sample test cases from `tasty`'s docs. I'll be replacing it
with my own soon.
- I'll probably start testing the `Url` module first since it's pretty tiny.

### Day 10 - 08/12/2021

- Decided to eventually experiment with deriving `aeson` instances with 
`Generic`, but only for anything related with the `Vehicle` resource. Since I 
still want to practice the basics more.
- I've decided to use `tasty` over `sandwich` just because the former has 
golden tests. Golden tests would be useful for the JSON output in this case since
it's a bad idea to all that in a source file. Also, pretty annoying to modify
if that's the case.
- I *may* include `QuickCheck` but I still have to think for what cases I would
use it for. Although I do see the value in generating tests just based on the
properties I state.

Not really doing much today because this day was intended to be a day off.

### Day 9 - 06/12/2021

- Turns out I missed a few cases of colors
- I wanted an easier time in getting information out of a URL. Manually parsing 
it every time wasn't that convenient so I opted for a new type called `UrlData`
with the following definition:

``` haskell
data UrlData = UrlData
  { udSubdir :: [Text]
  , udParams :: Map Text Text
  }
```

The two key things I noticed I needed a lot was the subdirectory and the URL
parameters. 

#### `udSubdir`

The subdirectory is whatever follows the base URL which in this case
is anything after `https://swapi.dev/api/`. e.g `people/1/` gets parsed into 
`["people", "1"] :: [Text]`. Not the _most_ convenient since I still have to
potentially convert the person ID into a numeric type but I think it's good for
whatever I need it for.

#### `udParams`

This is useful when trying to get/encode information about, well, URL params.
In SWAPI there are two that I noticed (so far), which was `search` for any search
query, and `page` for paginating any indexing/searching of a resource. 

`?search=r2&page=1` gets parsed into `Map.fromList [("search" "r2"), ("page", "1")]`
. Pretty cool.

Having this domain type makes it easier to deal with this sort of thing. I don't
have to care about the base URL. I also don't need to care about how the URL is
structured. I only care about the data I get from it.

### Day 8 - 03/12/2021

- ~~Same thing as some of the fields, I added a `PersonId` newtype with some
smart constructors to ensure that it's at least `> 0`.~~
- ~~I changed the smart constructor check from `>= 0` to `> 0` cause I just found
out that it actually starts with `1`.~~ I thought it would be a better idea to 
expose the data constructors for IDs instead since it would be kinda tedious to 
deal with once the HTTP requests get implemented. I don't think ID really has to 
be validated since it's possible for one to have a negative ID (I think). 
- Added `edited` and `created` fields. So now it converts an ISO8601 UTC timestamp
into the appropriate domain type
- Added `Root` although I'm not sure what this is used for because I've already
added data constructors for the different resources. So, just parsing it as if
the URLs were text.
- I forgot about the index endpoint so that's what I'm working on right now. I 
think it would be cool if I could parse all the URL attributes. So I wouldn't 
have to worry if a param goes first or not. All I have to check is if the 
parameter exists in a map. Maps might be ideal for storing URL attributes in 
this case. I'll think about it for now.
- Made a really ugly solution for parsing a URL. I needed to get the subdir,
and query params. I didn't want to have to use a library for it because:

  1. I have no idea how to use it. Yet another thing to learn.
  2. The use case is a bit simple. 
  
But did it in the end (somewhat) and so here it is:

``` haskell
data UrlData = UrlData
  { udSubdir :: [Text]           -- Contains the list of subdirectories in path.
  , udParams :: Map Text Text    -- Contains query parameters as KV pairs .
  }
  deriving Show

-- In ghci
λ> mkUrlData "https://swapi.dev/api/people/1/?search=r2d2"
Just (UrlData {udSubdir = ["people","1"], udParams = fromList [("search","r2d2")]})

-- But it's not perfect. I'm supposed to URL encode some characters!
λ> mkUrlData "https://swapi.dev/api/people/1/?search=&r2d2"
Just (UrlData {udSubdir = ["people","1"], udParams = fromList [("r2d2",""),("search","")]})
```

I don't really care about the base URL, so I don't *need* that information. But,
I do need the subdirectory and the query parameters especially for down the road
when search and paging are to be implemented. 

Maybe I do need that URL library. Damn it.

### Day 7 - 01/12/2021

Not much today. Asked the community in the Matrix server (#Haskell), and Twitter
for some feedback. Got nothing yet. I think I'll wait a bit longer. Thinking of
pausing this for a bit while I cover some other material.

- Added the remaining instance signatures. I'm honestly surprised that this isn't
a default extension. It's just too convenient especially to those unfamiliar.

### Day 6 - 30/11/2021

- I didn't have to make individual functions for converting the colors to `Text`
, I could just implement the instances for `TextShow`, and done!
- With the necessary `TextShow` instances, I could just make a function to:

  1. map `TextShow a => [a]` to `[Text]`
  2. intercalate `", "` and concatenate the list of `Text` to a single `Text`

  I could just move the function out somewhere if ever I need it elsewhere.
- Only hair colors and skin colors have multiple values. It's possible for eye
colors to have, heterochromia and all that, but it doesn't seem like that's the
case in the SWAPI db dump. So, I'll keep `EyeColor` singular for now.
- I moved out any color-related type/function/instance to `SwapiClient/Color.hs`
cause it had a bit too much going on.
- I had to add functions that unwrap newtypes because it was a bit inconvenient
to manually pattern match the boxed value. This way I get to compose things
better!

```diff haskell
instance ToJSON (SkinColors :: Type) where
  toJSON :: SkinColors -> Value
- toJSON (SkinColors scs) = String . commaConcat $ scs
+ toJSON = String . commaConcat . unSkinColors
  
unSkinColors :: SkinColors -> [SkinColors]
unSkinColors (SkinColors scs) = scs
```

  It's a possibility that I might end up unboxing it elsewhere, given it's a
  common enough thing to do.

### Day 5 - 29/11/2021

- I added the remaining list of resources associated with `Person`.
- Refactored the colors for hair, skin, and eye, and just made them all sum types
instead. Turns out the colors vary from each other to a certain degree, and it
is pretty odd if I just use a general sum type for all colors.
- Made smart constructors for creating an ID. Can't be negative, ever.
- Fixed the incorrect implementation of the ID newtypes' `ToJSON` instances. It
had to have a trailing forward slash otherwise it would've been parsed 
incorrectly. 
- Refactored the aeson instances for the ID newtypes to use the smart 
constructors.
- In the `parseJSON` implementation for the ID newtypes, I think this is where
monads would be useful, especially since I could avoid the nested cases. For now
I wrote them all manually. I'm a bit sleepy.
- SWAPI sometimes formats a collection of things as a text that is comma 
separated. A bit annoying, but nothing too bad. I did run into an issue though
where I couldn't just simply parse a text value into a list of constructors.
Here's an example:

``` haskell
import Data.Aeson qualified as (withText)
import Data.Text qualified as Text (split)

-- This is just an example, not the complete type.
data HairColor = Red | Blue

instance FromJSON (HairColor :: Type) where
  parseJSON =
    Aeson.withText "HairColor" $
      \(hairColorText :: Text) ->
        let hairColors :: Either String [HairColor]
            hairColors = mapM textToHairColor . Text.split (== ',')
              $ hairColorText
        in case hairColors of
             Right hcs = pure hcs
             Left e -> fail e

textToHairColor :: Text -> Either String HairColor
textToHairColor hct = case hct of
  "red" -> Right Red
  "blue" -> Right Blue
  _ -> Left "ERROR: Unexpected color value/format"
```

  The problem would be that for this instance, it's
  `parseJSON :: Value -> Parser HairColor`, but instead it's going to be
  `Value -> Parser [HairColor]`. Hmm.
  
  The first thing that came to mind was to just simply enable `FlexibleInstances`
  and just swap `FromJSON (HairColor :: Type)` with `FromJSON ([HairColor :: Type])`.
  Easy huh. Well, no, because I quickly ran into another issue about overlapping
  instances! I definitely don't want to override anything, if ever that's what I'm
  doing. I did some digging and found [this](https://stackoverflow.com/questions/53478455/aeson-parse-json-object-to-list)
  which is pretty handy. It didn't really answer my question but I noticed that
  the asker just wrapped it in a `newtype`, and then used it for the instance.
  A bit annoying that I have to add one more type, but it seems convenient enough.
  There might be a better way, which I'll ask the community in the future. But for
  now, this works just fine.

- I have to reimplement the `aeson` instances for the colors. I've already done
the one for `HairColors`, but I have lots more to go. I should probably start
moving some things into their own modules as well; maybe in the future.

### Day 4 - 28/11/2021

- Moved `*Ids` into an `Id` module
- Films: decode URL to ID; encode ID to URL
- Homeworld: decode URL to ID; encode ID to URL
- There are cases where I had to deal with `Int -> Text`, but there is no such
signature for `show`. I just used `Text.pack . show`, but then wondered if there
was a better way in terms of ergonomics and performance. I found `text-show`,
and tried it out in some cases. Not sure how I feel about it overall, since I'm
not sure if it really makes that big of a difference for this tiny application.
- Decided to make the `*Id` types as opaque types - where I can't touch the data
constructors, and have to rely on the smart constructors. I think it's better
this way, so I can ensure that it's at least a non-negative number.

### Day 3 - 27/11/2021

- I was a bit confused why I was able to use `fail`. I don't know why I was even
confused. I realized that `Parser` has a `MonadFail` instance so that's why.
Cool. To avoid going down a rabbit hole again, I'll avoid the technicalities of
`MonadFail` for now.
- I don't think I should've implemented the `ToJSON` instances cause I don't 
really need them. I'm just decoding JSON to domain types after all. But I guess
this would be useful when I make a replacement API for SWAPI in the future? For
now I'll just leave these here.
- I enabled `KindSignatures` to make things more explicit. Helps me out quite a
bit.
- It isn't really helpful to have `Homeworld` but it's actually just an ID. Later
on I'll be making a `Homeworld` type with the actual data, not just a reference
through an ID. So to make that distinction, I'm gonna suffix the types and field
names with `Id`(s) if they deal with Ids, and none if without.
- I have to find a way to organize the modules that doesn't cause circular 
imports. Right now I have imported `HomeworldId` from `SwapiClient.Homeworld`
and `FilmId` from `SwapiClient.Film`. If I put the `Homeworld` and `Film` records
in the corresponding modules, then I'll have to import some things from other
modules that already have those modules imported. I don't know how to word it 
better, but the idea is that I think I have to put the `Id` types in separate
modules as well. I could also just make a module `Id` that has all of the ID
types instead, that way it won't be too annoying to keep track of? I don't know
yet.

### Day 2 - 26/11/2021

- I just found out that `text` had some handy functions in the `Data.Text.Read`
module that does what I was annoyed with - parsing something like `"20BBY"`! How
I've initially done it was because the time periods `BBY` and `ABY` had 3 chars,
I just took the last 3 characters of the value and checked if it matched either
of the two. `Text.Read.decimal` is convenient because of this:

``` haskell
data BirthYear
  = BBY Double
  | ABY Double
  | UnknownBirthYear
  deriving Show

foo =
  let str = "20BBY"
  in case decimal str of
        Left e -> error "Does not start with a number"
        Right (years, "BBY") -> BBY years
        Right (years, "ABY") -> ABY years
```

It's at least much easier compared to manually taking apart the text and parsing
the number.
- I added the rest of the `Person` fields which wasn't really difficult. It was
just a chore to have to write each instance for each domain type I wrote, but
it helps things stick in my head.
- I was stuck with how to deal with `"unknown"` that SWAPI likes to use. Like
when the mass of a person is unknown so it becomes `"mass": "unknown"` rather
than a `Double`. I initially made it `Maybe Mass` (`newtype Mass = Mass Double`)
but then I ran into issues when implementing the `FromJSON` instance for it.
I couldn't deal with the unknown part of it, and I'm not sure how so I figured
I would just turn it into a sum type, and add an extra constructor `UnknownMass`.
- One of the things that puzzle me is, how do I handle unexpected types in
`parseJSON`? What if I got an `Array a` instead of `String s` for example?
Currently just using `error` which sounds OK in my head because I'm alright with
things failing at the boundary of the library. I think I remember something about
using `throwError` instead, or something like that, because you have to add it 
to the type constraints, but I can't remember exactly what it was called. Although
I did find in the `aeson` docs that they used `fail` cause of `MonadFail`.
- I enabled the `StrictData` language extension cause it seems to be a general
enough consensus to use it.
- Before I wrote the entire instance for `FromJSON Homeworld`, GHC got confused
when I used `toBoundedInteger` cause it couldn't figure out which type should
inhabit `Integral i`, so I used `TypeApplications` to let it know while I'm still
working on it. e.g `toBoundedInteger @Int homeworldId`. A reason why I left it
on in Cabal cause I don't really want to manually enable it again and again.
- I used `newtype`s for stuff like `Mass`, `Height`, and so I was expecting some
issues when decoding it to JSON. What if I had to manually unwrap the contents?
Turns out I didn't have to, which is nice. Then I wondered: Huh? Why didn't it
require me to? Which I quickly, and stupidly, realized that it's because that's
how I implemented the `ToJSON` instances.

I still have some stuff to do, the most annoying one is how I convert `Double`s
back to `String`s. `"19.1BBY"` to `BBY 19.1` to `"19.1BBY"` is expected. But
`"19BBY"` to `BBY 19.0` to `"19.0BBY"` isn't since SWAPI truncates `.0` if it can
be turned to a whole number.

### Day 1 - 25/11/2021

Unfortunately, I did not start taking down notes on day 1. So I might have
forgotten some of the things.

- I ran into a bug when using HLS 1.5 with a fresh project generated with
`cabal init --interactive`. I've detailed the problem
[here](https://gist.github.com/sekunho/72747c20a192e62a6fc9dc9e9660aa0a)
and the workaround is just to use `gen-hie` to generate a simple `hie.yaml`. The
issue is being tracked
[here](https://github.com/haskell/haskell-language-server/issues/2398).
- I placed everything in `SwapiClient.hs` for now because I don't really have
to organize things (yet). I know, I will do so in the future when I start adding
other things as well.
- Tackling JSON encoding/decoding is an interesting first problem to solve, more
enjoyable than HTTP clients for now at least since I wanted to get used to building
domain types.
- There are some challenges I ran into, which is a good thing - I can't use
the autoderiving stuff that's available in `aeson` because of two things I wanted:

    1. Encoding a sum type must not preserve the capitalization of a constructor.
    e.g Encoding `data Foo = Bar | Baz` should not result in `"Bar"` or `"Baz"`
    since the SWAPI documentation requires it to be all lowercase.

    2. Naming convention of the JSON field names and the record field accessor
    differentiate. Former being snake case `hello_world`, and the latter being
    camel case `helloWorld`. I also wanted to prefix my record fields so I don't
    run into the headache of one of the record problems that Haskell has. There's
    probably an extension to enable that I missed, but what's one letter/word as
    a prefix really gonna cost me?
