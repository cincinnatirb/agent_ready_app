require 'rails_helper'

RSpec.describe Workflow do
  before(:each) do
    described_class.instance_variable_set(:@workflows, nil)
  end

  let(:test_workflow) do
    described_class.new(
      id: 'test_workflow',
      name: 'Test Workflow',
      description: 'A test workflow',
      schema_class: 'ParcelEntrySchema',
      trigger_phrases: ['test', 'workflow test'],
      input_instructions: 'Test instructions',
      output_path: 'test_path'
    )
  end

  describe 'attributes' do
    it 'has expected attributes' do
      expect(test_workflow).to respond_to(:id)
      expect(test_workflow).to respond_to(:name)
      expect(test_workflow).to respond_to(:description)
      expect(test_workflow).to respond_to(:schema_class)
      expect(test_workflow).to respond_to(:trigger_phrases)
      expect(test_workflow).to respond_to(:input_instructions)
      expect(test_workflow).to respond_to(:output_path)
    end

    it 'initializes with given attributes' do
      expect(test_workflow.id).to eq('test_workflow')
      expect(test_workflow.name).to eq('Test Workflow')
      expect(test_workflow.description).to eq('A test workflow')
      expect(test_workflow.schema_class).to eq('ParcelEntrySchema')
      expect(test_workflow.trigger_phrases).to eq(['test', 'workflow test'])
      expect(test_workflow.input_instructions).to eq('Test instructions')
      expect(test_workflow.output_path).to eq('test_path')
    end

    it 'initializes trigger_phrases as an empty array by default' do
      workflow = described_class.new
      expect(workflow.trigger_phrases).to eq([])
    end
  end

  describe '#schema' do
    it 'returns the schema from the schema class' do
      schema_class = class_double('ParcelEntrySchema')
      schema_data = { type: 'object' }
      allow(schema_class).to receive(:schema).and_return(schema_data)
      allow(test_workflow).to receive(:schema_class).and_return('ParcelEntrySchema')
      allow(ParcelEntrySchema).to receive(:schema).and_return(schema_data)

      expect(test_workflow.schema).to eq(schema_data)
    end
  end

  describe '.all' do
    it 'returns an empty array when no workflows are registered' do
      expect(described_class.all).to eq([])
    end

    it 'returns all registered workflows' do
      described_class.register(test_workflow)
      expect(described_class.all).to include(test_workflow)
    end
  end

  describe '.register' do
    it 'adds a workflow to the collection' do
      expect {
        described_class.register(test_workflow)
      }.to change { described_class.all.count }.by(1)

      expect(described_class.all).to include(test_workflow)
    end
  end

  describe '.find_by_id' do
    before do
      described_class.register(test_workflow)
    end

    it 'returns the workflow with the matching id' do
      expect(described_class.find_by_id('test_workflow')).to eq(test_workflow)
    end

    it 'returns nil if no workflow has the given id' do
      expect(described_class.find_by_id('nonexistent')).to be_nil
    end
  end

  describe '.find_for_phrase' do
    before do
      described_class.register(test_workflow)
    end

    it 'returns the workflow that matches a phrase exactly' do
      expect(described_class.find_for_phrase('test')).to eq(test_workflow)
    end

    it 'returns the workflow that contains a phrase' do
      expect(described_class.find_for_phrase('this is a test phrase')).to eq(test_workflow)
    end

    it 'is case insensitive' do
      expect(described_class.find_for_phrase('TEST')).to eq(test_workflow)
      expect(described_class.find_for_phrase('This is a TEST phrase')).to eq(test_workflow)
    end

    it 'returns nil if no workflow matches the phrase' do
      expect(described_class.find_for_phrase('nonexistent')).to be_nil
    end

    context 'with multiple workflows' do
      let(:second_workflow) do
        described_class.new(
          id: 'second_workflow',
          name: 'Second Workflow',
          trigger_phrases: ['second workflow', 'another test workflow']
        )
      end

      before do
        described_class.register(second_workflow)
      end

      it 'returns the first workflow that matches' do
        expect(described_class.find_for_phrase('another test')).to eq(test_workflow)
      end
    end
  end
end