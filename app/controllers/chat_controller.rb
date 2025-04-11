class ChatController < ApplicationController
  def index
    @chat_history = session[:chat_history] || []
  end

  def message
    @chat_history = session[:chat_history] || []

    @chat_history << { role: 'user', content: params[:message] }

    process_user_message(params[:message])

    session[:chat_history] = @chat_history

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chat_index_path }
    end
  end

  def clear
    session[:chat_history] = []
    session[:active_workflow] = nil
    redirect_to chat_index_path, notice: "Chat history cleared"
  end

  private

  def process_user_message(message)
    llm_service = LlmService.new

    # Check if there's an active workflow
    active_workflow_id = session[:active_workflow]

    if active_workflow_id
      # Continue with the active workflow
      workflow = Workflow.find_by_id(active_workflow_id)
      result = llm_service.process_workflow(workflow, message)

      # Save result to database
      parcel = Parcel.new(result[:structured_output]["parcel"])
      structures = result[:structured_output]["structures"].map { |s| Structure.new(s.merge(parcel: parcel)) }

      if parcel.valid? && structures.all?(&:valid?)
        parcel.save
        structures.each do |structure|
          structure.parcel = parcel
          structure.save
        end

        # Add assistant message to chat history
        @chat_history << {
          role: 'assistant',
          content: "I've created a parcel based on the address you provided. You can review it here:",
          action: {
            type: 'link',
            text: 'Review Parcel',
            url: Rails.application.routes.url_helpers.review_parcel_path(parcel)
          }
        }

        # Clear the active workflow
        session[:active_workflow] = nil
      else
        @chat_history << {
          role: 'assistant',
          content: "I'm sorry, but I couldn't create the parcel with the information provided. Could you please provide more details?"
        }
      end
    else
      # Identify the workflow
      workflow_id = llm_service.identify_workflow(message)

      if workflow_id
        workflow = Workflow.find_by_id(workflow_id)

        if workflow
          # Set the active workflow
          session[:active_workflow] = workflow.id

          # Add assistant message to chat history
          @chat_history << {
            role: 'assistant',
            content: "I can help you with that. #{workflow.input_instructions}"
          }
        else
          # Workflow not found
          @chat_history << {
            role: 'assistant',
            content: "I'm sorry, but I couldn't identify a workflow to help with your request."
          }
        end
      else
        # No workflow identified, provide a generic response
        @chat_history << {
          role: 'assistant',
          content: "I'm here to help you with property management. You can ask me to add a parcel, for example."
        }
      end
    end
  end
end
