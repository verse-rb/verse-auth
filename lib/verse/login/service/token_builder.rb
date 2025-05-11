# frozen_string_literal: true

module Verse
  module Login
    class TokenBuilder
      def build(_user, role, env: nil, nonce: nil)
        active_roles = account.active_roles

        # If no active roles for the given account, raise error
        if active_roles.empty?
          raise Verse::Error::Authorization, "No role active"
        end

        # Select active roles which are matching the role name
        # we try to login into.
        # if role_name is nil, it will returns empty
        roles_array = active_roles.select { |x| x.name == role_name }

        # case the role is not found
        if roles_array.empty?
          # We check the last role used that is active
          # else we use the first active role
          last_role_name = system_account_logins.last_login_role_for(account.id)

          active_role =
            if active_roles.find { |x| x.name == last_role_name }
              last_role_name
            else
              active_roles.first&.name
            end

          return build_tokens(account, active_role, nonce:, ip:)
        end

        # Fetch labels from the role repository
        role = system_roles.find_by({ name: role_name })

        unless role
          raise Verse::Error::ValidationFailed, "Cannot find role #{role_name}"
        end

        scope = merge_roles(roles_array)

        exp = Time.now.to_i + Settings["auth_token.lifetime"]

        person = account&.person

        # encode the auth_token
        auth_token = Verse::Http::Auth::Token.encode(
          {
            id: account.id,
            name: person&.name,
            email: account.email,
            person_id: person&.id,
            labels: role.labels
          }.compact,
          role_name,
          scope,
          exp:
        )

        # generate a refresh token
        refresh_token = create_refresh_token(account, role_name, ip:, nonce:)

        roles_data = system_roles.index({ name: active_roles.map(&:name) })

        active_roles_data =
          active_roles.map do |r|
            role_data = roles_data.find { |x| x.name == r.name }
            {
              name: r.name,
              description: role_data.description,
              scopes: r.scopes
            }
          end.sort_by { |x| x[:name] }

        Model::AccountAuthRecord.new(
          {
            id: account.id,
            person_id: person&.id,
            organizational_unit: person&.organizational_unit,
            email: account.email,
            name: person&.name,
            picture_url: person&.picture_url,
            role_name: role.name,
            role_labels: role.labels,
            scope:,
            roles: active_roles_data,
            role_rights: role.rights,
            auth_type: account.auth_type,
            auth_token:,
            refresh_token:,
            exp:
          }
        )
      end
    end
  end
end
