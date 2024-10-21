module Evergreen.Migrate.V110 exposing (..)

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

import Evergreen.V109.Types
import Evergreen.V110.Types
import Lamdera.Migrations exposing (..)


frontendModel : Evergreen.V109.Types.FrontendModel -> ModelMigration Evergreen.V110.Types.FrontendModel Evergreen.V110.Types.FrontendMsg
frontendModel _ =
    ModelReset


backendModel : Evergreen.V109.Types.BackendModel -> ModelMigration Evergreen.V110.Types.BackendModel Evergreen.V110.Types.BackendMsg
backendModel _ =
    ModelReset


frontendMsg : Evergreen.V109.Types.FrontendMsg -> MsgMigration Evergreen.V110.Types.FrontendMsg Evergreen.V110.Types.FrontendMsg
frontendMsg _ =
    MsgOldValueIgnored


toBackend : Evergreen.V109.Types.ToBackend -> MsgMigration Evergreen.V110.Types.ToBackend Evergreen.V110.Types.BackendMsg
toBackend _ =
    MsgOldValueIgnored


backendMsg : Evergreen.V109.Types.BackendMsg -> MsgMigration Evergreen.V110.Types.BackendMsg Evergreen.V110.Types.BackendMsg
backendMsg _ =
    MsgOldValueIgnored


toFrontend : Evergreen.V109.Types.ToFrontend -> MsgMigration Evergreen.V110.Types.ToFrontend Evergreen.V110.Types.FrontendMsg
toFrontend _ =
    MsgOldValueIgnored