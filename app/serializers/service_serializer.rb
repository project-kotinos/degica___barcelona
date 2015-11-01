class ServiceSerializer < ActiveModel::Serializer
  attributes :name, :public, :command, :cpu, :memory, :endpoint, :status, :port_mappings, :running_count, :pending_count, :desired_count

  belongs_to :heritage

  def port_mappings
    object.port_mappings.map do |pm|
      {
        container_port: pm.container_port,
        lb_port: pm.lb_port,
        protocol: pm.protocol
      }
    end
  end
end
