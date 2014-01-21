Gem::Specification.new do |s|
  s.name = 'stella_gcm_xmpp'
  s.version = '0.0.1beta'
  s.date = '2014-01-21'
  s.summary = ''
  s.description = ''
  s.authors = ['Haru']
  s.email = 'aqure84@naver.com'
  s.files = ["lib/stella_gcm_xmpp.rb"]
  s.homepage = 'http://www.forelf.com'
  s.add_dependency("xmpp4r", '~> 0')
  s.add_dependency("active_support", '~>= 3.2')
  s.required_ruby_version     = ">= 1.9"
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "stella_gcm_xmpp"
end