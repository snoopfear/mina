let Prelude =  ../External/Prelude.dhall
let S = ../Lib/SelectFiles.dhall
let Cmd =  ../Lib/Cmds.dhall
let Pipeline = ../Pipeline/Dsl.dhall
let Command = ../Command/Base.dhall
let OpamInit = ../Command/OpamInit.dhall
let WithCargo = ../Command/WithCargo.dhall
let Docker = ../Command/Docker/Type.dhall
let Size = ../Command/Size.dhall
let JobSpec = ../Pipeline/JobSpec.dhall

in

Pipeline.build
  Pipeline.Config::
    { spec =
      JobSpec::
        { dirtyWhen = OpamInit.dirtyWhen #
          [ S.strictlyStart (S.contains "buildkite/src/Jobs/LintOpt")
          , S.strictlyStart (S.contains "src")
          ]
        , name = "LintOpt"
        }
    , steps =
      [ Command.build
          Command.Config::
            { commands = OpamInit.andThenRunInDocker ([] : List Text) "BASE_BRANCH_NAME=$(pipeline.git.base_revision) ./scripts/compare_ci_diff_types.sh"
            , label = "Compare CI diff types and binables"
            , key = "lint-opt"
            , target = Size.Small
            , docker = None Docker.Type
            }
      ],
      [ Command.build
          Command.Config::
            { commands = OpamInit.andThenRunInDocker ([] : List Text) "BASE_BRANCH_NAME=$(pipeline.git.base_revision) ./scripts/compare_ci_diff_binables.sh"
            , label = "Compare CI diff types and binables"
            , key = "lint-opt"
            , target = Size.Small
            , docker = None Docker.Type
            }
      ],
    }

