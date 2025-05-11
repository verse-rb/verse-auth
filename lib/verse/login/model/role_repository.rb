# frozen_string_literal: true

module Verse
  module Login
    class RoleRepository < Verse::Model::InMemory::Repository
      class << self
        attr_accessor :no_description
      end

      self.no_description = "There is no description for this role"
      self.primary_key = "name"
      self.resource = "auth:roles"

      Config.role_definition_template_path
      def self.load
        data.clear

        repo = new(Verse::Auth::Context.new)

        role_definition_template_path = File.expand_path(
          Config.role_definition_template_path,
          Config.role_definition_path
        )

        Dir.glob(
          File.join(
            Config.role_definition_path, "**", "*.yml"
          )
        ).each do |file|
          next if file.start_with?(role_definition_template_path)

          repo.load_role(
            YAML.safe_load(
              File.read(file)
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
        no_event do
          role_hash.each do |name, attribute|
            create(
              {
                name:,
                title: attribute.fetch("title", name),
                description: attribute.fetch(
                  "description", self.class.no_description
                ),
                scopes: attribute.fetch("scopes", []),
                rights: unfold_rights(attribute["rights"]),
                # Append the other attributes
                **attribute.except(
                  "title", "description", "scopes", "rights"
                ).transform_keys(&:to_sym)
              }
            )
          end
        end
      end
    end
  end
end
