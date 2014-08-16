FactoryGirl.define do
  factory :category do
    name_pt { "category-#{rand}" }
  end

  factory :contribution do
    confirmed_at { Time.now }
    credits      false
    value        10
    state        :confirmed
    association :project, factory: :online_project
    user
  end

  factory :match do |f|
    finishes_at { project.expires_at }
    starts_at   { Time.now.utc.to_date }
    state       :confirmed
    value       1_500
    value_unit  2
    association :project, factory: :online_project
    user
  end

  factory :project do
    about    'a-big-text-about-the-project'
    goal     10_000
    headline 'attractive-headline'
    location 'New York, NY'
    name     'a-project'
    user
    category

    factory :online_project do
      online_date { Time.now }
      online_days 30
      state       'online'
    end
  end

  factory :user do
    name         'Joãozinho'
    password     'right-password'
    email        { "person#{rand}@example.com" }
    confirmed_at { Time.now }
  end
end
