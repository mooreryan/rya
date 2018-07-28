RSpec.describe Rya do
  it "has a version number" do
    expect(Rya::VERSION).not_to be nil
  end

  it "has access to abort if methods" do
    expect { Rya::AbortIf.logger.info { "Hi, Ryan" } }.not_to raise_error
  end

  it "has access to abort if assert methods" do
    expect { Rya::AbortIf.assert 1 == 1 }.not_to raise_error
  end
end
