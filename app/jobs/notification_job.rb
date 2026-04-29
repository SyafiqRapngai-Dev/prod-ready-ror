class NotificationJob < ApplicationJob
  queue_as :default

  # Creates Notification records for all relevant recipients.
  #
  # @param notifiable_type [String] e.g. "Comment", "Task"
  # @param notifiable_id   [Integer]
  # @param actor_id        [Integer] the user who triggered the event
  # @param action          [String]  e.g. "commented", "assigned"
  def perform(notifiable_type, notifiable_id, actor_id, action)
    notifiable = notifiable_type.constantize.find_by(id: notifiable_id)
    return unless notifiable

    actor = User.find_by(id: actor_id)
    return unless actor

    recipients = determine_recipients(notifiable, actor)

    recipients.each do |recipient|
      Notification.create!(
        user:       recipient,
        actor:      actor,
        notifiable: notifiable,
        action:     action
      )
    end
  end

  private

  def determine_recipients(notifiable, actor)
    recipients = case notifiable
    when Comment
                   task = notifiable.task
                   [ task.creator ] + task.assignees.to_a
    when Task
                   notifiable.assignees.to_a
    else
                   []
    end

    # Never notify the actor about their own action
    recipients.compact.uniq.reject { |r| r.id == actor.id }
  end
end
