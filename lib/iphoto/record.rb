module Iphoto
  module Record
    DateProc = Proc.new { |p| Time.at(p.to_f + 978307200) }

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, Iphoto::Record::InstanceMethods)
    end

    module InstanceMethods
      def update_from_plist(plist)
        update_attribute_hash = {}

        self.class.mapping.each_pair do |plist_key, record_attribute|
          if self.class.proc.include?(record_attribute)
            update_attribute_hash[record_attribute] = self.class.proc[record_attribute].call(plist[plist_key])
          else
            update_attribute_hash[record_attribute] = plist[plist_key]
          end
        end

        self.attributes = update_attribute_hash

        if !self.changes.blank? # TODO meta_mod_date voodoo happening here
          self.save
          true
        else
          false
        end
      end
    end

    module ClassMethods
      attr_accessor :mapping, :proc

      def inherited(subclass)
        super(subclass)
        subclass.mapping = @mapping
        subclass.proc = @proc
      end

      def from_plist(id, plist, additional_attributes = {}) # OPTIMIZE don't use eval
        @mapping ||= Hash.new
        @proc ||= Hash.new

        self.create(additional_attributes) do |r|
          r.id = id
          @mapping.each_pair do |plist_key, record_attribute|

            if @proc.include?(record_attribute)
              eval "r.#{record_attribute} = @proc[record_attribute].call(plist[plist_key])", binding
            else
              eval "r.#{record_attribute} = plist[plist_key]", binding
            end
          end
        end
      end

      # def from_plist!(id, plist)
      #   record = from_plist(id, plist)
      #   record.save!
      #   record
      # end

      def set_plist_mapping(map = {})
        @mapping ||= Hash.new
        @mapping = @mapping.merge(map)
      end

      def set_plist_proc(record_attribute, proc)
        @proc ||= Hash.new
        @proc[record_attribute] = proc
      end
    end
  end
end
