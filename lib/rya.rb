require "abort_if"

# Needed for Rya::CoreExtensions::Process
require "systemu"

require "rya/version"
require "rya/core_extensions"

module Rya
  # If you want to use AbortIf from this module, you can use it as Rya::AbortIf
  module AbortIf
    # To include the methods
    extend Object::AbortIf
    extend Object::AbortIf::Assert

    # To include the helper classes
    include Object::AbortIf
  end
end
