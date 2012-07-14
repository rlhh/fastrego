FactoryGirl.define do

  factory :institution do
    sequence(:abbreviation) { |n| "MMU#{n}" }
    sequence(:name) { |n| "Multimedia University #{n}" }
    website 'http://www.mmu.edu.my'
    country 'Malaysia'
  end

  factory :admin_user do
    email 'admin@test.com'
    password 'password'
  end

  factory :user do
      name 'Suthen Thomas'
      sequence(:email) { |n| "suthen#{n}.thomas@gmail.com" }
      password 'password'
      phone_number '123123123123'
      institution
  end

  factory :tournament_name, class: Setting do
    key 'tournament_name'
    value 'Logan\'s Debate Extravaganza'
  end
  factory :debate_team_fees, :class => Setting do
    key 'debate_team_fees'
    value '200'
  end

  factory :adjudicator_fees, :class => Setting do
    key 'adjudicator_fees'
    value '100'
  end

  factory :observer_fees, :class => Setting do
    key 'observer_fees'
    value '100'
  end

  factory :enable_pre_registration, :class => Setting do
    key 'enable_pre_registration'
    value 'True'
  end

  factory :debate_team_size, class: Setting do
    key 'debate_team_size'
    value 3
  end

  factory :currency_symbol, :class => Setting do
    key 'currency_symbol'
    value 'RM'
  end

  factory :tournament_registration_email, class: Setting do
    key 'tournament_registration_email'
    value 'test@test.com'
  end

  factory :registration do
    debate_teams_requested 3
    adjudicators_requested 1
    observers_requested 1
    requested_at '2011-01-01 01:01:01'
    user
  end

  factory :payment do
    account_number 'AB1231234'
    amount_sent 12000
    date_sent '2011-12-12'
    comments 'Total payment - arriba!'
    scanned_proof { Rack::Test::UploadedFile.new(File.join(Rails.root,'spec','uploaded_files','test_image.jpg'), 'image/png')  }
    registration
  end
 
  factory :observer, class: Observer do
    name 'Jack Observer'
    gender 'Male'
    email 'test@test.com'
    dietary_requirement 'Halal'
    point_of_entry 'KLIA'
    emergency_contact_person 'Jason Statham'
    emergency_contact_number '123123123123'
    registration

    factory :custom_field_observer do
      debate_experience 5
      tshirt_size 'small'
    end
  end


  factory :debater do
    name 'Jack Nostrum'
    gender 'Male'
    email 'test@test.com'
    dietary_requirement 'Halal'
    point_of_entry 'KLIA'
    emergency_contact_person 'Jason Statham'
    emergency_contact_number '123123123123'
    speaker_number 1
    team_number 1
    registration
  end
end
