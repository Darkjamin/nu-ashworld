module Evergreen.Migrate.V136 exposing (..)

{-| This migration file was automatically generated by the lamdera compiler.

It includes:

  - A migration for each of the 6 Lamdera core types that has changed
  - A function named `migrate_ModuleName_TypeName` for each changed/custom type

Expect to see:

  - `Unimplementеd` values as placeholders wherever I was unable to figure out a clear migration path for you
  - `@NOTICE` comments for things you should know about, i.e. new custom type constructors that won't get any
    value mappings from the old type by default

You can edit this file however you wish! It won't be generated again.

See <https://dashboard.lamdera.app/docs/evergreen> for more info.

-}

import Evergreen.V135.Types
import Evergreen.V136.Types
import Lamdera.Migrations exposing (..)


frontendModel : Evergreen.V135.Types.FrontendModel -> ModelMigration Evergreen.V136.Types.FrontendModel Evergreen.V136.Types.FrontendMsg
frontendModel _ =
    ModelReset


backendModel : Evergreen.V135.Types.BackendModel -> ModelMigration Evergreen.V136.Types.BackendModel Evergreen.V136.Types.BackendMsg
backendModel _ =
    ModelReset


frontendMsg : Evergreen.V135.Types.FrontendMsg -> MsgMigration Evergreen.V136.Types.FrontendMsg Evergreen.V136.Types.FrontendMsg
frontendMsg _ =
    MsgOldValueIgnored


toBackend : Evergreen.V135.Types.ToBackend -> MsgMigration Evergreen.V136.Types.ToBackend Evergreen.V136.Types.BackendMsg
toBackend _ =
    MsgOldValueIgnored


backendMsg : Evergreen.V135.Types.BackendMsg -> MsgMigration Evergreen.V136.Types.BackendMsg Evergreen.V136.Types.BackendMsg
backendMsg _ =
    MsgOldValueIgnored


toFrontend : Evergreen.V135.Types.ToFrontend -> MsgMigration Evergreen.V136.Types.ToFrontend Evergreen.V136.Types.FrontendMsg
toFrontend _ =
    MsgOldValueIgnored
