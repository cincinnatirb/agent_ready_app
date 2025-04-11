require 'rails_helper'

RSpec.describe "Chat", type: :request do
  let(:llm_service) { instance_double(LlmService) }
  let(:test_workflow) do
    Workflow.new(
      id: 'add_parcel',
      name: 'Add Parcel',
      description: 'Add a new parcel',
      input_instructions: 'Please provide an address'
    )
  end

  before do
    Workflow.register(test_workflow)
    allow(LlmService).to receive(:new).and_return(llm_service)
  end

  describe "GET /chat" do
    it "renders the chat index page" do
      get chat_index_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /chat/message" do
    let(:user_message) { "I want to add a parcel" }
    let(:workflow_id) { "add_parcel" }

    before do
      allow(llm_service).to receive(:identify_workflow).and_return(workflow_id)
    end

    context "when no active workflow" do
      it "adds the workflow instructions to the chat history" do
        post chat_message_path, params: { message: user_message }

        expect(assigns(:chat_history).last).to include(
          role: 'assistant',
          content: "I can help you with that. #{test_workflow.input_instructions}"
        )
      end

      it "handles case when no workflow is identified" do
        allow(llm_service).to receive(:identify_workflow).and_return(nil)

        post chat_message_path, params: { message: "random message" }

        expect(assigns(:chat_history).last).to include(
          role: 'assistant',
          content: "I'm here to help you with property management. You can ask me to add a parcel, for example."
        )
      end
    end
  end

  describe "POST /chat/clear" do
    it "clears chat history and active workflow" do
      post chat_clear_path

      expect(response).to redirect_to(chat_index_path)
      expect(flash[:notice]).to eq("Chat history cleared")
    end
  end
end
