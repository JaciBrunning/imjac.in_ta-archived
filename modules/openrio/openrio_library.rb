require 'db/db'

module OpenRIO
    class DB
        @db = Database::connect
        SCHEMA = Sequel[:openrio]

        # Create Tables
        @db.create_table? SCHEMA[:telemetry_reports] do
            primary_key :id
            uuid :uuid, null: false

            DateTime :time
            String :os, size: 50
            String :os_family, size: 50
            String :os_version, size: 50
            String :os_native, size: 50

            String :gradle, size: 20
            String :gradlerio, size: 20
        end

        @db.create_table? SCHEMA[:telemetry_plugins] do
            primary_key :id
            String :plugin, unique: true, size: 100
        end

        @db.create_table? SCHEMA[:telemetry_report_plugins] do
            foreign_key :report_id, SCHEMA[:telemetry_reports], on_delete: :cascade
            foreign_key :plugin_id, SCHEMA[:telemetry_plugins], on_delete: :cascade
            primary_key [:report_id, :plugin_id]
        end

        @db.create_table? SCHEMA[:telemetry_deps] do
            primary_key :id
            String :group, null: true, size: 100
            String :name, size: 50
            unique [:group, :name]
        end

        @db.create_table? SCHEMA[:telemetry_report_deps] do
            primary_key :id
            foreign_key :report_id, SCHEMA[:telemetry_reports], on_delete: :cascade
            foreign_key :dep_id, SCHEMA[:telemetry_deps], on_delete: :cascade
            String :config, size: 50
            String :version, null: true, size: 50
        end

        @db.create_table? SCHEMA[:telemetry_wpi] do
            primary_key :id
            String :name, unique: true, size: 50
        end

        @db.create_table? SCHEMA[:telemetry_report_wpi] do
            foreign_key :report_id, SCHEMA[:telemetry_reports], on_delete: :cascade
            foreign_key :wpi_id, SCHEMA[:telemetry_wpi], on_delete: :cascade
            String :version, size: 50
            primary_key [:report_id, :wpi_id]
        end

        @db.create_table? SCHEMA[:telemetry_teams] do
            foreign_key :report_id, SCHEMA[:telemetry_reports], on_delete: :cascade
            String :team, size: 16
            primary_key [:report_id, :team]
        end

        # Models
        class TelemetryReport < Sequel::Model(@db[SCHEMA[:telemetry_reports]])
        end

        class TelemetryPlugin < Sequel::Model(@db[SCHEMA[:telemetry_plugins]])
        end

        class TelemetryPluginLink < Sequel::Model(@db[SCHEMA[:telemetry_report_plugins]])
            unrestrict_primary_key
            many_to_one :report, class: TelemetryReport
            many_to_one :plugin, class: TelemetryPlugin
        end

        class TelemetryDep < Sequel::Model(@db[SCHEMA[:telemetry_deps]])
        end

        class TelemetryDepLink < Sequel::Model(@db[SCHEMA[:telemetry_report_deps]])
            unrestrict_primary_key
            many_to_one :report, class: TelemetryReport
            many_to_one :dep, class: TelemetryDep
        end

        class TelemetryWPI < Sequel::Model(@db[SCHEMA[:telemetry_wpi]])
        end

        class TelemetryWPILink < Sequel::Model(@db[SCHEMA[:telemetry_report_wpi]])
            unrestrict_primary_key
            many_to_one :report, class: TelemetryReport
            many_to_one :wpi, class: TelemetryWPI
        end

        class TelemetryTeam < Sequel::Model(@db[SCHEMA[:telemetry_teams]])
            unrestrict_primary_key
            many_to_one :report, class: TelemetryReport
        end

        class << self
            def db
                @db
            end

            def parse_dep dep
                spl = dep.split(':')
                return { version: nil, name: spl.first(), group: nil } if spl.size == 1
                return { version: spl.last(), name: spl[1], group: spl.first() }
            end

            def report report
                return if ['os', 'uuid', 'gradle', 'plugins', 'classpath', 'deploy', 'dependencies', 'wpi'].map { |x| report[x] }.select { |x| x.nil? }.size > 0
                grio_plugin = report['classpath'].select { |x| x.include?('GradleRIO') }
                return if grio_plugin.nil? || grio_plugin.size == 0
                grio_version = parse_dep(grio_plugin.first())[:version]
                os = report['os']

                @db.transaction do
                    telem_report = TelemetryReport.create(uuid: report['uuid'], time: DateTime.now(),
                                os: os['name'], os_family: os['family'], os_version: os['version'], os_native: os['nativePrefix'],
                                gradle: report['gradle'], gradlerio: grio_version)
                    
                    report['wpi'].each do |name, version|
                        telem_wpi = TelemetryWPI.find_or_create(name: name)
                        TelemetryWPILink.create(report: telem_report, wpi: telem_wpi, version: version)
                    end

                    report['plugins'].each do |plugin|
                        telem_plugin = TelemetryPlugin.find_or_create(plugin: plugin)
                        TelemetryPluginLink.create(report: telem_report, plugin: telem_plugin)
                    end
                    
                    report['dependencies']['pluginClasspath'] = report['classpath']
                    report['dependencies'].each do |config, deps|
                        (deps.map do |dep|
                            resolved = parse_dep(dep)
                            [TelemetryDep.find_or_create(group: resolved[:group], name: resolved[:name]), resolved[:version]]
                        end).each do |dep_arr|
                            TelemetryDepLink.create(version: dep_arr.last(), dep: dep_arr.first(), config: config, report: telem_report)
                        end
                    end

                    unless report['deploy']['targets'].nil?
                        report['deploy']['targets'].each do |name, target|
                            unless target['team'].nil?
                                TelemetryTeam.create(team: target['team'], report: telem_report)
                            end
                        end
                    end
                end
            end
        end
    end
end