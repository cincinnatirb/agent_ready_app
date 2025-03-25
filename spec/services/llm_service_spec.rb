require 'rails_helper'

RSpec.describe LlmService do
  let(:service) { described_class.new }
  let(:mock_client) { instance_double(OpenAI::Client) }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(mock_client)
  end

  describe '#chat_with_structured_output' do
    let(:prompt) { "Test prompt" }
    let(:json_schema) { { type: "object" } }
    let(:mock_response) do
      {
        "choices" => [
          {
            "message" => {
              "content" => '{"test": "data"}'
            }
          }
        ]
      }
    end

    before do
      allow(mock_client).to receive(:chat).and_return(mock_response)
    end

    it 'sends correct parameters to OpenAI' do
      expected_params = {
        parameters: {
          model: "gpt-4o",
          messages: [
            {
              role: "system",
              content: "You are a helpful assistant that provides responses in a structured format. Follow the provided JSON schema exactly."
            },
            {
              role: "user",
              content: prompt
            }
          ],
          response_format: {
            type: "json_schema",
            json_schema: {
              name: "parcel_data",
              schema: json_schema
            }
          },
          temperature: 0.7
        }
      }

      service.chat_with_structured_output(prompt, json_schema)
      expect(mock_client).to have_received(:chat).with(expected_params)
    end

    it 'returns structured output and chat response' do
      result = service.chat_with_structured_output(prompt, json_schema)
      expect(result).to eq({
        structured_output: { "test" => "data" },
        chat_response: '{"test": "data"}'
      })
    end

    context 'when OpenAI returns invalid response' do
      let(:mock_response) { { "choices" => [] } }

      it 'raises an error' do
        expect {
          service.chat_with_structured_output(prompt, json_schema)
        }.to raise_error("Invalid response format from OpenAI")
      end
    end

    context 'when OpenAI raises an error' do
      before do
        allow(mock_client).to receive(:chat).and_raise(OpenAI::Error.new("API Error"))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs and re-raises the error' do
        expect {
          service.chat_with_structured_output(prompt, json_schema)
        }.to raise_error(OpenAI::Error)
        expect(Rails.logger).to have_received(:error).with("OpenAI API Error: API Error")
      end
    end
  end

  describe '#identify_workflow' do
    let(:test_workflow) do
      Workflow.new(
        id: 'test_workflow',
        name: 'Test Workflow',
        description: 'A test workflow'
      )
    end

    let(:mock_response) do
      {
        "choices" => [
          {
            "message" => {
              "content" => "test_workflow"
            }
          }
        ]
      }
    end

    before do
      Workflow.register(test_workflow)
      allow(mock_client).to receive(:chat).and_return(mock_response)
    end

    it 'sends workflow descriptions to OpenAI' do
      service.identify_workflow("test message")

      expect(mock_client).to have_received(:chat) do |params|
        expect(params[:parameters][:messages][1][:content]).to include(
          "ID: test_workflow",
          "Name: Test Workflow",
          "Description: A test workflow"
        )
      end
    end

    it 'returns workflow ID when workflow is identified' do
      expect(service.identify_workflow("test message")).to eq("test_workflow")
    end

    context 'when no workflow is identified' do
      let(:mock_response) do
        {
          "choices" => [
            {
              "message" => {
                "content" => "none"
              }
            }
          ]
        }
      end

      it 'returns nil' do
        expect(service.identify_workflow("invalid message")).to be_nil
      end
    end
  end

  describe '#process_workflow' do
    let(:workflow) do
      instance_double(
        Workflow,
        schema: { type: "object" }
      )
    end
    let(:auditor_data) { "Test auditor data" }
    let(:mock_response) do
      {
        "choices" => [
          {
            "message" => {
              "content" => '{"test": "data"}'
            }
          }
        ]
      }
    end

    before do
      allow(File).to receive(:read).and_return(auditor_data)
      allow(mock_client).to receive(:chat).and_return(mock_response)
    end

    it 'reads auditor data file' do
      service.process_workflow(workflow, "123 Test St")
      expect(File).to have_received(:read).with(Rails.root.join("auditor_data.txt"))
    end

    it 'processes workflow with correct data' do
      result = service.process_workflow(workflow, "123 Test St")
      expect(result).to eq({
        structured_output: { "test" => "data" },
        chat_response: '{"test": "data"}'
      })
    end

    it 'includes address and auditor data in prompt' do
      service.process_workflow(workflow, "123 Test St")

      expect(mock_client).to have_received(:chat) do |params|
        prompt = params[:parameters][:messages][1][:content]
        expect(prompt).to include("123 Test St")
        expect(prompt).to include("Test auditor data")
      end
    end
  end
end
