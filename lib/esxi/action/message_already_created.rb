require "i18n"
require 'esxi/util/ssh'

module VagrantPlugins
  module ESXi
    module Action
      class MessageAlreadyCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t("vagrant_esxi.vm_already_created")
          @app.call(env)
        end
      end
    end
  end
end
