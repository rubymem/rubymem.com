FactoryGirl.define do
  sequence :cve do |n|
    "CVE-2016-#{n}"
  end

  sequence :gem do |n|
    "gem_number#{n}"
  end

  factory :rubysec_advisory do
    identifier { "#{gem}-#{cve}" }
    gem
    cve
    date { rand(1..99).weeks.ago }
    title "this is a title"
    patched_versions { ["> 1.2.3", "~> 3.2"] }
    unaffected_versions { [">= 1.2.4", "~> 2.2"] }
    updated_at { rand(1..99).weeks.ago }
  end
end
