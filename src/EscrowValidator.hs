{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ImportQualifiedPost #-}

module EscrowValidator where

import Plutus.V1.Ledger.Scripts qualified
import Plutus.V1.Ledger.Api (ScriptContext, Validator)
import Plutus.V1.Ledger.Crypto (PubKeyHash)
import Plutus.V1.Ledger.Tx (Address)
import PlutusTx (makeIsDataIndexed, makeLift)

data EscrowRedeemer = Close | Refund

data EscrowDatum = EscrowDatum
  { organizerAddr :: Address,
    eventDate :: Integer,
    bookedAt :: Integer
  }
  deriving (Show, Eq)

data EscrowProvider = EscrowProvider
  { pkHash :: PubKeyHash,
    addr :: Address
  }
  deriving (Show, Eq)

-- | Organizer (O')
-- | Attendee (A')

-- | once A' sends the funds he can only withdraw them up to 48h,
-- | how do we notify O'?

-- | 1. allow O' to change their receiving addr
-- | 2. let mediator release the funds after a determined timeout
-- | 3. let O' cancel the event (release funds back to A')
makeIsDataIndexed ''EscrowRedeemer [('Close, 0), ('Refund, 1)]
makeLift ''EscrowProvider
makeLift ''EscrowDatum

-- newType instance Plutus.V1.Ledger.Scripts
instance Scripts Typed where
    type RedeemerType = EscrowRedeemer
    type DatumType = EscrowDatum

-- | CustomParameters, Redeemer, Datum , Context
{-# INLINEABLE mkValidator #-}
mkValidator :: EscrowProvider -> EscrowDatum -> EscrowRedeemer -> ScriptContext -> Bool
mkValidator prov datum red ctx = True

-- validator :: Validator
-- validator = mkValidatorScript $$(compile [||
