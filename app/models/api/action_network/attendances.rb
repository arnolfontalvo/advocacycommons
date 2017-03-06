class Api::ActionNetwork::Attendances
  attr_accessor :attendances

  # Import event attendances from Action Network OSDI API.
  # Requires ACTION_NETWORK_API_TOKEN set in ENV.
  # There are no external endpoints for this method yet.
  def self.import!(event)
    action_network_event_id = event.identifier_id('action_network')
    logger.info "Api::ActionNetwork::Attendances#import! from https://actionnetwork.org/api/v2/events/#{action_network_event_id}/attendances"

    attendances = request_attendances_from_action_network(action_network_event_id)

    Attendance.transaction do
      existing_attendances, new_attendances = partition_attendances(attendances)
      updated_count = update_attendances(existing_attendances)
      logger.debug "Api::ActionNetwork::Attendances#import! new: #{new_attendances.size} existing: #{existing_attendances.size} updated: #{updated_count}"
      new_attendances = add_associations(new_attendances, event.id)
      new_attendances.each(&:save!)
    end
  end

  def self.request_attendances_from_action_network(action_network_event_id)
    action_network = Api::ActionNetwork::Attendances.new
    client = Api::ActionNetwork::AttendancesRepresenter.new(action_network)
    client.get(uri: "https://actionnetwork.org/api/v2/events/#{action_network_event_id}/attendances", as: 'application/json') do |request|
      request['OSDI-API-TOKEN'] = Rails.application.secrets.action_network_api_token
    end

    logger.debug "Api::ActionNetwork::Attendances#import! attendances: #{action_network.attendances.size}"
    action_network.attendances
  end

  def self.partition_attendances(attendances)
    attendances.partition do |attendance|
      action_network_identifier = attendance.identifier('action_network')
      Attendance.any_identifier(action_network_identifier).exists?
    end
  end

  # Update all attributes for attendances that already exist and have not been modified after import
  # We may want to do something different
  def self.update_attendances(existing_attendances)
    updated_count = 0
    existing_attendances.each do |attendance|
      old_attendance = Attendance.outdated_existing(attendance, 'action_network').first

      if old_attendance
        updated_count += 1
        attributes = attendance.attributes
        attributes.delete_if { |k, v| v.nil? }
        old_attendance.update_attributes! attributes
      end
    end

    updated_count
  end

  def self.add_associations(new_attendances, event_id)
    new_attendances.each do |attendance|
      attendance.event_id = event_id
      person = Person.create!(identifiers: ["action_network:#{attendance.person_uuid}"], given_name: 'TBD')
      attendance.person_id = person.id
    end
  end

  def self.logger
    Attendance.logger
  end
end