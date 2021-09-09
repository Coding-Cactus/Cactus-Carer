# -*- encoding: utf-8 -*-
# stub: mongo 2.15.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mongo".freeze
  s.version = "2.15.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://jira.mongodb.org/projects/RUBY", "changelog_uri" => "https://github.com/mongodb/mongo-ruby-driver/releases", "documentation_uri" => "https://docs.mongodb.com/ruby-driver/", "homepage_uri" => "https://docs.mongodb.com/ruby-driver/", "source_code_uri" => "https://github.com/mongodb/mongo-ruby-driver" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tyler Brock".freeze, "Emily Stolfo".freeze, "Durran Jordan".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDRDCCAiygAwIBAgIBATANBgkqhkiG9w0BAQsFADAmMSQwIgYDVQQDDBtkcml2\nZXItcnVieS9EQz0xMGdlbi9EQz1jb20wHhcNMjEwMjA5MTQxOTU3WhcNMjIwMjA5\nMTQxOTU3WjAmMSQwIgYDVQQDDBtkcml2ZXItcnVieS9EQz0xMGdlbi9EQz1jb20w\nggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDRXUgGvH0ZtWwDPc2umdHw\nB+INNm6jNTRp8PMyUKxPzxaxX2OiBQk9gLC3zsK9ZmlZu4lNfpHVSCEPoiP/fhPg\nKyfq2xld3Qz0Pki5d5i0/r14343MTKiNiFulLlbbdlN0cXeEFNJHUycZnD2LOXwz\negYGHOl14FI8t5visIWtqRnLXXIlDsBHzmeEZjUZRGSgjC0R3RT/I+Fk5yUhn1w4\nrqFyAiW+cjjzmT7mmqT0jV6fd0JFHbKnSgt9iPijKSimBgUOsorHwOTMlTzwsy0d\nZT+al1RiT5zqlAJLxFHwmoYOxD/bSNtKsYl60ek0hK2mISBVy9BBmLvCgHDx5uSp\nAgMBAAGjfTB7MAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdDgQWBBRbd1mx\nfvSaVIwKI+tnEAYDW/B81zAgBgNVHREEGTAXgRVkcml2ZXItcnVieUAxMGdlbi5j\nb20wIAYDVR0SBBkwF4EVZHJpdmVyLXJ1YnlAMTBnZW4uY29tMA0GCSqGSIb3DQEB\nCwUAA4IBAQCYGRgQbtk+g+Nuwg15p8jb+8bJlwHFHkb8rkLn00OPXLk3uBhImOKZ\nmhwwr/8ZBkeE/PBDxkQjeua+NpqSaPr1lvXQaGpHxJzpR/BmSteeoF49jBu0dHaz\nMRghinst6ROS1qVRae0z+wkbnufpH/NxdCUufb639nAlZguT2rGqvM6VZCC8eSO9\nKfJA7/MEE+qQtiQgJaAUVRaGC8fLtmS555BPjNVITJs+BcGDYWh2clWuqlzjHOp3\nYoFhlyUEi7VLlqNH0H/JFttVZK6+qmLelkVNcIYVLeWOB4Lf4VxEiYGEK1ORxsrY\niyYKJJALWY1FAInGRIlvkN+B8o3yIhq1\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2021-07-14"
  s.description = "A Ruby driver for MongoDB".freeze
  s.executables = ["mongo_console".freeze]
  s.files = ["bin/mongo_console".freeze]
  s.homepage = "https://docs.mongodb.com/ruby-driver/".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Ruby driver for MongoDB".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bson>.freeze, ["< 5.0.0", ">= 4.8.2"])
    else
      s.add_dependency(%q<bson>.freeze, ["< 5.0.0", ">= 4.8.2"])
    end
  else
    s.add_dependency(%q<bson>.freeze, ["< 5.0.0", ">= 4.8.2"])
  end
end
