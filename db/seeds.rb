# frozen_string_literal: true

# =============================================================================
# SEEDS — ProjectFlow Demo Data
# =============================================================================
# Run with: rails db:seed
# Idempotent: safe to run multiple times (uses find_or_create_by!)
# =============================================================================

puts "==> Cleaning existing seed data..."
# Remove in reverse dependency order to respect foreign keys
ActivityLog.delete_all
Notification.delete_all
Tagging.delete_all
Comment.delete_all
TaskAssignment.delete_all
Task.delete_all
Label.delete_all
Column.delete_all
Board.delete_all
ProjectMember.delete_all
Project.delete_all
Membership.delete_all
Organization.delete_all
User.delete_all

puts "==> Creating users..."

alice = User.create!(
  name:                  "Alice Chen",
  email:                 "alice@example.com",
  password:              "password123",
  password_confirmation: "password123"
)

bob = User.create!(
  name:                  "Bob Martinez",
  email:                 "bob@example.com",
  password:              "password123",
  password_confirmation: "password123"
)

carol = User.create!(
  name:                  "Carol Smith",
  email:                 "carol@example.com",
  password:              "password123",
  password_confirmation: "password123"
)

dave = User.create!(
  name:                  "Dave Kim",
  email:                 "dave@example.com",
  password:              "password123",
  password_confirmation: "password123"
)

eve = User.create!(
  name:                  "Eve Johnson",
  email:                 "eve@example.com",
  password:              "password123",
  password_confirmation: "password123"
)

puts "  Created #{User.count} users"

# =============================================================================
# ORGANIZATION 1: Acme Corp
# =============================================================================
puts "==> Creating Acme Corp organization..."

acme = Organization.create!(
  name:        "Acme Corp",
  description: "Building products that power the future"
)

Membership.create!(user: alice, organization: acme, role: :owner)
Membership.create!(user: bob,   organization: acme, role: :admin)
Membership.create!(user: carol, organization: acme, role: :member)
Membership.create!(user: dave,  organization: acme, role: :member)

puts "  Slug auto-generated: #{acme.slug}"

# =============================================================================
# PROJECT 1: Acme Website
# =============================================================================
puts "==> Creating Acme Website project..."

website = Project.create!(
  organization: acme,
  name:         "Website Redesign",
  key:          "WEB",
  description:  "Complete overhaul of the company website",
  status:       :active
)

ProjectMember.create!(project: website, user: alice, role: :manager)
ProjectMember.create!(project: website, user: bob,   role: :manager)
ProjectMember.create!(project: website, user: carol, role: :member)

web_board = Board.create!(project: website, name: "Main Board")

# Columns are auto-positioned by before_create callback
web_backlog    = Column.create!(board: web_board, name: "Backlog",     color: "#94a3b8")
web_in_progress = Column.create!(board: web_board, name: "In Progress", color: "#3b82f6")
web_review     = Column.create!(board: web_board, name: "In Review",   color: "#f59e0b")
web_done       = Column.create!(board: web_board, name: "Done",        color: "#22c55e")

# Labels
bug_label     = Label.create!(project: website, name: "Bug",      color: "#ef4444")
feature_label = Label.create!(project: website, name: "Feature",  color: "#6366f1")
docs_label    = Label.create!(project: website, name: "Docs",     color: "#8b5cf6")
design_label  = Label.create!(project: website, name: "Design",   color: "#ec4899")
chore_label   = Label.create!(project: website, name: "Chore",    color: "#6b7280")

# Tasks
task1 = Task.create!(
  project:    website,
  column:     web_backlog,
  creator:    alice,
  title:      "Redesign homepage hero section",
  description: "Create a compelling above-the-fold experience that communicates our value proposition.",
  priority:   :high,
  due_date:   2.weeks.from_now
)
Tagging.create!(label: design_label, taggable: task1)
Tagging.create!(label: feature_label, taggable: task1)
TaskAssignment.create!(task: task1, user: carol)

task2 = Task.create!(
  project:    website,
  column:     web_in_progress,
  creator:    bob,
  title:      "Fix navigation menu on mobile",
  description: "The hamburger menu doesn't open on iOS Safari.",
  priority:   :urgent,
  due_date:   3.days.from_now
)
Tagging.create!(label: bug_label, taggable: task2)
TaskAssignment.create!(task: task2, user: bob)

task3 = Task.create!(
  project:    website,
  column:     web_in_progress,
  creator:    alice,
  title:      "Write product page copy",
  description: "Update copy for the three main product tiers.",
  priority:   :medium
)
Tagging.create!(label: docs_label, taggable: task3)
TaskAssignment.create!(task: task3, user: carol)

task4 = Task.create!(
  project:    website,
  column:     web_review,
  creator:    bob,
  title:      "Set up Google Analytics 4",
  description: "Migrate from UA to GA4, configure conversion events.",
  priority:   :high
)
Tagging.create!(label: chore_label, taggable: task4)
TaskAssignment.create!(task: task4, user: alice)

task5 = Task.create!(
  project:    website,
  column:     web_done,
  creator:    alice,
  title:      "Create sitemap.xml",
  description: "Generate XML sitemap and submit to Google Search Console.",
  priority:   :low
)
Tagging.create!(label: chore_label, taggable: task5)

# Subtask
subtask1 = Task.create!(
  project:    website,
  column:     web_backlog,
  creator:    alice,
  title:      "Design hero animation",
  priority:   :medium,
  parent:     task1
)
Tagging.create!(label: design_label, taggable: subtask1)

# Comments
Comment.create!(task: task2, user: bob,   body: "Reproduced on iPhone 14 Pro. The click event fires but the menu div doesn't toggle visibility.")
Comment.create!(task: task2, user: alice, body: "Check if Tailwind's `hidden` class is conflicting with the Stimulus controller state.")
Comment.create!(task: task3, user: carol, body: "Draft copy is ready for review. Pasting into the design doc now.")

# Activity logs
ActivityLog.create!(trackable: task1, actor: alice, action: "created",  metadata: { title: task1.title })
ActivityLog.create!(trackable: task2, actor: bob,   action: "created",  metadata: { title: task2.title })
ActivityLog.create!(trackable: task2, actor: bob,   action: "moved",    metadata: { from: "Backlog", to: "In Progress" })
ActivityLog.create!(trackable: task4, actor: bob,   action: "moved",    metadata: { from: "In Progress", to: "In Review" })

# =============================================================================
# PROJECT 2: Acme Mobile App
# =============================================================================
puts "==> Creating Acme Mobile App project..."

mobile = Project.create!(
  organization: acme,
  name:         "Mobile App",
  key:          "MOB",
  description:  "Native iOS and Android app for customer portal",
  status:       :active
)

ProjectMember.create!(project: mobile, user: alice, role: :manager)
ProjectMember.create!(project: mobile, user: dave,  role: :member)

mob_board      = Board.create!(project: mobile, name: "Sprint Board")
mob_backlog    = Column.create!(board: mob_board, name: "Backlog",     color: "#94a3b8")
mob_in_progress = Column.create!(board: mob_board, name: "In Progress", color: "#3b82f6")
mob_done       = Column.create!(board: mob_board, name: "Done",        color: "#22c55e")

mob_bug     = Label.create!(project: mobile, name: "Bug",     color: "#ef4444")
mob_feature = Label.create!(project: mobile, name: "Feature", color: "#6366f1")
mob_ux      = Label.create!(project: mobile, name: "UX",      color: "#ec4899")

mob_task1 = Task.create!(
  project:    mobile,
  column:     mob_backlog,
  creator:    alice,
  title:      "Implement push notifications",
  description: "Use Firebase Cloud Messaging for both iOS and Android.",
  priority:   :high,
  due_date:   3.weeks.from_now
)
Tagging.create!(label: mob_feature, taggable: mob_task1)
TaskAssignment.create!(task: mob_task1, user: dave)

mob_task2 = Task.create!(
  project:    mobile,
  column:     mob_in_progress,
  creator:    dave,
  title:      "Fix login screen layout on small screens",
  description: "Elements overflow viewport on 320px width devices.",
  priority:   :medium
)
Tagging.create!(label: mob_bug, taggable: mob_task2)
Tagging.create!(label: mob_ux, taggable: mob_task2)
TaskAssignment.create!(task: mob_task2, user: dave)

ActivityLog.create!(trackable: mob_task1, actor: alice, action: "created", metadata: { title: mob_task1.title })

# =============================================================================
# ORGANIZATION 2: Pixel Studio
# =============================================================================
puts "==> Creating Pixel Studio organization..."

pixel = Organization.create!(
  name:        "Pixel Studio",
  description: "A design-first product studio"
)

Membership.create!(user: alice, organization: pixel, role: :owner)
Membership.create!(user: eve,   organization: pixel, role: :admin)
Membership.create!(user: carol, organization: pixel, role: :member)

puts "  Slug auto-generated: #{pixel.slug}"

# =============================================================================
# PROJECT 3: Pixel Dashboard
# =============================================================================
puts "==> Creating Pixel Dashboard project..."

dashboard_proj = Project.create!(
  organization: pixel,
  name:         "Analytics Dashboard",
  key:          "DASH",
  description:  "Real-time analytics platform for clients",
  status:       :active
)

ProjectMember.create!(project: dashboard_proj, user: alice, role: :manager)
ProjectMember.create!(project: dashboard_proj, user: eve,   role: :manager)
ProjectMember.create!(project: dashboard_proj, user: carol, role: :member)

dash_board      = Board.create!(project: dashboard_proj, name: "Main Board")
dash_todo       = Column.create!(board: dash_board, name: "Todo",        color: "#94a3b8")
dash_in_progress = Column.create!(board: dash_board, name: "In Progress", color: "#3b82f6")
dash_review     = Column.create!(board: dash_board, name: "Review",      color: "#f59e0b")
dash_done       = Column.create!(board: dash_board, name: "Done",        color: "#22c55e")

dash_feature  = Label.create!(project: dashboard_proj, name: "Feature",    color: "#6366f1")
dash_bug      = Label.create!(project: dashboard_proj, name: "Bug",        color: "#ef4444")
dash_perf     = Label.create!(project: dashboard_proj, name: "Performance", color: "#f97316")
dash_design   = Label.create!(project: dashboard_proj, name: "Design",     color: "#ec4899")

dash_task1 = Task.create!(
  project:     dashboard_proj,
  column:      dash_todo,
  creator:     alice,
  title:       "Build chart component library",
  description: "Implement reusable Line, Bar, and Pie chart components using D3.js.",
  priority:    :high,
  due_date:    1.month.from_now
)
Tagging.create!(label: dash_feature, taggable: dash_task1)
Tagging.create!(label: dash_design, taggable: dash_task1)
TaskAssignment.create!(task: dash_task1, user: eve)

dash_task2 = Task.create!(
  project:     dashboard_proj,
  column:      dash_in_progress,
  creator:     eve,
  title:       "Optimize database query performance",
  description: "Several dashboard queries are taking >2s. Add proper indexes and query optimization.",
  priority:    :urgent,
  due_date:    1.week.from_now
)
Tagging.create!(label: dash_perf, taggable: dash_task2)
TaskAssignment.create!(task: dash_task2, user: alice)
TaskAssignment.create!(task: dash_task2, user: eve)

dash_task3 = Task.create!(
  project:     dashboard_proj,
  column:      dash_review,
  creator:     carol,
  title:       "Date range picker component",
  description: "Allow users to select custom date ranges for all dashboard widgets.",
  priority:    :medium
)
Tagging.create!(label: dash_feature, taggable: dash_task3)
TaskAssignment.create!(task: dash_task3, user: carol)

Comment.create!(task: dash_task2, user: eve,   body: "Found the culprit: missing index on events.created_at. Adding that now.")
Comment.create!(task: dash_task2, user: alice, body: "Also consider adding a composite index on (user_id, created_at) for the user-level queries.")
Comment.create!(task: dash_task3, user: carol, body: "Using flatpickr for the date picker — lightweight and accessible.")

ActivityLog.create!(trackable: dash_task1, actor: alice, action: "created",  metadata: { title: dash_task1.title })
ActivityLog.create!(trackable: dash_task2, actor: eve,   action: "created",  metadata: { title: dash_task2.title })
ActivityLog.create!(trackable: dash_task2, actor: alice, action: "assigned", metadata: { assignee: alice.name })

# Notifications
Notification.create!(
  user:       alice,
  actor:      eve,
  notifiable: dash_task2,
  action:     "assigned"
)
Notification.create!(
  user:       eve,
  actor:      alice,
  notifiable: dash_task2,
  action:     "commented"
)

# =============================================================================
# Summary
# =============================================================================
puts ""
puts "✓ Seed complete!"
puts "  Users:         #{User.count}"
puts "  Organizations: #{Organization.count}"
puts "  Projects:      #{Project.count}"
puts "  Boards:        #{Board.count}"
puts "  Columns:       #{Column.count}"
puts "  Tasks:         #{Task.count}"
puts "  Comments:      #{Comment.count}"
puts "  Labels:        #{Label.count}"
puts "  Activity logs: #{ActivityLog.count}"
puts "  Notifications: #{Notification.count}"
puts ""
puts "Login with: alice@example.com / password123"
