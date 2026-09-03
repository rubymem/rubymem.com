require 'test_helper'

class RubymemAdvisoryTest < ActiveSupport::TestCase
  # The form marks gem, url, title, date, description and submitter_email as
  # required, the model has to enforce the same set.
  REQUIRED_ATTRIBUTES = %i[gem url title date description].freeze

  test "an advisory carrying every required attribute is valid" do
    assert FactoryBot.build(:rubymem_advisory).valid?
  end

  REQUIRED_ATTRIBUTES.each do |attribute|
    test "#{attribute} is required" do
      advisory = FactoryBot.build(:rubymem_advisory, attribute => nil)

      refute advisory.valid?
      assert_includes advisory.errors[attribute], "can't be blank"
    end

    test "#{attribute} cannot be blank" do
      advisory = FactoryBot.build(:rubymem_advisory, attribute => '')

      refute advisory.valid?
      assert_includes advisory.errors[attribute], "can't be blank"
    end
  end

  test "a submission has to say who reported the leak" do
    advisory = FactoryBot.build(:rubymem_advisory, submitter_email: nil, imported: false)

    refute advisory.valid?
    assert_includes advisory.errors[:submitter_email], "can't be blank"
  end

  test "an imported advisory has no submitter" do
    # The advisory database carries no submitter_email, the importer would not
    # be able to store a single file if this were required.
    advisory = FactoryBot.build(:rubymem_advisory, submitter_email: nil, imported: true)

    assert advisory.valid?
  end

  test "the optional fields stay optional" do
    advisory = FactoryBot.build(:rubymem_advisory, unaffected_versions: [],
                                patched_versions: [], related_links: [])

    assert advisory.valid?, advisory.errors.full_messages.join(', ')
  end

  test "an empty advisory reports every missing attribute at once" do
    advisory = RubymemAdvisory.new

    refute advisory.valid?
    assert_equal (REQUIRED_ATTRIBUTES + [:submitter_email]).sort,
                 advisory.errors.attribute_names.sort
  end

  test "generate_yaml exposes the advisory attributes and drops the blank ones" do
    advisory = FactoryBot.create(:rubymem_advisory,
                                 gem: 'leaky_gem',
                                 title: 'Memory leak',
                                 description: 'It leaks.',
                                 patched_versions: ['>= 1.2.3'],
                                 unaffected_versions: [],
                                 related_links: [])

    yaml = YAML.safe_load(advisory.generate_yaml, permitted_classes: [Date])

    assert_equal 'leaky_gem', yaml['gem']
    assert_equal 'Memory leak', yaml['title']
    assert_equal ['>= 1.2.3'], yaml['patched_versions']
    refute yaml.key?('unaffected_versions'), 'empty arrays must not reach the YAML'
    refute yaml.key?('related_links'), 'empty arrays must not reach the YAML'
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

  test "to_param falls back to the id for an advisory submitted through the form" do
    # `create` does not assign an identifier, the advisory only gets one once a
    # reviewer imports it.
    submitted = FactoryBot.create(:rubymem_advisory, identifier: nil)

    assert_equal submitted.id.to_s, submitted.to_param
    # The symptom this guards against: linking to a submission used to raise.
    assert_equal "/advisories/#{submitted.id}",
                 Rails.application.routes.url_helpers.advisory_path(submitted)
  end

  test "to_param is nil safe for an advisory that was never stored" do
    assert_nil RubymemAdvisory.new.to_param
  end

  # Characterization test: this locks in behavior that is still wrong, so a fix
  # has to update it deliberately rather than by accident. Fixing it means
  # changing how the route handles dots, not just to_param.
  test "CHARACTERIZATION an identifier containing a dot cannot round trip" do
    # to_param truncates at the dot, and `show` looks the record up by the full
    # identifier, so the generated URL cannot find it.
    advisory = FactoryBot.create(:rubymem_advisory, identifier: 'leaky_gem-1.2')

    assert_equal 'leaky_gem-1', advisory.to_param
    assert_nil RubymemAdvisory.find_by(identifier: advisory.to_param)
  end

  test "an empty advisory cannot be stored" do
    assert_no_difference 'RubymemAdvisory.count' do
      assert_raises(ActiveRecord::RecordInvalid) { RubymemAdvisory.create! }
    end
  end
end
