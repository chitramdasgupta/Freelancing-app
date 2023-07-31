# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    title { 'My Project Title' }
    description { 'Project Description' }
    user
  end
end
