class LlmService
  def initialize
    @client = OpenAI::Client.new(
      access_token: ENV["OPENAI_API_KEY"]
    )
  end

  def chat_with_structured_output(prompt, json_schema)
    response = @client.chat(
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
    )

    # Extract the response content
    content = response.dig("choices", 0, "message", "content")
    if content
      {
        structured_output: JSON.parse(content),
        chat_response: content
      }
    else
      raise "Invalid response format from OpenAI"
    end
  rescue OpenAI::Error => e
    Rails.logger.error("OpenAI API Error: #{e.message}")
    raise
  end

  def identify_workflow(user_message)
    workflow_descriptions = Workflow.all.map do |workflow|
      "ID: #{workflow.id}, Name: #{workflow.name}, Description: #{workflow.description}"
    end.join("\n")

    prompt = <<~PROMPT
      You are an assistant that helps identify the most appropriate workflow for a user request.

      Available workflows:
      #{workflow_descriptions}

      Based on the user's message, determine which workflow they are trying to use, if any.
      If a workflow is identified, respond with just the ID of the workflow.
      If no workflow is identified, respond with "none".

      User message: "#{user_message}"
    PROMPT

    response = @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are a helpful assistant." },
          { role: "user", content: prompt }
        ],
        temperature: 0.3
      }
    )

    content = response.dig("choices", 0, "message", "content").strip

    if content.downcase == "none"
      nil
    else
      content
    end
  end

  def process_workflow(workflow, user_input)
    # Read auditor data file
    auditor_data = File.read(Rails.root.join("auditor_data.txt"))

    prompt = <<~PROMPT.squish
      "You must look up the actual parcel information from authoritative sources like the county auditor's website or property records. Do not make up or guess information. If you cannot find the structure information with confidence, simply return the address information the user passed in.

      Here is some auditor data that may be helpful. If the address matches something in this data, prefer this information over other sources:

      #{auditor_data}

      The address to look up is: #{user_input}
    PROMPT

    chat_with_structured_output(prompt, workflow.schema)
  end
end
