require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # rack_test keeps the suite dependency free: no browser, no driver binaries.
  # The submission flow does not rely on JavaScript, the "Submit for review"
  # button in the preview posts to `advisories_path` through `formaction`.
  driven_by :rack_test
end
