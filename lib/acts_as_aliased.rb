require 'active_record'

module ActsAsAliased
  def self.included(base)
    base.extend(ClassMethods)
  end

  class Alias < ActiveRecord::Base
    belongs_to :aliased, polymorphic: true
    attr_accessible :aliased, :name
  end

  module ClassMethods
    def acts_as_aliased options = {}
      has_many :aliases, as: :aliased, class_name: ::ActsAsAliased::Alias

      cattr_accessor :associations
      cattr_accessor :column
      self.associations = options[:associations] || []
      self.column       = options[:column]       || 'name'

      class_eval <<-EOV
        include ActsAsAliased::InstanceMethods

        def self.lookup(value)
          return nil if value.blank?
          self.send("find_by_#{column}", value) ||
          Alias.where(["aliased_type = ? AND name = ?", self.to_s, value]).first.try(:aliased)
        end
      EOV
    end
  end

  module InstanceMethods
    def to_alias! aliased
      raise "Cannot create alias for myself" if aliased == self
      self.class.transaction do

        # Move references to this instance from the provided associations to the
        # newly aliased one
        a = ::ActsAsAliased::Alias.create(aliased: aliased, name: self[column])
        associations.each do |association|
          klass = association.to_s.classify.constantize
          key   = self.class.to_s.foreign_key
          klass.where(key => id).update_all(key => aliased.id)
        end

        # Move references to this instance to the newly aliased one
        Alias.where("aliased_type = ? AND aliased_id = ?", self.class.to_s, self.id).update_all(aliased_id: aliased.id)

        # Poof!
        self.destroy
        return a
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include ActsAsAliased
end
