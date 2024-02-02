local ollama = require("model.providers.ollama")
-- local openai = require("model.providers.openai")
-- local llama2_fmt = require('model.format.llama2')
-- local starling_fmt = require('model.format.starling')

-- local function input_if_selection(input, context)
--   return context.selection and input or ''
-- end

M = {
  code = {
    provider = ollama,
    params = {
      model = 'codellama:70b',
    },
    system = 'You are an intelligent programming assistant, have a chat about the following:',
    create = function(input, ctx)
      return ctx.selection and input or ''
    end,
    run = function(messages, _)
      local prompt = '<s>Source: system \n\n'

      for _, msg in ipairs(messages) do
        prompt = prompt
          .. '\n\n### '
          .. (msg.role == 'user' and 'Source: user\n\n' or 'Source: assistant\n\n')
          .. '\n'
          .. msg.content
      end

      prompt = prompt .. 'Source: assistant\nDestination: user\n\n'

      return {
        prompt = prompt,
      }
    end,
  }
}
return M
