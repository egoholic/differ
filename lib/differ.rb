require "differ/version"

module Differ
  require "differ/diff_service"

  def self.diff(fpath1, fpath2)
    service = DiffService.new fpath1, fpath2

    service.call
  end
end
