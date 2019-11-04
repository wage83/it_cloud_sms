Gem::Specification.new do |s|
  s.name          = 'it_cloud_sms'
  s.version       = '0.3'
  s.date          = '2015-06-16'
  s.summary       = 'IT Cloud Services Colombia send SMS HTTP gateway'
  s.description   = 'A gateway to send SMS using HTTP POST, through IT Cloud Services Colombia, written in ruby'
  s.files         = ['lib/it_cloud_sms.rb']
  s.require_path  ='lib'
  s.author        = 'Angel García Pérez'
  s.email         = 'wage83@gmail.com'
  s.homepage      = 'http://www.itcloudcolombia.com/?page_id=23'
  s.has_rdoc      = false

  s.add_dependency('global_phone', '~>1.0.1')
  s.add_dependency('activesupport')
  s.add_development_dependency('rake', '~> 0.8.7')
  s.add_development_dependency('rspec', '>1.3.1')
  s.add_development_dependency('json')
end
