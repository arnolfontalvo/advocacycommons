class PhoneNumber < ApplicationRecord
  include ArelHelpers::ArelTable
  belongs_to :person

  validates_presence_of :number
  validates_uniqueness_of :number, scope: :person_id
end
