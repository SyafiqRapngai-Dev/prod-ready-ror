class ActivityLogJob < ApplicationJob
  queue_as :default

  # Records an activity log entry for any trackable resource.
  #
  # @param trackable_type [String]  e.g. "Task", "Comment"
  # @param trackable_id   [Integer]
  # @param actor_id       [Integer] the user who performed the action
  # @param action         [String]  e.g. "created", "updated", "destroyed"
  # @param metadata       [Hash]    optional key/value pairs to store with the log
  def perform(trackable_type, trackable_id, actor_id, action, metadata = {})
    trackable = trackable_type.constantize.find_by(id: trackable_id)
    return unless trackable

    actor = User.find_by(id: actor_id)
    return unless actor

    ActivityLog.create!(
      trackable: trackable,
      actor:     actor,
      action:    action,
      metadata:  metadata
    )
  end
end
