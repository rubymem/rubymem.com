FactoryGirl.define do
  sequence :gem do |n|
    "gem_number#{n}"
  end

  factory :rubymem_advisory do
    identifier { gem }
    gem
    date { rand(1..99).weeks.ago }
    title "this is a title"
    patched_versions { ["> 1.2.3", "~> 3.2"] }
    unaffected_versions { [">= 1.2.4", "~> 2.2"] }
    updated_at { rand(1..99).weeks.ago }
  end
end
