Sequel.migration do
    change do
        schema = Sequel[:auth]
        create_schema(schema)

        create_table(schema[:users]) do
            primary_key :id, type: :uuid
            String :username, null: false, unique: true
            String :email, null: false, unique: true
            String :name, null: false
            String :pass_salt, null: false
            String :pass_hash, null: false
            Boolean :superuser, default: false

            index Sequel.function(:lower, :username), :unique => true
            index Sequel.function(:lower, :email), :unique => true
        end

        create_table(schema[:tokens]) do
            primary_key :id, type: :uuid
            foreign_key :user_id, schema[:users], on_delete: :cascade, type: :uuid
            DateTime :leased_time, null: false
            DateTime :expire_time, null: false
        end
    end
end