local openai = require("model.providers.openai")
local codellama = require("model.providers.codellama")
local ollama = require("model.providers.ollama")
local mode = require('model').mode
local extract = require('model.prompts.extract')
local util = require('util')
local prompts = require('model.util.prompts')

function code_replace_fewshot(input, context)
  local surrounding_text = prompts.limit_before_after(context, 30)

  local content = 'The code:\n```\n'
    .. surrounding_text.before
    .. '<@@>'
    .. surrounding_text.after
    .. '\n```\n'

  if context.selection then -- we only use input if we have a visual selection
    content = content .. '\n\nExisting text at <@@>:\n```' .. input .. '```\n'
  end

  if #context.args > 0 then
    content = content .. '\nInstruction: ' .. context.args
  end

  local messages = {
    {
      role = 'user',
      content = content,
    },
  }

  return {
    instruction = 'You are an expert programmer. You are given a snippet of code which includes the symbol <@@>. Complete the correct code that should replace the <@@> symbol given the content. Only respond with the code that should replace the symbol <@@>. If you include any other code, the program will fail to compile and the user will be very sad.',
    fewshot = {
      {
        role = 'user',
        content = 'The code:\n```\nfunction greet(name) { console.log("Hello " <@@>) }\n```\n\nExisting text at <@@>: `+ nme`',
      },
      {
        role = 'assistant',
        content = '+ name',
      },
    },
    messages = messages,
  }
end

M = {
  gpt4 = {
    provider = openai,
    mode = mode.INSERT_OR_REPLACE,
    params = {
      temperature = 0.2,
      max_tokens = 1000,
      model = 'gpt-4',
    },
    builder = function(input, context)
      return openai.adapt(code_replace_fewshot(input, context))
    end,
    transform = extract.markdown_code,
  },
  code = {
    provider = ollama,
    params = {
      model = 'codellama:13b',
      temperature = 0.1, -- Seems to rarely decode EOT if temp is high
      top_p = 0.9,
      n_predict = 256, -- Server seems to be ignoring this?
      repeat_penalty = 1.2, -- infill really struggles with overgenerating
    },
    builder = function(input)
      return {
        prompt = "You are a helpful coding assistant\n" .. input
      }
    end,
  },
}


return M

