# frozen_string_literal: true

module Verse
  module Login
    class Role
      class Record < Verse::Model::Record::Base
        type "login/roles"

        field :name, type: String, primary: true

        field :title, type: String
        field :rights, type: Array
        field :description, type: String
      end

      class Repository < Verse::Model::InMemory::Repository
        class << self
          attr_accessor :no_description
        end

        self.no_description = "There is no description for this role"
        self.primary_key = "name"
        self.resource = "auth:roles"
        self.no_event = true

        def self.load
          data.clear

          repo = new(Verse::Auth::Context.new)

          # Get full path for the role definition template:
          full_path = File.expand_path(
            Config.role_definition_path,
            "."
          )

          template_full_path = File.expand_path(
            Config.role_definition_template_path,
            "."
          )


          Dir.glob(
            File.join(
              full_path, "**", "*.yml"
            )
          ).each do |file|
            next if file.start_with?(template_full_path)

            repo.load_role(
              YAML.safe_load(
                File.read(file),
                symbolize_names: true
              )
            )
          end
        end

        def find_template(file_name)
          @templates ||= {}

          return @templates[file_name] if @templates.key?(file_name)

          template_file = File.join(Config.role_definition_template_path, "#{file_name}.yml")

          raise "Template #{file_name} not found" unless File.exist?(template_file)

          template = YAML.safe_load(File.read(template_file))

          @templates[file_name] = template.fetch("resources", [])
        end

        # Fetch the template and unfold them
        # if any
        def unfold_rights(rights)
          rights.map{ |x|
            if x[0] == "$" # Special character to indicate a template path
              template_name = x[1..]
              find_template(template_name)
            else
              x
            end
          }.flatten
        end

        def load_role(role_hash)
          role_hash.each do |name, attribute|
            attribute[:name] = name
            attribute[:rights] = unfold_rights(attribute[:rights])
            attribute[:description] ||= self.class.no_description
            attribute[:title] ||= name

            create(**attribute)
          end
        end
      end
    end
  end
end
