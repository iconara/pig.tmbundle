require 'spec/rake/spectask'


task :default => :spec

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts << '--color' << '--format' << 'specdoc'
  spec.spec_files = FileList['spec/*_spec.rb']
end