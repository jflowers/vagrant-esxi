module VagrantPlugins
  module ESXi
    module Action
      class IsCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)

          config = env[:machine].provider_config

          ssh_util = VagrantPlugins::ESXi::Util::SSH
          env[:result] = ssh_util.esxi_host.communicate.execute("vim-cmd vmsvc/get.summary #{env[:machine].id}")

          @app.call env
        end
      end
    end
  end
end
