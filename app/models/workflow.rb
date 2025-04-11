class Workflow
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :string
  attribute :name, :string
  attribute :description, :string
  attribute :schema_class, :string
  attribute :trigger_phrases, array: true, default: []
  attribute :input_instructions, :string
  attribute :output_path, :string

  def schema
    schema_class.constantize.schema
  end

  def self.all
    @workflows ||= []
  end

  def self.register(workflow)
    all << workflow
  end

  def self.find_by_id(id)
    all.find { |w| w.id == id }
  end

  def self.find_for_phrase(phrase)
    all.find do |workflow|
      workflow.trigger_phrases.any? do |trigger|
        phrase.downcase.include?(trigger.downcase)
      end
    end
  end
end
