module SwapiClient.Film (FilmId (FilmId)) where

import Data.Aeson (FromJSON (parseJSON), ToJSON (toJSON), Value (Number))
import qualified Data.Aeson as Aeson (withScientific)
import Data.Kind (Type)
import qualified Data.Scientific as Scientific (toBoundedInteger)

--------------------------------------------------------------------------------
-- DATA TYPES

newtype FilmId = FilmId Int
  deriving Show

instance FromJSON FilmId where
  parseJSON =
    Aeson.withScientific "FilmId" $
      \filmId ->
        case Scientific.toBoundedInteger filmId of
         Just intId -> pure $ FilmId intId
         Nothing -> fail "ERROR: Film id must be a valid integer."

instance ToJSON (FilmId :: Type) where
  toJSON (FilmId filmId) = Number . fromIntegral $ filmId
