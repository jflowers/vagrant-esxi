
require 'esxi/util/ssh'

module VagrantPlugins
  module ESXi
    module Action
      class IsCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          if env[:machine].id.nil?
            env[:result] = false
          else
            config = env[:machine].provider_config

            ssh_util = VagrantPlugins::ESXi::Util::SSH
            env[:result] = ssh_util.esxi_host.communicate.execute("vim-cmd vmsvc/get.summary #{env[:machine].id}", :error_check => false)
          end

          @app.call env
        end
      end
    end
  end
end
