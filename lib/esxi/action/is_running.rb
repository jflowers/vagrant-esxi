module VagrantPlugins
  module ESXi
    module Action
      class IsRunning
        
        def initialize(app, env)
          @app = app
        end

        def call(env)
          raise "I don't think this is used, if this exception is raise we should consider using the get_state class instead..."
          @app.call env
        end
      end
    end
  end
end
