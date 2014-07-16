require "vagrant"

module VagrantPlugins
  module ESXi
    class Config < Vagrant.plugin("2", :config)
      class << self
        attr_accessor :instance
      end
      attr_accessor :host
      attr_accessor :user
      attr_accessor :ssh_key_path
      attr_accessor :password
      attr_accessor :datastore

      def initialize
        super

        @ssh_key_path = File.expand_path('~/.ssh/id_rsa')
      end

      def finalize!
        super

        self.class.instance = self
      end

      def validate(machine)
        errors = _detected_errors

        errors << I18n.t("config.host") if host.nil?
        errors << I18n.t("config.user") if user.nil?
        errors << I18n.t("config.password") if password.nil?
        errors << I18n.t("config.datastore") if datastore.nil?

        { "esxi Provider" => errors }
      end
    end
  end
end
