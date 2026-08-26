require 'test_helper'

class RubymemAdvisoryTest < ActiveSupport::TestCase
  test "generate_yaml exposes the advisory attributes and drops the blank ones" do
    advisory = FactoryBot.create(:rubymem_advisory,
                                 gem: 'leaky_gem',
                                 title: 'Memory leak',
                                 description: 'It leaks.',
                                 url: nil,
                                 patched_versions: ['>= 1.2.3'],
                                 unaffected_versions: [])

    yaml = YAML.safe_load(advisory.generate_yaml, permitted_classes: [Date])

    assert_equal 'leaky_gem', yaml['gem']
    assert_equal 'Memory leak', yaml['title']
    assert_equal ['>= 1.2.3'], yaml['patched_versions']
    refute yaml.key?('url'), 'blank attributes must not reach the YAML'
    refute yaml.key?('unaffected_versions'), 'empty arrays must not reach the YAML'
    # Internal bookkeeping stays out of the published advisory.
    %w[id ident identifier imported submitter_email created_at updated_at].each do |key|
      refute yaml.key?(key), "#{key} must not reach the YAML"
    end
  end

  test "relevant_attributes drops the identity and timestamp columns" do
    advisory = FactoryBot.create(:rubymem_advisory)

    attributes = advisory.relevant_attributes

    %w[id ident created_at updated_at].each do |key|
      refute attributes.key?(key), "#{key} must not be part of relevant_attributes"
    end
    assert attributes.key?('identifier')
    assert attributes.key?('gem')
  end

  test "the imported scope only returns reviewed advisories" do
    published = FactoryBot.create(:rubymem_advisory, imported: true)
    FactoryBot.create(:rubymem_advisory, imported: false)

    assert_equal [published], RubymemAdvisory.imported.to_a
  end

  test "advisories default to unpublished" do
    assert_equal false, RubymemAdvisory.new.imported
  end

  test "the recent scope orders by disclosure date, newest first" do
    older = FactoryBot.create(:rubymem_advisory, date: Date.new(2015, 1, 1))
    newest = FactoryBot.create(:rubymem_advisory, date: Date.new(2017, 6, 1))
    middle = FactoryBot.create(:rubymem_advisory, date: Date.new(2016, 3, 1))

    assert_equal [newest, middle, older], RubymemAdvisory.recent.to_a
  end

  test "ident is generated as a secure token" do
    advisory = FactoryBot.create(:rubymem_advisory)

    assert_match(/\A[a-zA-Z0-9]{24}\z/, advisory.ident)
  end

  test "to_param keeps the identifier up to the first dot" do
    advisory = FactoryBot.build(:rubymem_advisory, identifier: 'leaky_gem-670')

    assert_equal 'leaky_gem-670', advisory.to_param
  end

  # Characterization tests: these lock in behavior that is currently wrong, so a
  # fix has to update them deliberately rather than by accident.

  test "CHARACTERIZATION to_param raises for an advisory submitted through the form" do
    # `create` never assigns an identifier, so linking to a submitted advisory
    # blows up instead of rendering.
    submitted = RubymemAdvisory.create!(gem: 'leaky_gem', title: 'Memory leak')

    assert_nil submitted.identifier
    assert_raises(NoMethodError) { submitted.to_param }
  end

  test "CHARACTERIZATION an identifier containing a dot cannot round trip" do
    # to_param truncates at the dot, and `show` looks the record up by the full
    # identifier, so the generated URL cannot find it.
    advisory = FactoryBot.create(:rubymem_advisory, identifier: 'leaky_gem-1.2')

    assert_equal 'leaky_gem-1', advisory.to_param
    assert_nil RubymemAdvisory.find_by(identifier: advisory.to_param)
  end

  test "CHARACTERIZATION an advisory has no validations at all" do
    # Anything the submission form posts is accepted, including nothing.
    assert RubymemAdvisory.new.valid?
    assert_difference 'RubymemAdvisory.count', 1 do
      RubymemAdvisory.create!
    end
  end
end
