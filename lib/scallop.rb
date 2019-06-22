require "benchmark"
require "open3"

require "scallop/command_builder"
require "scallop/errors"
require "scallop/executor"
require "scallop/param"
require "scallop/public_api"
require "scallop/result"
require "scallop/version"

module Scallop
  include PublicAPI
end
