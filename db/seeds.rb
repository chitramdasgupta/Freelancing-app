# frozen_string_literal: true

category_names = ['Web Design', 'Web Development', 'Content Writing', 'Project Management', 'SEO Service', 'Marketing',
                  'Business Analysis', 'Android Development', 'iOS Development', 'Technical Support', 'Graphic Design',
                  'UI/UX Design', 'Copywriting', 'Social Media Marketing', 'Email Marketing', 'Data Analysis',
                  'Game Development']

industry_names = ['Technology', 'Marketing and Advertising', 'Writing and Editing', 'Design', 'Management Consulting',
                  'Information Services', 'Computer Games', 'Education', 'Finance', 'Retail']

qualification_names = ['No formal education', 'High School', 'Diploma', 'Bachelor of Science', 'Bachelor of Arts',
                       'Bachelor of Commerce', 'Bachelor of Education', 'Bachelor of Technology', 'Master of Science',
                       'Master of Arts', 'Master of Commerce', 'Master of Education', 'Master of Technology', 'PhD',
                       'Post Doctorate']

skill_names = ['Javascript developer', 'Ruby developer', 'Elixir developer', 'Typescript developer',
               'Python developer', 'Android developer', 'Java developer', 'Graphic designer',
               'HTML/CSS developer', 'System admin', 'Data scientist', 'Technical writer']

category_names.each do |name|
  Category.create!(name:)
end

admin = User.new(username: 'admin', email: 'admin@email.com', password: '123456', password_confirmation: '123456',
                 role: 'admin', email_confirmed: true, confirmation_token: nil, status: 'approved')
admin.save

(1..15).each do |i|
  client = User.create!(username: "c#{i}", email: "c#{i}@email.com", password: '123456',
                        password_confirmation: '123456', role: 'client', industry: industry_names.sample,
                        email_confirmed: true, confirmation_token: nil, status: 'approved')

  rand(3..5).times do |j|
    project = client.projects.build(title: "Project #{j} for Client #{i}",
                                    description: 'lorem ipsum')

    project.categories << Category.all_categories.sample(rand(1..3))
    project.skills = skill_names.sample(rand(1..2))
    project.save!
  end
end

(1..35).each do |i|
  freelancer_visibility = rand(10) > 3 ? 'pub' : 'priv'
  freelancer = User.new(username: "f#{i}", email: "f#{i}@email.com", password: '123456',
                        password_confirmation: '123456', role: 'freelancer', email_confirmed: true,
                        qualification: qualification_names.sample, experience: rand(0..25),
                        industry: industry_names.sample, confirmation_token: nil, visibility: freelancer_visibility,
                        status: 'approved')

  freelancer.categories << Category.all_categories.sample(rand(1..4))
  freelancer.save!
end

User.where(role: 'freelancer').each do |freelancer|
  project = Project.all_projects.sample

  project.bids.create!(bid_description: 'lorem ipsum dolor', bid_amount: rand(10_000..25_000), user_id: freelancer.id)
end
