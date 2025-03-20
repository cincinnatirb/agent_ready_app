class LlmService
  def initialize
    @client = OpenAI::Client.new(
      access_token: ENV["OPENAI_API_KEY"]
    )
  end

  def chat_with_structured_output(prompt, json_schema)
    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
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
    puts "Response: #{response}"

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
end
