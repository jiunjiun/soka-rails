# frozen_string_literal: true

module Soka
  module Rails
    # Test helpers for RSpec tests with Soka agents and tools
    module TestHelpers
      extend ActiveSupport::Concern

      included do
        let(:mock_llm) { instance_double('Soka::LLM') }
      end

      # Mock AI response
      def mock_ai_response(response_attrs = {})
        response = build_mock_response(response_attrs)
        setup_llm_mock(response)
      end

      def build_mock_response(attrs)
        default_response = {
          final_answer: 'Mocked answer',
          status: :completed,
          iterations: 1,
          thought_process: []
        }
        default_response.merge(attrs)
      end

      def setup_llm_mock(response)
        return unless defined?(Soka::LLM)

        allow(Soka::LLM).to receive(:new).and_return(mock_llm)
        allow(mock_llm).to receive(:chat).and_return(
          Struct.new(:content).new(build_react_response(response))
        )
      end

      # Mock tool execution
      def mock_tool_execution(tool_class, result)
        allow_any_instance_of(tool_class).to receive(:call).and_return(result)
      end

      # Build ReAct format response
      def build_react_response(attrs)
        thoughts = attrs[:thought_process].presence ||
                   ['Analyzing the request']

        response = thoughts.map { |t| "<Thought>#{t}</Thought>" }.join("\n")
        response += "\n<Final_Answer>#{attrs[:final_answer]}</Final_Answer>"
        response
      end

      # Agent test helper methods
      def run_agent(agent, input, &)
        result = if block_given?
                   agent.run(input, &)
                 else
                   agent.run(input)
                 end

        expect(result).to be_a(Struct)
        result
      end

      # Event collector
      def collect_agent_events(agent, input)
        events = []

        agent.run(input) do |event|
          events << event
        end

        events
      end

      # Test configuration
      def with_test_configuration
        original_config = Soka::Rails.configuration.dup

        Soka::Rails.configure do |config|
          config.ai_provider = :mock
          config.max_iterations = 3
          config.timeout = 5
          yield config if block_given?
        end

        yield
      ensure
        Soka::Rails.configuration = original_config
      end

      # Helper method: create successful result
      def successful_result(attrs = {})
        default_attrs = {
          status: :completed,
          final_answer: 'Success',
          iterations: 1
        }

        Struct.new(*default_attrs.keys).new(*default_attrs.merge(attrs).values)
      end

      # Helper method: check if result is successful
      RSpec::Matchers.define :be_successful do
        match do |actual|
          actual.respond_to?(:status) && actual.status == :completed
        end

        failure_message do |actual|
          "expected result to be successful, but status was #{actual.status}"
        end
      end
    end
  end
end
